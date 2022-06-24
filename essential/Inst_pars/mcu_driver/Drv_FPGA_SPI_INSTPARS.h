#ifndef __DRV_FPGA_SPI_INSTPARS_H
#define __DRV_FPGA_SPI_INSTPARS_H
#ifdef __cplusplus
  extern "C" {
#endif


#include "main.h"


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

#define FIFOData_BeginAddr  (3)
#define RAMData_BeginAddr   (5)


extern uint8_t FPGA_SPI_Buf_Send [1024];
extern uint8_t FPGA_SPI_Buf_Rece [1024];

void FPGA_SPI_disable();
void FPGA_SPI_enable();
void FPGA_SPI_writeReg();
void FPGA_SPI_readReg();
void FPGA_SPI_writeFIFO();
void FPGA_SPI_readFIFO();
void FPGA_SPI_writeRAM();
void FPGA_SPI_readRAM();


#ifdef __cplusplus
  }
#endif
#endif /* __DRV_FPGA_SPI_INSTPARS_H */
