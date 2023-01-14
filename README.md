# FPGA 与 MCU 简易spi通信

## 0. Intro

​本仓库实现两种基于SPI的FPGA与MCU通讯方式：类SRAM接口与指令解析。

​不论哪种方式，MCU都是通过修改FPGA内部一些控制寄存器的值实现对FPGA硬件的控制。在类SRAM接口方式中，每一个控制寄存器与数据寄存器的读写都被分配了唯一的地址，通过指定地址，即可实现对目标寄存器的读或写操作。在指令解析方式中，则是通过状态机对MCU发送的指令进行解析，实现对目标寄存器的读写。

​本仓库分为两个部分，essential中实现了基本的读写功能，即寄存器的读写、FIFO的读写与DPRAM的读写，simpleDSP中实现了简单的数字信号处理功能（未完成），包括信号采样、FFT与IFFT、FIR滤波。

​实验中使用了Intel的IP核，并提供相应的仿真，具体的软硬件平台如下表所示。

| 平台          |                 |
| ----------- |:--------------- |
| FPGA        | EP4CE15         |
| MCU         | STM32F407       |
| **软件**      |                 |
| Quartus     | 18.1.1 Standard |
| Keil        |                 |
| STM32CubeMX | 6.5.0           |

## 1. 目录结构

**有的文件找不到，是还没做完。**

```
FPGA_MCU_SPI_COM
├── LICENSE
├── README.assert                   // README中图像
├── README.md
├── essential                       // 基础部分
│   ├── alt_ip                      // 使用到的IP核
│   ├── Inst_pars                   // 指令解析方式
│   │   ├── RTL                     // RTL实现
│   │   ├── mcu_driver              // 驱动程序
│   │   └── sim
│   │       ├── modelsim_prj
│   │       │   ├── run.do          // 仿真运行脚本
│   │       │   └── wave.do         // 波形脚本
│   │       ├── run.bat             // 启动脚本
│   │       └── tb_main.v
│   └── sram_like                   // 类SRAM接口方式
│      ├─sim
│      ├─fsmc
│      │  ├─mcu_driver
│      │  └─RTL
│      └─spi
│          ├─mcu_driver
│          └─RTL
└── simpleDSP                       // todo
```

## 2. SPI模块

![](README.assert/diagram_SPI.png)

![](README.assert/wave_SPI.png)

​SPI模块实现了spi的从机模式，并且只支持mode 0，即上升沿采样下降沿切换。通过对scl、sel等信号的采样，判断出这些信号的上升下降沿，作出相应的动作，因此，scl的最大频率受到clk的制约。例如clk取50M，scl的频率就不能超过25M。由于仅作从机，FPGA端没有主动向MCU发起传输的能力，当MCU需要读取数据时，需要发送空数据0产生scl时钟，待读取的数据才能在sdo线（FPGA端，对应MCU端sdi线）上出现。

​Data_begin与Data_end信号作为通讯的开始与结束标志，也是Din与Dout端口数据的有效标志。在data_begin拉底前，Din端口就应准备好数据，否则Din数据无法及时地被SPI模块装载，sdo也就无法正确输出。同理，在Data_end拉高前，也不应该去读取Dout端口的数据。

## 3. essential

* 简单求和

​SPI接口模块内存在一些寄存器，并在端口处将他们引出。为了简单测试寄存器的功能，用纯组合逻辑实现了这些寄存器的求和。

* dual clk FIFO

​使用Intel的IP核，配置大小为16位*256，show ahead模式。

* dual port RAM

​使用Intel的IP核，配置大小为16位*256，区分读写时钟，读端口数据不需要寄存。

* 使能控制

对上述3点功能添加使能控制。

## 4. 类SRAM接口

主要为三个模块：协议接口模块，寄存器组模块，功能模块。

协议接口模块用于将外部通信协议转换，对后级的寄存器组模块提供统一的读写接口（addr，wdata，rdata，wen，ren）。

寄存器组模块实现用户寄存器的定义与封装，读写RAM与FIFO的功能也在其中实现。

### 4.1 spi

