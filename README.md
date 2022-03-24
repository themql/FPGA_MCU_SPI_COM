# FPGA 与 MCU 简易spi通信

## 0. Intro

​		看了些资料，觉得两种FPGA与MCU通信方式十分不错：基于状态机的指令解析与基于寄存器的硬件控制。

​		指令解析效率很高，通讯协议设计的好，几次spi传输就能实现目标效果，但状态机设计比较繁琐，设计需求一变，状态机就得重写。

​		基于寄存器的设计比较灵活，只需将FPGA的控制与配置信号设计成寄存器，由MCU改变寄存器的值即可实现对FPGA的控制。若控制信号位数少，甚至不需要spi，直接将控制信号线接到FPGA引脚上，MCU只需控制这些引脚的电平。

​		本实验实现了基于寄存器的设计，FPGA采用EP4CE15，MCU采用STM32F407。



## 1. FPGA部分

​		RTL中包含3个文件，sim中是对顶层的仿真。

​		实现reg0 = reg1 + reg2 + reg3

| 文件名        | 描述                                       |
| ------------- | ------------------------------------------ |
| design_main.v | 顶层设计                                   |
| SPI_if.v      | spi接口(interface)，对寄存器封装           |
| Drv_SPI.v     | spi的实现，使用两条ssel对cmd和data进行区分 |



### design_main.v

​		顶层。

​		利用SPI_if的寄存器接口实现需求设计。



### SPI_if.v

​		spi接口(interface)。

​		![Diagram_SPI_if](README.assets/Diagram_SPI_if.png)

​		描述所需的寄存器，实现Drv_SPI模块对这些寄存器的读写与寄存器的对外接口。



### Drv_SPI.v

​		spi的实现。

​		![image-20220324234240027](README.assets/Diagram_Drv_SPI.png)

​       使用两条ssel对cmd和data进行区分，每次spi传输时只允许使用一条ssel，传输结束时(ssel拉高)，数据会显示在对应的端口上(Dcmd/Dout)，并且对应的结束标志(done_cmd/done_data)会拉高一个周期。cmd与data的位宽可由对应的parameter设置。



#### 仿真波形

​		![sim_wave](README.assets/sim_wave.png)



## 2. MCU驱动

​		无话可说



## 3. 样例

​		摸了

