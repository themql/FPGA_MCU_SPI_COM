# FPGA 与 MCU 简易spi通信

## 0. Intro

​       本仓库实现两种基于SPI的FPGA与MCU通讯方式：类SRAM接口与指令解析。

​       不论哪种方式，MCU都是通过修改FPGA内部一些控制寄存器的值实现对FPGA硬件的控制。在类SRAM接口方式中，每一个控制寄存器与数据寄存器的读写都被分配了唯一的地址，通过指定地址，即可实现对目标寄存器的读或写操作。在指令解析方式中，则是通过状态机对MCU发送的指令进行解析，实现对目标寄存器的读写。

​       本仓库分为两个部分，essential中实现了基本的读写功能，即寄存器的读写、FIFO的读写与DPRAM的读写，simpleDSP中实现了简单的数字信号处理功能，包括信号采样、FFT与IFFT、FIR滤波。

​       实验中使用了Intel的IP核，并提供相应的仿真，具体的软硬件平台如下表所示。

| 平台          |                 |
| ----------- |:--------------- |
| FPGA        | EP4CE15         |
| MCU         | STM32F407       |
| **软件**      |                 |
| Quartus     | 18.1.1 Standard |
| Keil        |                 |
| STM32CubeMX | 6.5.0           |

## 1. 目录结构

```
FPGA_MCU_SPI_COM
├── LICENSE
├── README.assert                   // README中图像
├── README.md
├── essential                       // 基础部分
│   ├── Inst_pars                   // 指令解析
│   │   ├── RTL                     // RTL实现
│   │   ├── mcu_driver              // 驱动程序
│   │   └── sim                     // 仿真
│   │       ├── modelsim_prj
│   │       │   ├── run.do          // 仿真运行脚本
│   │       │   ├── wave.do         // 波形脚本
│   │       ├── run.bat             // 启动脚本
│   │       └── tb_main.v
│   ├── alt_ip                      // 使用到的IP核
│   └── sram_like
│       ├── RTL
│       ├── mcu_driver
│       └── sim                     // 与Inst_pars类似，就不展开了
└── simpleDSP                       // todo
    ├── dsp
    ├── inst_pars
    └── sram_like
```

## 2. SPI模块

![](README.assert/2022-06-19-00-34-08-image.png)

![](README.assert/2022-06-19-00-44-24-image.png)

​       SPI模块实现了spi的从机模式，并且只支持mode 0，即上升沿采样下降沿切换。通过对scl、sel等信号的采样，判断出这些信号的上升下降沿，作出相应的动作，因此，scl的最大频率受到clk的制约。例如clk取50M，scl的频率就不能超过25M。

​       Data_begin与Data_end信号作为通讯的开始与结束标志，也是DIn与Dout端口数据的有效标志。在Data_begin拉底前，Din端口就应准备好数据，否则Din数据无法及时地被SPI模块装载，sdo也就无法正确输出。同理，在Data_end拉高前，也不应该去读取Dout端口的数据。

## 3. essential

* 简单求和

​       SPI接口模块内存在一些寄存器，并在端口处将他们引出。为了简单测试寄存器的功能，用纯组合逻辑实现了这些寄存器的求和。

* dual clk FIFO

​       使用Intel的IP核，配置大小为16*256，show ahead模式。

* dual port RAM

​       使用Intel的IP核，配置大小为16*256，区分读写时钟，读端口数据不需要寄存。

## 4. 类SRAM接口

## 5. 指令解析接口

## 6. simpleDSP
