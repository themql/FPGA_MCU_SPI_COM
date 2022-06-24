#include "Drv_FPGA_SPI_INSTPARS.h"


// setting
#define SPI_WIDTH_BYTE  (1)
#define Buf_size        (1024)

#define USE_BITBAND (0) // need to dalay appropriate time or increase FPGA clock

#define HARD_SPI    (0)
#define HSPI        (hspi2)
#define SIMU_SPI    (1)


// buffer define
uint8_t FPGA_SPI_Buf_Send [Buf_size];
uint8_t FPGA_SPI_Buf_Rece [Buf_size];

// Pin Operation
#if USE_BITBAND
  #include "BitBand.h"
  #include "Drv_TIM.h"  // delay_us

  #define FPGA_SPI_SEL(x)       (PFout(7)) = (x)

  #if SIMU_SPI
    #define FPGA_SPI_SCL(x)     delay_us(5); (PDout(10)) = (x)
    #define FPGA_SPI_MOSI(x)    (PBout(12)) = (x)
    #define FPGA_SPI_MISO()     (PCin(0))
  #endif
#else
  #define FPGA_SPI_SEL(x)       HAL_GPIO_WritePin(FPGA_SPI_SEL_GPIO_Port,   FPGA_SPI_SEL_Pin, ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )

  #if SIMU_SPI
    #define FPGA_SPI_SCL(x)     HAL_GPIO_WritePin(FPGA_SPI_SCL_GPIO_Port,   FPGA_SPI_SCL_Pin,     ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )
    #define FPGA_SPI_MOSI(x)    HAL_GPIO_WritePin(FPGA_SPI_MOSI_GPIO_Port,  FPGA_SPI_MOSI_Pin,    ((x) ?GPIO_PIN_SET :GPIO_PIN_RESET) )
    #define FPGA_SPI_MISO()     HAL_GPIO_ReadPin (FPGA_SPI_MISO_GPIO_Port,  FPGA_SPI_MISO_Pin )
  #endif
#endif


// SPI implement
#if 1
  static void spi_SendRece(uint8_t *pTxData, uint8_t *pRxData, uint16_t size)
  {
  #if SIMU_SPI
    uint32_t i, cnt;

    if(size > Buf_size)
      return;
    for(cnt = 0; cnt < size; ++cnt)
    {
      pRxData[cnt] = 0;
      for(i = 0; i < 8; ++i)
      {
        FPGA_SPI_MOSI((pTxData[cnt] &(0x80)) ?1 :0);
        pTxData[cnt] <<= 1;
        FPGA_SPI_SCL(1);
        pRxData[cnt] <<= 1;
        pRxData[cnt] = (pRxData[cnt]) | (FPGA_SPI_MISO());
        FPGA_SPI_SCL(0);
      }
    }
  #endif

  #if HARD_SPI
    extern SPI_HandleTypeDef HSPI;
    HAL_SPI_TransmitReceive(&HSPI, pTxData, pRxData, size, 50);
  #endif
  }
#endif


// user instruction
// disable
// | 0x00     |
// enable
// | 0x01     |
// write register
// | 0x02     | regAddr | regData_0 | regData_1 |
// read register
// | 0x03     | regAddr | 0x00      | 0x00      |
// write fifo
// | 0x04     | dataCnt_0 | dataCnt_1 | data0_0 | data0_1 | ... | dataX_0 | dataX_1 |
// read fifo
// | 0x05     | dataCnt_0 | dataCnt_1 | 0x00    | 0x00    | ... | 0x00    | 0x00    |
// write ram
// | 0x06     | firstAddr_0 | firstAddr_1 | dataCnt_0 | dataCnt_1 | data0_0 | data0_1 | ... | dataX_0 | dataX_1 |
// read ram
// | 0x07     | firstAddr_0 | firstAddr_1 | dataCnt_0 | dataCnt_1 | 0x00    | 0x00    | ... | 0x00    | 0x00    |

void FPGA_SPI_disable()
{
  FPGA_SPI_Buf_Send[0] = 0x00;
  spi_SendRece(FPGA_SPI_Buf_Send, FPGA_SPI_Buf_Rece, 1);
}

