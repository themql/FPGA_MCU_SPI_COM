// instruction define begin
// disable
// | 0x00     |
// enable
// | 0x01     |
// write register
// | 0x02     | regAddr | regData_0 | regData_1 |
// read register
// | 0x03     | regAddr | 0x00      | 0x00      |
// write fifo
// | 0x04     | dataCnt_0 | dataCnt_1 | data0_0 | data0_1 | ... | dataX_0 | dataX_1 |
// read fifo
// | 0x05     | dataCnt_0 | dataCnt_1 | 0x00    | 0x00    | ... | 0x00    | 0x00    |
// write ram
// | 0x06     | firstAddr_0 | firstAddr_1 | dataCnt_0 | dataCnt_1 | data0_0 | data0_1 | ... | dataX_0 | dataX_1 |
// read ram
// | 0x07     | firstAddr_0 | firstAddr_1 | dataCnt_0 | dataCnt_1 | 0x00    | 0x00    | ... | 0x00    | 0x00    |
// instruction define end

module instPars #(
    parameter spiWidth       = 8,
    parameter isLittleEndian = 1,
    parameter RAM_SIZE       = 256
)
(
    input   wire            clk,
    input   wire            rst_n,

    input   wire    [spiWidth-1:0]  Din,
    output  reg     [spiWidth-1:0]  Dout,
    input   wire                    transBegin,
    input   wire                    transEnd,
    // reg interface
    input   wire    [15:0]  i_sum,
    output  wire    [15:0]  o_num1,
    output  wire    [15:0]  o_num2,
    output  wire    [15:0]  o_num3,
    output  wire            en,
    // fifo interface
    output  reg             fifo_wreq,
    output  reg     [15:0]  fifo_wdata,
    input   wire            fifo_wfull,
    output  reg             fifo_rreq,
    input   wire    [15:0]  fifo_rdata,
    input   wire            fifo_rempty,
    // ram interface
    output  reg             ram_wreq,
    output  reg     [7:0]   ram_waddr,
    output  reg     [15:0]  ram_wdata,
    output  reg     [7:0]   ram_raddr,
    input   wire    [15:0]  ram_rdata
);


localparam op_disable   = 0,
           op_enable    = 1,
           op_writeReg  = 2,
           op_readReg   = 3,
           op_writeFIFO = 4,
           op_readFIFO  = 5,
           op_writeRAM  = 6,
           op_readRAM   = 7;


// user reg addr
localparam regAddr_sum  = 0,
           regAddr_num1 = 1,
           regAddr_num2 = 2,
           regAddr_num3 = 3,
           regAddr_en   = 4;


// user register define
reg     [15:0]      rnum1;
reg     [15:0]      rnum2;
reg     [15:0]      rnum3;
reg                 ren;

assign o_num1 = rnum1;
assign o_num2 = rnum2;
assign o_num3 = rnum3;
assign en     = ren;


// Parsing FSM begin
reg     [7:0]       statec;
reg     [7:0]       staten;

reg     [7:0]       fsm_addr_reg;
reg     [15:0]      fsm_addr_RAM;
reg     [15:0]      fsm_dataHold_reg;
reg     [15:0]      fsm_dataHold_FIFO;
reg     [15:0]      fsm_dataHold_RAM;
reg     [15:0]      fsm_cnt_FIFO;
reg     [15:0]      fsm_cnt_RAM;

