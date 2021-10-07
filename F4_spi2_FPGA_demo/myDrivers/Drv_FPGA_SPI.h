#ifndef __DRV_FPGA_SPI_H
#define __DRV_FPGA_SPI_H
#ifdef __cplusplus
  extern "C" {
#endif


#include "main.h"

/*******************  reg setting  *************/
// wr addr (8-15)
#define CMD_wr0   (8)
#define CMD_wr1   (9)
#define CMD_wr2   (10)
#define CMD_wr3   (11)
#define CMD_wr4   (12)
#define CMD_wr5   (13)
#define CMD_wr6   (14)
#define CMD_wr7   (15)

// rd addr (0-7)
#define CMD_rd0   (0)
#define CMD_rd1   (1)
#define CMD_rd2   (2)
#define CMD_rd3   (3)
#define CMD_rd4   (4)
#define CMD_rd5   (5)
#define CMD_rd6   (6)
#define CMD_rd7   (7)

/*******************  reg setting end  **********/


void FPGA_SPI_Send(uint8_t cmd, uint32_t data);
uint32_t FPGA_SPI_Rece(uint8_t cmd);
void FPGA_SPI_Send_Cmd(uint32_t cmd);

#ifdef __cplusplus
  }
#endif
#endif /* __DRV_FPGA_SPI_H */