void FPGA_SPI_enable()
{
  FPGA_SPI_Buf_Send[0] = 0x01;
  spi_SendRece(FPGA_SPI_Buf_Send, FPGA_SPI_Buf_Rece, 1);
}

void FPGA_SPI_writeReg(uint8_t regAddr, uint16_t regData)
{
  FPGA_SPI_Buf_Send[0] = 0x02;
  FPGA_SPI_Buf_Send[1] = regAddr;
  FPGA_SPI_Buf_Send[2] = (uint8_t)(regData >> 8);
  FPGA_SPI_Buf_Send[3] = (uint8_t)(regData & 0x00FF);
  spi_SendRece(FPGA_SPI_Buf_Send, FPGA_SPI_Buf_Rece, 4);
}

void FPGA_SPI_readReg(uint8_t regAddr)
{
  FPGA_SPI_Buf_Send[0] = 0x03;
  FPGA_SPI_Buf_Send[1] = regAddr;
  FPGA_SPI_Buf_Send[2] = 0x00;
  FPGA_SPI_Buf_Send[3] = 0x00;
  spi_SendRece(FPGA_SPI_Buf_Send, FPGA_SPI_Buf_Rece, 4);
}

void FPGA_SPI_writeFIFO(uint16_t dataCnt)
{
  FPGA_SPI_Buf_Send[0] = 0x04;
  FPGA_SPI_Buf_Send[1] = (uint8_t)(dataCnt >> 8);
  FPGA_SPI_Buf_Send[2] = (uint8_t)(dataCnt & 0x00FF);
  spi_SendRece(FPGA_SPI_Buf_Send, FPGA_SPI_Buf_Rece, 3 + dataCnt * 2);
}

void FPGA_SPI_readFIFO(uint16_t dataCnt)
{
  uint32_t i;

  FPGA_SPI_Buf_Send[0] = 0x05;
  FPGA_SPI_Buf_Send[1] = (uint8_t)(dataCnt >> 8);
  FPGA_SPI_Buf_Send[2] = (uint8_t)(dataCnt & 0x00FF);
  for(i = 0; i < dataCnt; ++i)
  {
    FPGA_SPI_Buf_Send[FIFOData_BeginAddr + 0 + i * 2] = 0x00;
    FPGA_SPI_Buf_Send[FIFOData_BeginAddr + 1 + i * 2] = 0x00;
  }
  spi_SendRece(FPGA_SPI_Buf_Send, FPGA_SPI_Buf_Rece, 3 + dataCnt * 2);
}

void FPGA_SPI_writeRAM(uint16_t firstAddr, uint16_t dataCnt)
{
  FPGA_SPI_Buf_Send[0] = 0x06;
  FPGA_SPI_Buf_Send[1] = (uint8_t)(firstAddr >> 8);
  FPGA_SPI_Buf_Send[2] = (uint8_t)(firstAddr & 0x00FF);
  FPGA_SPI_Buf_Send[3] = (uint8_t)(dataCnt >> 8);
  FPGA_SPI_Buf_Send[4] = (uint8_t)(dataCnt & 0x00FF);
  spi_SendRece(FPGA_SPI_Buf_Send, FPGA_SPI_Buf_Rece, 5 + dataCnt * 2);
}

void FPGA_SPI_readRAM(uint16_t firstAddr, uint16_t dataCnt)
{
  uint32_t i;

  FPGA_SPI_Buf_Send[0] = 0x07;
  FPGA_SPI_Buf_Send[1] = (uint8_t)(firstAddr >> 8);
  FPGA_SPI_Buf_Send[2] = (uint8_t)(firstAddr & 0x00FF);
  FPGA_SPI_Buf_Send[3] = (uint8_t)(dataCnt >> 8);
  FPGA_SPI_Buf_Send[4] = (uint8_t)(dataCnt & 0x00FF);
  for(i = 0; i < dataCnt; ++i)
  {
    FPGA_SPI_Buf_Send[RAMData_BeginAddr + 0 + i * 2] = 0x00;
    FPGA_SPI_Buf_Send[RAMData_BeginAddr + 1 + i * 2] = 0x00;
  }
  spi_SendRece(FPGA_SPI_Buf_Send, FPGA_SPI_Buf_Rece, 5 + dataCnt * 2);
}
