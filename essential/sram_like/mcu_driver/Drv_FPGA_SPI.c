#include "Drv_FPGA_SPI.h"


// setting
#define USE_BITBAND (1) // need to dalay appropriate time or increase FPGA clock

#define HARD_SPI    (0)
#define HSPI        (hspi2)
#define SIMU_SPI    (1)



// Pin Operation
#if USE_BITBAND
  #include "BitBand.h"
  #include "Drv_TIM.h"  // delay_us

  #define FPGA_SPI_CS_ADDR(x)    (PFout(7)) = (x)
  #define FPGA_SPI_CS_DATA(x)   (PFout(8)) = (x)

  #if SIMU_SPI
    #define FPGA_SPI_SCL(x)     delay_us(5); (PDout(10)) = (x)
    #define FPGA_SPI_MOSI(x)    (PBout(12)) = (x)
    #define FPGA_SPI_MISO()     (PCin(0))
  #endif
#else
  #define FPGA_SPI_CS_ADDR(x)    HAL_GPIO_WritePin(FPGA_SPI_CS_ADDR_GPIO_Port,  FPGA_SPI_CS_ADDR_Pin,  ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )
  #define FPGA_SPI_CS_DATA(x)   HAL_GPIO_WritePin(FPGA_SPI_CS_DATA_GPIO_Port, FPGA_SPI_CS_DATA_Pin, ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )

  #if SIMU_SPI
    #define FPGA_SPI_SCL(x)     HAL_GPIO_WritePin(FPGA_SPI_SCL_GPIO_Port,     FPGA_SPI_SCL_Pin,     ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )
    #define FPGA_SPI_MOSI(x)    HAL_GPIO_WritePin(FPGA_SPI_MOSI_GPIO_Port,    FPGA_SPI_MOSI_Pin,    ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )
    #define FPGA_SPI_MISO()     HAL_GPIO_ReadPin (FPGA_SPI_MISO_GPIO_Port,    FPGA_SPI_MISO_Pin )
  #endif
#endif


// SPI implement
#if 1
  #if HARD_SPI
    extern SPI_HandleTypeDef HSPI;
  #endif

  void spi_send8(uint8_t data)
  {
  #if SIMU_SPI
    uint32_t i;

    for(i = 0; i < 8; ++i)
    {
      FPGA_SPI_MOSI((data &(0x80))) ?1 :0);
      data <<= 1;
      FPGA_SPI_SCL(1);
      FPGA_SPI_SCL(0);
    }
  #endif

  #if HARD_SPI
    HAL_SPI_Transmit(&HSPI, (uint8_t*)data, 1, 50);
  #endif
  }

  void spi_send16(uint16_t data)
  {
  #if SIMU_SPI
    uint32_t i;

    for(i = 0; i < 16; ++i)
    {
      FPGA_SPI_MOSI((data &(0x8000)) ?1 :0);
      data <<= 1;
      FPGA_SPI_SCL(1);
      FPGA_SPI_SCL(0);
    }
  #endif

  #if HARD_SPI
    HAL_SPI_Transmit(&HSPI, (uint8_t*)data, 2, 50);
  #endif
  }

  void spi_send32(uint32_t data)
  {
  #if SIMU_SPI
    uint32_t i;

    for(i = 0; i < 32; ++i)
    {
      FPGA_SPI_MOSI((data &(0x80000000)) ?1 :0);
      data <<= 1;
      FPGA_SPI_SCL(1);
      FPGA_SPI_SCL(0);
    }
  #endif

  #if HARD_SPI
    HAL_SPI_Transmit(&HSPI, (uint8_t*)data, 4, 50);
  #endif
  }

  void spi_rece8(uint32_t *data)
  {
  #if SIMU_SPI
    uint32_t i;

    *data = 0;
    for(i = 0; i < 8; ++i)
    {
      FPGA_SPI_SCL(1);
      *data <<= 1;
      *data = (*data) | (FPGA_SPI_MISO());
      FPGA_SPI_SCL(0);
    }
  #endif

  #if HARD_SPI
    HAL_SPI_Receive(&HSPI, (uint8_t*)data, 1, 50);
  #endif
  }

  void spi_rece16(uint32_t *data)
  {
  #if SIMU_SPI
    uint32_t i;

    *data = 0;
    for(i = 0; i < 16; ++i)
    {
      FPGA_SPI_SCL(1);
      *data <<= 1;
      *data = (*data) | (FPGA_SPI_MISO());
      FPGA_SPI_SCL(0);
    }
  #endif

  #if HARD_SPI
    HAL_SPI_Receive(&HSPI, (uint8_t*)data, 2, 50);
  #endif
  }

  void spi_rece32(uint32_t *data)
  {
  #if SIMU_SPI
    uint32_t i;

    *data = 0;
    for(i = 0; i < 32; ++i)
    {
      FPGA_SPI_SCL(1);
      *data <<= 1;
      *data = (*data) | (FPGA_SPI_MISO());
      FPGA_SPI_SCL(0);
    }
  #endif

  #if HARD_SPI
    HAL_SPI_Receive(&HSPI, (uint8_t*)data, 4, 50);
  #endif
  }
#endif


// Send and receive data
void FPGA_SPI_Send_Addr(uint32_t addr)
{
  FPGA_SPI_CS_ADDR(0);
#if   (WIDTH_BYTE_ADDR == 1)
  spi_send8((uint8_t)addr);
#endif
  FPGA_SPI_CS_ADDR(1);
}

void FPGA_SPI_Send_Data(uint32_t data)
{
  FPGA_SPI_CS_DATA(0);
#if   (WIDTH_BYTE_DATA == 1)
  spi_send8((uint8_t)data);
#elif (WIDTH_BYTE_DATA == 2)
  spi_send16((uint16_t)data);
#elif (WIDTH_BYTE_DATA == 4)
  spi_send32((uint32_t)data);
#endif
  FPGA_SPI_CS_DATA(1);
}

uint32_t FPGA_SPI_Rece_Data(void)
{
  uint32_t receData = 0;

  FPGA_SPI_CS_DATA(0);
#if   (WIDTH_BYTE_DATA == 1)
  spi_rece8(&receData);
#elif (WIDTH_BYTE_DATA == 2)
  spi_rece16(&receData);
#elif (WIDTH_BYTE_DATA == 4)
  spi_rece32(&receData);
#endif
  FPGA_SPI_CS_DATA(1);

  return receData;
}

void FPGA_SPI_Send(uint8_t addr, uint32_t data)
{
  FPGA_SPI_Send_Addr(addr);
  FPGA_SPI_Send_Data(data);
}

uint32_t FPGA_SPI_Rece(uint8_t addr)
{
  FPGA_SPI_Send_Addr(addr);
  return (FPGA_SPI_Rece_Data());
}