协议接口模块采用双sel线spi_cs_addr与spi_cs_data，以区别本次传输的数据是地址还是数据。每次传输完毕会将地址或数据锁存。

![](README.assert/diagram_SPI_DCS.png)

寄存器组模块内为每个需要通过spi访问的寄存器分配**寄存器地址**。对寄存器组模块的读或写操作由传输地址决定，依据**寄存器地址**分为对应的读写地址，写地址最高位为0，读地址的最高位为1，其余位与**寄存器地址**保持相同。

| 寄存器地址 | 传输地址(8位，写操作） | 传输地址（8位，读操作） |
| ----- | ------------ | ------------ |
| 1     | 1            | 1+128        |

对于FIFO的读写操作，在指定地址后，允许多次的读**或**写数据。

对于所有的写操作，采用时序逻辑；对于所有的读操作，采用组合逻辑。

### 4.2 fsmc

并行传输在逻辑上是更简单的，无需用地址区分读写，对于RAM也可直接访问每个单元。当然数据线的增多意味着更复杂的硬件设计需求。

fsmc采用SRAM传输协议，A模式（OE翻转，在配置中打开extended mode）。1模式并未测试。

协议接口模块将异步的fsmc转换为同步方式；也可以不经过协议接口模块，直接对寄存器（RAM与FIFO的ip核仅提供同步方式）异步读写（regBank_async.v）。

## 5. 指令解析接口

spi传输位宽为8位，FPGA中数据的位宽位为16位。SPI模块为标准4线SPI。

多字节数据默认小端序（低字节在前）。（⚠但是testbench里需要设置成大端序）

### 5.1. 指令设计

共设计了8条指令：

| 指令描述    | 操作码（首字节） |
| ------- | -------- |
| disable | 0x00     |
| enable  | 0x01     |

用于置位控制寄存器ren;

| 指令描述           | 操作码（首字节） |         |           |           |
| -------------- | -------- | ------- | --------- | --------- |
| write register | 0x02     | regAddr | regData_0 | regData_1 |
| read register  | 0x03     | regAddr | 0x00      | 0x00      |

regAddr，内部数据寄存器编址。

regData_0，regData_1，大小端序由parameter `isLittleEndian` 决定。

| 指令描述       | 操作码（首字节） |           |           |         |         |     |         |         |
| ---------- | -------- | --------- | --------- | ------- | ------- | --- | ------- | ------- |
| write fifo | 0x04     | dataCnt_0 | dataCnt_1 | data0_0 | data0_1 | ... | dataX_0 | dataX_1 |
| read fifo  | 0x05     | dataCnt_0 | dataCnt_1 | 0x00    | 0x00    | ... | 0x00    | 0x00    |

FIFO读写，采用连续传输。

dataCnt，16位，传输数据的长度。

当FIFO满时，多余的数据无效；FIFO空时，读出0。

| 指令描述      | 操作码（首字节） |             |             |           |           |         |         |     |         |         |
| --------- | -------- | ----------- | ----------- | --------- | --------- | ------- | ------- | --- | ------- | ------- |
| write ram | 0x06     | firstAddr_0 | firstAddr_1 | dataCnt_0 | dataCnt_1 | data0_0 | data0_1 | ... | dataX_0 | dataX_1 |
| read ram  | 0x07     | firstAddr_0 | firstAddr_1 | dataCnt_0 | dataCnt_1 | 0x00    | 0x00    | ... | 0x00    | 0x00    |

RAM读写，采用连续传输。

firstAddr，16位，为数据的首地址。（ram大小其实仅为16位*256，8位够了，设计成16位是为了通用性强点，ram深度大点指令也可以兼容，但无疑是牺牲了效率的（一般都无所谓👀））

dataCnt，16位，传输数据的长度。

从首地址开始顺序读写，当数据对应的地址超出RAM上限时，写入无效，读取为0。（判断十分简陋，`fsm_addr_RAM >= RAM_SIZE` ，溢出什么的都没考虑）

### 5.2. 状态机设计

* Moore型三段式状态机（状态很多😰）（原本采用Mealy型，状态是少点，但更加复杂，[点这里查看](https://github.com/themql/FPGA_MCU_SPI_COM/blob/83315b0b244c760d53b684feafe2f4033f946952/essential/Inst_pars/RTL/SPI_instPars_if.v)）

* 状态机的输入为SPI传输的开始与结束标志信号（例如：SPI_Data_begin与SPI_Data_end）

![](README.assert/state_intro.png)

* 状态命名一般为`s_操作码_状态_wait`与 `s_操作码_状态`，前者用于等待传输结束标志的到来，后者则在一个时钟内完成相应操作，然后进入下一个wait状态。

* 写操作使用时序逻辑，读操作使用组合逻辑。注意，写的时序逻辑和读的组合逻辑是以**次态**为准的，写逻辑是为了避免寄存器滞后一拍的影响，读逻辑则是因为SPI模块的读操作时序十分严格，如前所述，需要在`Data_begin`信号拉低前准备好数据，而`Data_begin`信号由只持续一拍。状态机中，是以`Data_begin` 为依据进入读取状态（为SPI模块提供数据的状态，`s_*_readData`），也就是说要在进入读取状态前就将数据准备好，所以要依赖次态。

* 本人觉得基于状态机进行解析还是太复杂了，可拓展性也不是很好，不如直接用软核。（写起来又累又要命，全是重复劳动，强烈推荐VSCode两个插件：better align与Increment Selection，当然还有vim的宏）当然如果您有好想法，欢迎向本仓库提交😊。

#### 5.2.1. 状态跳转简单示意

为简化，在后几幅示意图中：

* 条件不满足时维持原状态的跳转不显示

* wait状态不显示，以在对应状态后添加 **(wait)** 表示。

##### disable 与 enable

```mermaid
stateDiagram-v2
    s_idle      --> s_idle          
    s_idle      --> s_opDect        :transBegin

    s_opDect    --> s_opDect        
    s_opDect    --> s_disable/s_enable       :transEnd
    
    s_disable/s_enable   --> s_idle
```

##### write register

```mermaid
stateDiagram-v2      
    s_idle      --> s_opDect            : transBegin

    s_opDect    --> s_writeReg_getAddr_wait  : transEnd

    s_writeReg_getAddr_wait   --> s_writeReg_getAddr : transEnd

    s_writeReg_getAddr  --> s_writeReg_writeData_0_wait

    s_writeReg_writeData_0_wait --> s_writeReg_writeData_0 : transEnd

    s_writeReg_writeData_0 --> s_writeReg_writeData_1_wait

    s_writeReg_writeData_1_wait --> s_writeReg_writeData_1 : transEnd

    s_writeReg_writeData_1 --> s_idle
```

##### read register

```mermaid
stateDiagram-v2

s_idle --> s_opDect : transBegin

s_opDect --> s_readReg_getAddr_wait : transEnd

s_readReg_getAddr_wait --> s_readReg_getAddr : transEnd

s_readReg_getAddr --> s_readReg_readData_0 : transBegin

s_readReg_readData_0 --> s_readReg_readData_0_wait

s_readReg_readData_0_wait --> s_readReg_readData_1 : transBegin

s_readReg_readData_1 --> s_readReg_readData_1_wait

s_readReg_readData_1_wait --> s_idle : transEnd
```

##### write fifo 与 read fifo

```mermaid
stateDiagram-v2         
    s_idle      --> s_opDect        : transBegin

    s_opDect    --> s_writeFIFO_getCNT_0(wait) : transEnd

    s_writeFIFO_getCNT_0(wait) --> s_writeFIFO_getCNT_1(wait) : transEnd

    s_writeFIFO_getCNT_1(wait) --> s_writeFIFO_decCNT : transEnd

    s_writeFIFO_decCNT --> s_writeFIFO_writeData_0(wait)

    s_writeFIFO_writeData_0(wait) --> s_writeFIFO_writeData_1(wait) : transEnd

    s_writeFIFO_writeData_1(wait) --> s_writeFIFO_decCNT : transEnd && (fsm_cnt != 0)
    s_writeFIFO_writeData_1(wait) --> s_idle : transEnd && (fsm_cnt == 0)
```

##### write ram 与 read ram

```mermaid
stateDiagram        
    s_idle      --> s_opDect        : transBegin

    s_opDect    --> s_writeRAM_getFirstAddr_0(wait) : transEnd

    s_writeRAM_getFirstAddr_0(wait) --> s_writeRAM_getFirstAddr_1(wait) : transEnd

    s_writeRAM_getFirstAddr_1(wait) --> s_writeRAM_getCNT_0(wait) : transEnd

    s_writeRAM_getCNT_0(wait) --> s_writeRAM_getCNT_1(wait) : transEnd

    s_writeRAM_getCNT_1(wait) --> s_writeRAM_setAddrdecCNT : transEnd

    s_writeRAM_setAddrdecCNT --> s_writeRAM_writeData_0(wait)

    s_writeRAM_writeData_0(wait) --> s_writeRAM_writeData_1(wait) : transEnd

    s_writeRAM_writeData_1(wait) --> s_writeRAM_setAddrdecCNT   : transEnd && (fsm_cnt != 0)
    s_writeRAM_writeData_1(wait) --> s_idle               : transEnd && (fsm_cnt == 0)
    note right of s_writeRAM_writeData_1(wait) : addr的自增在此完成
```

## 6. simpleDSP

画个饼先

### 6.1. 结构框图

![](README.assert/diagram_simpleDSP.png)

### 6.2. 寄存器定义

| 地址  | 读写  | 寄存器名      |
| --- | --- | --------- |
| 0   | RW  | ctrl[9:0] |

* [0] en_sclkGen

* [1] en_sample

* [2] en_waveGen

* [3] en_FIR

* [4] wen_sclkGen_coef
  
  系数写使能，写使能有效时对应模块失能（模块使能 = en_模块 & (~ wen_模块系数)）。

* [5] wen_FIR_coef
  
  系数写使能，同上。

* [7:6] mode_sample
  
  * 0：连续采样，仅输出到FIR
  * 1：突发采样(1024点)，仅输出到RAM
  * 2：突发采样(1024点)，仅输出到FIFO
  * 3：突发采样(1024点)，仅输出到RAM与FIFO

* [8] sel_FIR_WaveGen

* [9] en_int：中断使能

| 地址  | 读写  | 寄存器名         |
| --- | --- | ------------ |
| 1   | W   | trigger[2:0] |

* [0] trig_sample： 置1触发一次采样(1024点)，采样结束自动置0
* [1] trig_FFT：    置1触发一次转换(1024点)，转换结束自动置0
* [2] trig_IFFT：   置1触发一次转换(1024点)，转换结束自动置0

| 地址  | 读写  | 寄存器名       |
| --- | --- | ---------- |
| 1   | R   | state[2:0] |

* [0] busy_sample
* [1] busy_FFT
* [2] busy_IFFT

| 地址  | 读写  | 寄存器名            |
| --- | --- | --------------- |
| 2   | R   | fifo_wave_rdata |
|     | W   | fifo_wave_wdata |
| 3   | W   | ram_wave_waddr  |
| 4   | W   | ram_wave_raddr  |
| 5   | R   | ram_wave_rdata  |
|     | W   | ram_wave_wdata  |
| 6   | W   | ram_fre_waddr   |
| 7   | W   | ram_fre_raddr   |
| 8   | R   | ram_fre_rdata   |
|     | W   | ram_fre_wdata   |
| 9   | W   | FIRcoef_waddr   |
| 10  | W   | FIRcoef_raddr   |
| 11  | R   | FIRcoef_rdata   |
|     | W   | FIRcoef_wdata   |

| 地址  | 读写  | 寄存器名                 |
| --- | --- | -------------------- |
| 12  | RW  | sclk_gen_coef[31:16] |
| 13  | RW  | sclk_gen_coef[15:0]  |

sclk_gen_coef：采样时钟生成系数，类似DDS频率控制字

## 7. todo

1. 现在只进行了仿真，还未实际上板验真。mcu驱动也未测试。（所以仅供参考（逃）
2. simpleDSP（有生之年，等 ~~22~~）