localparam s_idle                         = 0,
           s_opDect                       = 1,
           s_disable                      = 2,
           s_enable                       = 3,
           s_writeReg_getAddr_wait        = 4,
           s_writeReg_getAddr             = 5,
           s_writeReg_writeData_0_wait    = 6,
           s_writeReg_writeData_0         = 7,
           s_writeReg_writeData_1_wait    = 8,
           s_writeReg_writeData_1         = 9,
           s_readReg_getAddr_wait         = 10,
           s_readReg_getAddr              = 11,
           s_readReg_readData_0           = 12,
           s_readReg_readData_0_wait      = 13,
           s_readReg_readData_1           = 14,
           s_readReg_readData_1_wait      = 15,
           s_writeFIFO_getCNT_0_wait      = 16,
           s_writeFIFO_getCNT_0           = 17,
           s_writeFIFO_getCNT_1_wait      = 18,
           s_writeFIFO_getCNT_1           = 19,
           s_writeFIFO_decCNT             = 20,
           s_writeFIFO_writeData_0_wait   = 21,
           s_writeFIFO_writeData_0        = 22,
           s_writeFIFO_writeData_1_wait   = 23,
           s_writeFIFO_writeData_1        = 24,
           s_readFIFO_getCNT_0_wait       = 25,
           s_readFIFO_getCNT_0            = 26,
           s_readFIFO_getCNT_1_wait       = 27,
           s_readFIFO_getCNT_1            = 28,
           s_readFIFO_decCNT              = 29,
           s_readFIFO_readData_0          = 30,
           s_readFIFO_readData_0_wait     = 31,
           s_readFIFO_readData_1          = 32,
           s_readFIFO_readData_1_wait     = 33,
           s_writeRAM_getFirstAddr_0_wait = 34,
           s_writeRAM_getFirstAddr_0      = 35,
           s_writeRAM_getFirstAddr_1_wait = 36,
           s_writeRAM_getFirstAddr_1      = 37,
           s_writeRAM_getCNT_0_wait       = 38,
           s_writeRAM_getCNT_0            = 39,
           s_writeRAM_getCNT_1_wait       = 40,
           s_writeRAM_getCNT_1            = 41,
           s_writeRAM_setAddrdecCNT       = 42,
           s_writeRAM_writeData_0_wait    = 43,
           s_writeRAM_writeData_0         = 44,
           s_writeRAM_writeData_1_wait    = 45,
           s_writeRAM_writeData_1         = 46,
           s_readRAM_getFirstAddr_0_wait  = 47,
           s_readRAM_getFirstAddr_0       = 48,
           s_readRAM_getFirstAddr_1_wait  = 49,
           s_readRAM_getFirstAddr_1       = 50,
           s_readRAM_getCNT_0_wait        = 51,
           s_readRAM_getCNT_0             = 52,
           s_readRAM_getCNT_1_wait        = 53,
           s_readRAM_getCNT_1             = 54,
           s_readRAM_setAddrdecCNT        = 55,
           s_readRAM_readData_0           = 56,
           s_readRAM_readData_0_wait      = 57,
           s_readRAM_readData_1           = 58,
           s_readRAM_readData_1_wait      = 59;

// 
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        statec <= s_idle;
    else
        statec <= staten;
