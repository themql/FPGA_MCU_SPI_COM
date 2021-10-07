#ifndef __BITBAND_H
#define __BITBAND_H
#ifdef __cplusplus
  extern "C" {
#endif

#include "stm32f4xx.h"

//找出别名区
//addr  --地址（寄存器）
//bit   --位（要操作的寄存器的位）
#define BITBAND(addr,bit)  (((addr & 0xF0000000) +0x2000000) + ((addr & 0xFFFFF)*8+bit)*4)
//                         别名区基地址                      + 偏移量
//操作别名区
#define MEM_ADDR(addr,bit) *(volatile unsigned int *)BITBAND(addr,bit)


//PA6  --1 
//PAout(6) =1;
//ODR
#define PAout(bit)  MEM_ADDR((unsigned int)&GPIOA->ODR,bit)
#define PBout(bit)  MEM_ADDR((unsigned int)&GPIOB->ODR,bit)
#define PCout(bit)  MEM_ADDR((unsigned int)&GPIOC->ODR,bit)
#define PDout(bit)  MEM_ADDR((unsigned int)&GPIOD->ODR,bit)
#define PEout(bit)  MEM_ADDR((unsigned int)&GPIOE->ODR,bit)
#define PFout(bit)  MEM_ADDR((unsigned int)&GPIOF->ODR,bit)    
#define PGout(bit)  MEM_ADDR((unsigned int)&GPIOG->ODR,bit)
#define PHout(bit)  MEM_ADDR((unsigned int)&GPIOH->ODR,bit)
//IDR
#define PAin(bit)   MEM_ADDR((unsigned int)&GPIOA->IDR,bit)
#define PBin(bit)   MEM_ADDR((unsigned int)&GPIOB->IDR,bit)
#define PCin(bit)   MEM_ADDR((unsigned int)&GPIOC->IDR,bit)
#define PDin(bit)   MEM_ADDR((unsigned int)&GPIOD->IDR,bit)
#define PEin(bit)   MEM_ADDR((unsigned int)&GPIOE->IDR,bit)
#define PFin(bit)   MEM_ADDR((unsigned int)&GPIOF->IDR,bit)    
#define PGin(bit)   MEM_ADDR((unsigned int)&GPIOG->IDR,bit)
#define PHin(bit)   MEM_ADDR((unsigned int)&GPIOH->IDR,bit)

#ifdef __cplusplus
  }
#endif
#endif /* __BITBAND_H */
