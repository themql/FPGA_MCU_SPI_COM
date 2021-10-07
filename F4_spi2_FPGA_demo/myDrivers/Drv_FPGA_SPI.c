#include "Drv_FPGA_SPI.h"


// setting
#define WIDTH_BYTE_CMD    (1)
#define WIDTH_BYTE_DATA   (2)
#define SPI_DATA_WIDTH    (WIDTH_BYTE_DATA * 8)
// 位带不好用, 不延时太快数据出错, 延1us又太慢
#define USE_BITBAND (0)
#define HARD_SPI    (0)
#define SIMU_SPI    (1)



// Pin Process
#if USE_BITBAND
  #include "BitBand.h"
  #include "Drv_TIM.h"

  #if HARD_SPI
    // hardspi pin addr
    // #define PIN_SCL        (PBout(13))
    // #define PIN_MOSI       (PCout(3))
    // #define PIN_MISO       (PCin(2))
    #define PIN_CS_CMD     (PCout(0))
    #define PIN_CS_DATA    (PCout(1))

    #define FPGA_SPI_CS_CMD(x)    PIN_CS_CMD = (x)
    #define FPGA_SPI_CS_DATA(x)   PIN_CS_DATA = (x)
  #endif

  #if SIMU_SPI
    #define PIN_SCL     (PDout(10))
    #define PIN_MOSI    (PBout(12))
    #define PIN_MISO    (PCin(0))
    #define PIN_CS_CMD  (PFout(7))
    #define PIN_CS_DATA (PFout(8))

    #define FPGA_SPI_SCL(x)       PIN_SCL = (x)
    #define FPGA_SPI_MOSI(x)      PIN_MOSI = (x)
    #define FPGA_SPI_MISO()       PIN_MISO
    #define FPGA_SPI_CS_CMD(x)    PIN_CS_CMD = (x)
    #define FPGA_SPI_CS_DATA(x)   PIN_CS_DATA = (x)
  #endif
#else
  #define FPGA_SPI_CS_CMD(x)    HAL_GPIO_WritePin(FPGA_SPI_CS_CMD_GPIO_Port,  FPGA_SPI_CS_CMD_Pin,  ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )
  #define FPGA_SPI_CS_DATA(x)   HAL_GPIO_WritePin(FPGA_SPI_CS_DATA_GPIO_Port, FPGA_SPI_CS_DATA_Pin, ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )

  #if SIMU_SPI
    #define FPGA_SPI_SCL(x)     HAL_GPIO_WritePin(FPGA_SPI_SCL_GPIO_Port,     FPGA_SPI_SCL_Pin,     ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )
    #define FPGA_SPI_MOSI(x)    HAL_GPIO_WritePin(FPGA_SPI_MOSI_GPIO_Port,    FPGA_SPI_MOSI_Pin,    ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )
    #define FPGA_SPI_MISO()     HAL_GPIO_ReadPin (FPGA_SPI_MISO_GPIO_Port,    FPGA_SPI_MISO_Pin )
  #endif
#endif


// Generate Timing, Send Data
#if HARD_SPI
  extern SPI_HandleTypeDef hspi2;

  void FPGA_SPI_Send_Cmd(uint32_t cmd)
  {
    FPGA_SPI_CS_CMD(0);
    HAL_SPI_Transmit(&hspi2, (uint8_t*)cmd, WIDTH_BYTE_CMD, 50);
    FPGA_SPI_CS_CMD(1);
  }

  void FPGA_SPI_Send_Data(uint32_t data)
  {
    FPGA_SPI_CS_DATA(0);
    HAL_SPI_Transmit(&hspi2, (uint8_t*)data, WIDTH_BYTE_DATA, 50);
    FPGA_SPI_CS_DATA(1);
  }

  uint32_t FPGA_SPI_Rece_Data(void)
  {
    uint32_t buf_data = 0;

    FPGA_SPI_CS_DATA(0);
    HAL_SPI_TransmitReceive(&hspi2, (uint8_t*)buf_data, (uint8_t*)buf_data, WIDTH_BYTE_DATA, 50);
    FPGA_SPI_CS_DATA(1);

    return  buf_data;
  }

#elif SIMU_SPI
  #if   (SPI_DATA_WIDTH == 8 ) 
    #define MSB_CHECK (0x00000080)
  #elif (SPI_DATA_WIDTH == 16)
    #define MSB_CHECK (0x00008000)
  #elif (SPI_DATA_WIDTH == 32)
    #define MSB_CHECK (0x80000000)
  #endif
  
  void FPGA_SPI_Send_Cmd(uint32_t cmd)
  {
    uint32_t i;

    FPGA_SPI_CS_CMD(0);
    for(i = 0; i < 8; ++i)
    {
      FPGA_SPI_MOSI((cmd &(0x00000080)) ?1 :0);
      cmd <<= 1;
      FPGA_SPI_SCL(0);
      FPGA_SPI_SCL(1);
      #if USE_BITBAND
        delay_US(1);
      #endif
    }
    FPGA_SPI_CS_CMD(1);
  }

  void FPGA_SPI_Send_Data(uint32_t data)
  {
    uint32_t i;

    FPGA_SPI_CS_DATA(0);
    for(i = 0; i < SPI_DATA_WIDTH; ++i)
    {
      FPGA_SPI_MOSI((data &MSB_CHECK) ?1 :0);
      data <<= 1;
      FPGA_SPI_SCL(0);
      FPGA_SPI_SCL(1);
      #if USE_BITBAND
        delay_US(1);
      #endif
    }
    FPGA_SPI_CS_DATA(1);
  }

  uint32_t FPGA_SPI_Rece_Data(void)
  {
    uint32_t i;
    uint32_t buf_data = 0;

    FPGA_SPI_CS_DATA(0);
    for( i = 0; i < SPI_DATA_WIDTH; ++i)
    {
      buf_data <<= 1;
      buf_data = buf_data | (FPGA_SPI_MISO());
      FPGA_SPI_SCL(1);
      FPGA_SPI_SCL(0);
      #if USE_BITBAND
        delay_US(1);
      #endif
    }
    FPGA_SPI_CS_DATA(1);

    return  buf_data;
  }
#endif





void FPGA_SPI_Send(uint8_t cmd, uint32_t data)
{
  FPGA_SPI_Send_Cmd(cmd);
  FPGA_SPI_Send_Data(data);
}

uint32_t FPGA_SPI_Rece(uint8_t cmd)
{
  FPGA_SPI_Send_Cmd(cmd);
  return (FPGA_SPI_Rece_Data());
}
