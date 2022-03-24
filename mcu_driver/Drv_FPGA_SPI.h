#ifndef __DRV_FPGA_SPI_H
#define __DRV_FPGA_SPI_H
#ifdef __cplusplus
  extern "C" {
#endif


#include "main.h"


/*******************  regiser define  *************/
#define WRITE_BASE  (0)
#define READ_BASE   (128)

// write addr (0-127)
#define CMDWR_reg1  (WRITE_BASE + 1)
#define CMDWR_reg2  (WRITE_BASE + 2)
#define CMDWR_reg3  (WRITE_BASE + 3)

// read addr (128-255)
#define CMDRD_reg0  (READ_BASE + 0)
#define CMDRD_reg1  (READ_BASE + 1)
#define CMDRD_reg2  (READ_BASE + 2)
#define CMDRD_reg3  (READ_BASE + 3)

/*******************  reg setting end  **********/


void      FPGA_SPI_Send_Cmd(uint32_t cmd);
void      FPGA_SPI_Send_Data(uint32_t data);
uint32_t  FPGA_SPI_Rece_Data(void);

void      FPGA_SPI_Send(uint8_t cmd, uint32_t data);
uint32_t  FPGA_SPI_Rece(uint8_t cmd);

#ifdef __cplusplus
  }
#endif
#endif /* __DRV_FPGA_SPI_H */