end
// nest state
always @(*) begin
    staten = statec;
    case (statec)
        s_idle: 
            if(transBegin)
                staten = s_opDect;
        s_opDect: 
            if(transEnd)
                case (Din)
                    op_disable   : staten = s_disable;
                    op_enable    : staten = s_enable;
                    op_writeReg  : staten = s_writeReg_getAddr_wait;
                    op_readReg   : staten = s_readReg_getAddr_wait;
                    op_writeFIFO : staten = s_writeFIFO_getCNT_0_wait;
                    op_readFIFO  : staten = s_readFIFO_getCNT_0_wait;
                    op_writeRAM  : staten = s_writeRAM_getFirstAddr_0_wait;
                    op_readRAM   : staten = s_readRAM_getFirstAddr_0_wait;
                    default      : staten = s_idle;
                endcase
        s_disable:
            staten = s_idle;
        s_enable:
            staten = s_idle;

        s_writeReg_getAddr_wait:
            if(transEnd)
                staten = s_writeReg_getAddr;
        s_writeReg_getAddr:
            staten = s_writeReg_writeData_0_wait;
        s_writeReg_writeData_0_wait:
            if(transEnd)
                staten = s_writeReg_writeData_0;
        s_writeReg_writeData_0:
            staten = s_writeReg_writeData_1_wait;
        s_writeReg_writeData_1_wait:
            if(transEnd)
                staten = s_writeReg_writeData_1;
        s_writeReg_writeData_1:
            staten = s_idle;

        s_readReg_getAddr_wait:
            if(transEnd)
                staten = s_readReg_getAddr;
        s_readReg_getAddr:
            if(transBegin)
                staten = s_readReg_readData_0;
        s_readReg_readData_0:
            staten = s_readReg_readData_0_wait;
        s_readReg_readData_0_wait:
            if(transBegin)
                staten = s_readReg_readData_1;
        s_readReg_readData_1:
            staten = s_readReg_readData_1_wait;
        s_readReg_readData_1_wait:
            if(transEnd)
                staten = s_idle;

        s_writeFIFO_getCNT_0_wait:
            if(transEnd)
                staten = s_writeFIFO_getCNT_0;
        s_writeFIFO_getCNT_0:
            staten = s_writeFIFO_getCNT_1_wait;
        s_writeFIFO_getCNT_1_wait:
            if(transEnd)
                staten = s_writeFIFO_getCNT_1;
        s_writeFIFO_getCNT_1:
            staten = s_writeFIFO_decCNT;
        s_writeFIFO_decCNT:
            staten = s_writeFIFO_writeData_0_wait;
        s_writeFIFO_writeData_0_wait:
            if(transEnd)
                staten = s_writeFIFO_writeData_0;
        s_writeFIFO_writeData_0:
            staten = s_writeFIFO_writeData_1_wait;
        s_writeFIFO_writeData_1_wait:
            if(transEnd)
                staten = s_writeFIFO_writeData_1;
        s_writeFIFO_writeData_1:
            if(fsm_cnt_FIFO == 'd0)
                staten = s_idle;
            else
                staten = s_writeFIFO_decCNT;

        s_readFIFO_getCNT_0_wait:
            if(transEnd)
                staten = s_readFIFO_getCNT_0;
        s_readFIFO_getCNT_0:
            staten = s_readFIFO_getCNT_1_wait;
        s_readFIFO_getCNT_1_wait:
            if(transEnd)
                staten = s_readFIFO_getCNT_1;
        s_readFIFO_getCNT_1:
            staten = s_readFIFO_decCNT;
        s_readFIFO_decCNT:
            if(transBegin)
                staten = s_readFIFO_readData_0;
        s_readFIFO_readData_0:
            staten = s_readFIFO_readData_0_wait;
        s_readFIFO_readData_0_wait:
            if(transBegin)
                staten = s_readFIFO_readData_1;
        s_readFIFO_readData_1:
            staten = s_readFIFO_readData_1_wait;
        s_readFIFO_readData_1_wait:
            if(transEnd)
                if(fsm_cnt_FIFO == 'd0)
                    staten = s_idle;
                else
                    staten = s_readFIFO_decCNT;

        s_writeRAM_getFirstAddr_0_wait:
            if(transEnd)
                staten = s_writeRAM_getFirstAddr_0;
        s_writeRAM_getFirstAddr_0:
            staten = s_writeRAM_getFirstAddr_1_wait;
        s_writeRAM_getFirstAddr_1_wait:
            if(transEnd)
                staten = s_writeRAM_getFirstAddr_1;
        s_writeRAM_getFirstAddr_1:
            staten = s_writeRAM_getCNT_0_wait;
        s_writeRAM_getCNT_0_wait:
            if(transEnd)
                staten = s_writeRAM_getCNT_0;
        s_writeRAM_getCNT_0:
            staten = s_writeRAM_getCNT_1_wait;
        s_writeRAM_getCNT_1_wait:
            if(transEnd)
                staten = s_writeRAM_getCNT_1;
        s_writeRAM_getCNT_1:
            staten = s_writeRAM_setAddrdecCNT;
        s_writeRAM_setAddrdecCNT:
            staten = s_writeRAM_writeData_0_wait;
        s_writeRAM_writeData_0_wait:
            if(transEnd)
                staten = s_writeRAM_writeData_0;
        s_writeRAM_writeData_0:
            staten = s_writeRAM_writeData_1_wait;
        s_writeRAM_writeData_1_wait:
            if(transEnd)
                staten = s_writeRAM_writeData_1;
        s_writeRAM_writeData_1:
            if(fsm_cnt_RAM == 'd0)
                staten = s_idle;
            else
                staten = s_writeRAM_setAddrdecCNT;

        s_readRAM_getFirstAddr_0_wait:
            if(transEnd)
                staten = s_readRAM_getFirstAddr_0;
        s_readRAM_getFirstAddr_0:
            staten = s_readRAM_getFirstAddr_1_wait;
        s_readRAM_getFirstAddr_1_wait:
            if(transEnd)
                staten = s_readRAM_getFirstAddr_1;
        s_readRAM_getFirstAddr_1:
            staten = s_readRAM_getCNT_0_wait;
        s_readRAM_getCNT_0_wait:
            if(transEnd)
                staten = s_readRAM_getCNT_0;
        s_readRAM_getCNT_0:
            staten = s_readRAM_getCNT_1_wait;
        s_readRAM_getCNT_1_wait:
            if(transEnd)
                staten = s_readRAM_getCNT_1;
        s_readRAM_getCNT_1:
            staten = s_readRAM_setAddrdecCNT;
        s_readRAM_setAddrdecCNT:
            staten = s_readRAM_readData_0_wait;
        s_readRAM_readData_0_wait:
            if(transEnd)
                staten = s_readRAM_readData_0;
        s_readRAM_readData_0:
            staten = s_readRAM_readData_1_wait;
        s_readRAM_readData_1_wait:
            if(transEnd)
                staten = s_readRAM_readData_1;
        s_readRAM_readData_1:
            if(fsm_cnt_RAM == 'd0)
                staten = s_idle;
            else
                staten = s_readRAM_setAddrdecCNT;

        default:
            // staten = s_idle;
            staten = 8'dx; // forDebug
    endcase
end

// FSM output
// reg
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        ren <= 1'd0;
    else if(staten == s_disable)
        ren <= 1'd0;
    else if (staten == s_enable)
        ren <= 1'd1;
    else
        ren <= ren;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        fsm_addr_reg <= 8'd0;
    else if(staten == s_idle)
        fsm_addr_reg <= 8'd0;
    else if(    
        (staten == s_writeReg_getAddr)||
        (staten == s_readReg_getAddr)
    )
        fsm_addr_reg <= Din;
    else
        fsm_addr_reg <= fsm_addr_reg;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        fsm_dataHold_reg <= 16'd0;
    else if(staten == s_idle)
        fsm_dataHold_reg <= 16'd0;
    else if(staten == s_writeReg_writeData_0)
        fsm_dataHold_reg <= {8'd0, Din};
    else if(staten == s_readReg_getAddr)
        case (Din)
            regAddr_sum : fsm_dataHold_reg <= i_sum;
            regAddr_num1: fsm_dataHold_reg <= rnum1;
            regAddr_num2: fsm_dataHold_reg <= rnum2;
            regAddr_num3: fsm_dataHold_reg <= rnum3;
            regAddr_en  : fsm_dataHold_reg <= {15'd0, ren} ;
            default     : fsm_dataHold_reg <= 'd0;
        endcase
    else
        fsm_dataHold_reg <= fsm_dataHold_reg;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        rnum1   <= 16'd0;
        rnum2   <= 16'd0;
        rnum3   <= 16'd0;
    end
    else if(staten == s_writeReg_writeData_1) begin
        if(isLittleEndian)
            case (fsm_addr_reg)
                regAddr_num1: rnum1 <= {Din, fsm_dataHold_reg[7:0]};
                regAddr_num2: rnum2 <= {Din, fsm_dataHold_reg[7:0]};
                regAddr_num3: rnum3 <= {Din, fsm_dataHold_reg[7:0]};
                default     : ;
            endcase
        else
            case (fsm_addr_reg)
                regAddr_num1: rnum1 <= {fsm_dataHold_reg[7:0], Din};
                regAddr_num2: rnum2 <= {fsm_dataHold_reg[7:0], Din};
                regAddr_num3: rnum3 <= {fsm_dataHold_reg[7:0], Din};
                default: ;
            endcase
    end
    else begin
        rnum1 <= rnum1;
        rnum2 <= rnum2;
        rnum3 <= rnum3;
    end
end

// FIFO
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        fsm_dataHold_FIFO <= 16'd0;
    else if(staten == s_idle)
        fsm_dataHold_FIFO <= 16'd0;
    else if(staten == s_writeFIFO_writeData_0)
        fsm_dataHold_FIFO <= {8'd0, Din};
    else
        fsm_dataHold_FIFO <= fsm_dataHold_FIFO;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        fsm_cnt_FIFO <= 16'd0;
    else if(staten == s_idle)
        fsm_cnt_FIFO <= 16'd0;
    else if(
        (staten == s_writeFIFO_getCNT_0)||
        (staten == s_readFIFO_getCNT_0)
    )
        if(isLittleEndian)
            fsm_cnt_FIFO <= {8'd0, Din};
        else
            fsm_cnt_FIFO <= {Din, 8'd0};
    else if(
        (staten == s_writeFIFO_getCNT_1)||
        (staten == s_readFIFO_getCNT_1)
    )
        if(isLittleEndian)
            fsm_cnt_FIFO <= {Din, fsm_cnt_FIFO[7:0]};
        else
            fsm_cnt_FIFO <= {fsm_cnt_FIFO[15:8], Din};
    else if(
        (staten == s_writeFIFO_decCNT)||
        (staten == s_readFIFO_decCNT)
    )
        fsm_cnt_FIFO <= fsm_cnt_FIFO - 'd1;
    else
        fsm_cnt_FIFO <= fsm_cnt_FIFO;
end
// fifo ctrl signal
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        fifo_wreq  <= 1'd0;
        fifo_rreq  <= 1'd0;
        fifo_wdata <= 16'd0;
    end
    else if(staten == s_writeFIFO_writeData_1) begin
        fifo_wreq  <= (fifo_wfull) ?1'd0 :1'd1;
        if(isLittleEndian)
            fifo_wdata <= {Din, fsm_dataHold_FIFO[7:0]};
        else
            fifo_wdata <= {fsm_dataHold_FIFO[7:0], Din};
    end
    else if(staten == s_readFIFO_readData_1)
        fifo_rreq  <= (fifo_rempty) ?1'd0 :1'd1;
    else begin
        fifo_wreq  <= 1'd0;
        fifo_rreq  <= 1'd0;
        fifo_wdata <= 16'd0; 
    end
end

// RAM
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        fsm_addr_RAM <= 16'd0;
    else if(staten == s_idle)
        fsm_addr_RAM <= 16'd0;
    else if(
        (staten == s_writeRAM_getFirstAddr_0)||
        (staten == s_readRAM_getFirstAddr_0)
    )
        if(isLittleEndian)
            fsm_addr_RAM <= {8'd0, Din};
        else
            fsm_addr_RAM <= {Din, 8'd0};
    else if(
        (staten == s_writeRAM_getFirstAddr_1)||
        (staten == s_readRAM_getFirstAddr_1)
    )
        if(isLittleEndian)
            fsm_addr_RAM <= {Din, fsm_addr_RAM[7:0]};
        else
            fsm_addr_RAM <= {fsm_addr_RAM[15:8], Din};
    else if(
        (staten == s_writeRAM_setAddrdecCNT)||
        (staten == s_readRAM_setAddrdecCNT)
    );
    else if(
        (staten == s_writeRAM_writeData_1)||
        (staten == s_readRAM_readData_1)
    )
        fsm_addr_RAM <= fsm_addr_RAM + 'd1;
    else
        fsm_addr_RAM <= fsm_addr_RAM; 
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        fsm_dataHold_RAM <= 16'd0;
    else if(staten == s_idle)
        fsm_dataHold_RAM <= 16'd0;
    else if(staten == s_writeRAM_writeData_0)
        fsm_dataHold_RAM <= {8'd0, Din};
    else
        fsm_dataHold_RAM <= fsm_dataHold_RAM;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        fsm_cnt_RAM <= 16'd0;
    else if(staten == s_idle)
        fsm_cnt_RAM <= 16'd0;
    else if(
        (staten == s_writeRAM_getCNT_0)||
        (staten == s_readRAM_getCNT_0)
    )
        if(isLittleEndian)
            fsm_cnt_RAM <= {8'd0, Din};
        else
            fsm_cnt_RAM <= {Din, 8'd0};
    else if(
        (staten == s_writeRAM_getCNT_1)||
        (staten == s_readRAM_getCNT_1)
    )
        if(isLittleEndian)
            fsm_cnt_RAM <= {Din, fsm_cnt_RAM[7:0]};
        else
            fsm_cnt_RAM <= {fsm_cnt_RAM[15:8], Din};
    else if(
        (staten == s_writeRAM_setAddrdecCNT)||
        (staten == s_readRAM_setAddrdecCNT)
    )
        fsm_cnt_RAM <= fsm_cnt_RAM - 'd1;
    else
        fsm_cnt_RAM <= fsm_cnt_RAM;
end
// RAM ctrl signal
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        ram_waddr <= 8'd0;
        ram_raddr <= 8'd0;
    end
    else if(staten == s_idle) begin
        ram_waddr <= 8'd0;
        ram_raddr <= 8'd0;
    end
    else if(staten == s_writeRAM_setAddrdecCNT)
        ram_waddr <= fsm_addr_RAM[7:0];
    else if(staten == s_readRAM_setAddrdecCNT)
        ram_raddr <= fsm_addr_RAM[7:0];
    else begin
        ram_waddr <= ram_waddr;
        ram_raddr <= ram_raddr;
    end
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        ram_wreq  <= 1'd0;
        ram_wdata <= 16'd0;
    end
    else if(staten == s_writeRAM_writeData_1) begin
        ram_wreq  <= (fsm_addr_RAM >= RAM_SIZE) ?1'd0 :1'd1;
        if(isLittleEndian)
            ram_wdata <= {Din, fsm_dataHold_RAM[7:0]};
        else
            ram_wdata <= {fsm_dataHold_RAM[7:0], Din};
    end
    else begin
        ram_wreq  <= 1'd0;
        ram_wdata <= 16'd0;
    end
end

// read
always @(*) begin
    if(!rst_n)
        Dout = {spiWidth{1'd0}};
    else if(staten == s_readReg_readData_0)
        if(isLittleEndian)
            Dout = fsm_dataHold_reg[7:0];
        else
            Dout = fsm_dataHold_reg[15:8];
    else if(staten == s_readReg_readData_1)
        if(isLittleEndian)
            Dout = fsm_dataHold_reg[15:8];
        else
            Dout = fsm_dataHold_reg[7:0];
    else if(staten == s_readFIFO_readData_0)
        if(isLittleEndian)
            Dout = (fifo_rempty) ?8'd0 :fifo_rdata[7:0];
        else
            Dout = (fifo_rempty) ?8'd0 :fifo_rdata[15:8];
    else if(staten == s_readFIFO_readData_1)
        if(isLittleEndian)
            Dout = (fifo_rempty) ?8'd0 :fifo_rdata[15:8];
        else
            Dout = (fifo_rempty) ?8'd0 :fifo_rdata[7:0];
    else if(staten == s_readRAM_readData_0)
        if(isLittleEndian)
            Dout = (fsm_addr_RAM >= RAM_SIZE) ?8'd0 :ram_rdata[7:0];
        else
            Dout = (fsm_addr_RAM >= RAM_SIZE) ?8'd0 :ram_rdata[15:8];
    else if(staten == s_readRAM_readData_1)
        if(isLittleEndian)
            Dout = (fsm_addr_RAM >= RAM_SIZE) ?8'd0 :ram_rdata[15:8];
        else
            Dout = (fsm_addr_RAM >= RAM_SIZE) ?8'd0 :ram_rdata[7:0];
    else
        Dout = {spiWidth{1'd0}};
end

endmodule
