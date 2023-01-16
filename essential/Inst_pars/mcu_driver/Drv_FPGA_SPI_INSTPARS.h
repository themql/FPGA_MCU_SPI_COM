#ifndef __DRV_FPGA_SPI_INSTPARS_H
#define __DRV_FPGA_SPI_INSTPARS_H
#ifdef __cplusplus
  extern "C" {
#endif


#include "main.h"


union Data16
{
  uint16_t  data;
  uint8_t   Bytes[2];
};


/*******************  regiser define  *************/
// 0    R   sum[15:0]
// 1    RW  num1[15:0]
// 2    RW  num2[15:0]
// 3    RW  num3[15:0]
// 4    R   en[0]
#define REGADDR_sum     (0)
#define REGADDR_num1    (1)
#define REGADDR_num2    (2)
#define REGADDR_num3    (3)
#define REGADDR_en      (4)

#define REG_DATA_OFFSET   (2)
#define FIFO_DATA_OFFSET  (3)
#define RAM_DATA_OFFSET   (5)


extern uint8_t FPGA_SPI_Buf_Send [1024];
extern uint8_t FPGA_SPI_Buf_Rece [1024];

void FPGA_SPI_disable();
void FPGA_SPI_enable();
void FPGA_SPI_writeReg(uint8_t regAddr, uint16_t regData);
uint16_t FPGA_SPI_readReg(uint8_t regAddr);
void FPGA_SPI_writeFIFO(uint16_t dataCnt, uint16_t* dataSrc);
void FPGA_SPI_readFIFO(uint16_t dataCnt, uint16_t* dataDes);
void FPGA_SPI_writeRAM(uint16_t firstAddr, uint16_t dataCnt, uint16_t* dataSrc);
void FPGA_SPI_readRAM(uint16_t firstAddr, uint16_t dataCnt, uint16_t* dataDes);


#ifdef __cplusplus
  }
#endif
#endif /* __DRV_FPGA_SPI_INSTPARS_H */
