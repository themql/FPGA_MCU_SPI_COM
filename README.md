## FPGA 与 STMF4 简易spi通信

FPGA作为从机，STM作为主机，FPGA无法主动发起通信。

FPGA提供读写地址供STM操作，默认16个通道（读8写8），最大256个（地址寄存器只设定了8位）。

默认16通道测试通过。

F4 端建议使用HAL_GPIO_WritePin操作GPIO, 利用硬件SPI还未实现。