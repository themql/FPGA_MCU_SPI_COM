#ifndef __DRV_FPGA_SPI_SRAMLIKE_H
#define __DRV_FPGA_SPI_SRAMLIKE_H
#ifdef __cplusplus
  extern "C" {
#endif


#include "main.h"


/*******************  regiser define  *************/
#define WIDTH_BYTE_ADDR   (1)
#define WIDTH_BYTE_DATA   (2)
#define WRITE_BASE        (0)
#define READ_BASE         (1 << (WIDTH_BYTE_ADDR * 8 - 1))

// write addr (0-127)
#define WADDR_num1      (WRITE_BASE + 1)
#define WADDR_num2      (WRITE_BASE + 2)
#define WADDR_NUM3      (WRITE_BASE + 3)
#define WADDR_fifo_w    (WRITE_BASE + 4)
#define WADDR_ram_waddr (WRITE_BASE + 5)
#define WADDR_ram_raddr (WRITE_BASE + 6)
#define WADDR_ram_wdata (WRITE_BASE + 7)
#define WADDR_ctrl      (WRITE_BASE + 8)

// read addr (128-255)
#define RADDR_sum       (READ_BASE + 0)
#define RADDR_num1      (READ_BASE + 1)
#define RADDR_num2      (READ_BASE + 2)
#define RADDR_NUM3      (READ_BASE + 3)
#define RADDR_fifo_w    (READ_BASE + 4)
#define RADDR_ram_waddr (READ_BASE + 5)
#define RADDR_ram_raddr (READ_BASE + 6)
#define RADDR_ram_wdata (READ_BASE + 7)
#define RADDR_ctrl      (READ_BASE + 8)

/*******************  reg setting end  **********/


void      FPGA_SPI_Send_Addr(uint32_t addr);
void      FPGA_SPI_Send_Data(uint32_t data);
uint32_t  FPGA_SPI_Rece_Data(void);

void      FPGA_SPI_Send(uint8_t addr, uint32_t data);
uint32_t  FPGA_SPI_Rece(uint8_t addr);

#ifdef __cplusplus
  }
#endif
#endif /* __DRV_FPGA_SPI_SRAMLIKE_H */
