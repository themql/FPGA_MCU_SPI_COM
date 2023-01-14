// user register define
// Programmer's model
//-------------------------------------
// 0    R   sum[15:0]     sum of num1~3
// 1    RW  num1[15:0]
// 2    RW  num2[15:0]
// 3    RW  num3[15:0]
// 4    R   fifo_r[15:0]
//      W   fifo_w[15:0]
// 5    W   ram_waddr[7:0]
// 6    W   ram_raddr[7:0]
// 7    R   ram_rdata[15:0] 
//      W   ram_wdata[15:0]
// 8    RW  ctrl[0]
//              /0  en
//-------------------------------------
`define ADDR_SUM        0
`define ADDR_NUM1       1
`define ADDR_NUM2       2
`define ADDR_NUM3       3
`define ADDR_fifo_r     4
`define ADDR_fifo_w     4
`define ADDR_ram_waddr  5
`define ADDR_ram_raddr  6
`define ADDR_ram_rdata  7
`define ADDR_ram_wdata  7
`define ADDR_CTRL       8
//-------------------------------------


module regBank #(
    parameter   p_WIDTH_ADDR = 8,
    parameter   p_WIDTH_DATA = 16
)(
    input   wire                        clk,
    input   wire                        rst_n,
    // register rw interface
    input   wire    [p_WIDTH_ADDR-1:0]  addr,
    input   wire    [p_WIDTH_DATA-1:0]  wdata,
    output  reg     [p_WIDTH_DATA-1:0]  rdata,
    input   wire                        wen,
    input   wire                        ren,
    // register interface
    input   wire    [15:0]              sum_i,
    output  wire    [15:0]              num1_o,
    output  wire    [15:0]              num2_o,
    output  wire    [15:0]              num3_o,
    output  wire                        sys_en,
    // fifo interface
    output  reg                         fifo_wreq,
    output  reg     [15:0]              fifo_wdata,
    input   wire                        fifo_wfull,
    output  reg                         fifo_rreq,
    input   wire    [15:0]              fifo_rdata,
    input   wire                        fifo_rempty,
    // ram interface
    output  reg                         ram_wreq,
    output  reg     [7:0]               ram_waddr,
    output  reg     [15:0]              ram_wdata,
    output  reg     [7:0]               ram_raddr,
    input   wire    [15:0]              ram_rdata
);


//-------------------------------------
// write base addr  0000_0000
// read  base addr  1000_0000
//-------------------------------------
localparam p_BASEADDR_W = 0;
localparam p_BASEADDR_R = (1 << (p_WIDTH_ADDR - 1));


// register 
// define
reg     [15:0]      reg_num1;
reg     [15:0]      reg_num2;
reg     [15:0]      reg_num3;
reg                 reg_ctrl;

// read
always @(*) begin
    if(ren) begin
        case (addr)
            (p_BASEADDR_R + `ADDR_SUM)          : rdata = sum_i;
            (p_BASEADDR_R + `ADDR_NUM1)         : rdata = reg_num1;
            (p_BASEADDR_R + `ADDR_NUM2)         : rdata = reg_num2;
            (p_BASEADDR_R + `ADDR_NUM3)         : rdata = reg_num3;
            (p_BASEADDR_R + `ADDR_fifo_r)       : rdata = fifo_rdata;
            (p_BASEADDR_R + `ADDR_ram_rdata)    : rdata = ram_rdata;
            (p_BASEADDR_R + `ADDR_CTRL)         : rdata = {15'd0, reg_ctrl};
            default                             : rdata = {p_WIDTH_DATA{1'b0}};
        endcase
    end
    else begin
        rdata = {p_WIDTH_DATA{1'b0}};
    end
end

// write
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        reg_num1 <= 16'd0;
        reg_num2 <= 16'd0;
        reg_num3 <= 16'd0;
        reg_ctrl <= 1'd0;
    end
    else if(wen) begin
        case (addr)
            (p_BASEADDR_W + `ADDR_NUM1) : reg_num1 <= wdata;
            (p_BASEADDR_W + `ADDR_NUM2) : reg_num2 <= wdata;
            (p_BASEADDR_W + `ADDR_NUM3) : reg_num3 <= wdata;
            (p_BASEADDR_W + `ADDR_CTRL) : reg_ctrl <= wdata[0];
            default : ; 
        endcase
    end
    else ;
end

// out wire
assign num1_o = reg_num1;
assign num2_o = reg_num2;
assign num3_o = reg_num3;
assign sys_en = reg_ctrl;


// fifo
// read
always @(*) begin
    if(ren &&(addr == (p_BASEADDR_R + `ADDR_fifo_r))) begin
        fifo_rreq = (fifo_rempty) ?1'b0 :1'b1;
    end
    else begin
        fifo_rreq = 1'b0;
    end
end

// write
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        fifo_wreq   <= 1'b0;
        fifo_wdata  <= 16'd0;
    end
    else if(wen &&(addr == (p_BASEADDR_W + `ADDR_fifo_w))) begin
        fifo_wreq   <= (fifo_wfull) ?1'b0 :1'b1;
        fifo_wdata  <= wdata;
    end
    else begin
        fifo_wreq   <= 1'b0;
        fifo_wdata  <= 16'd0;
    end
end


// dual port ram
// set addr
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        ram_waddr   <= 8'd0;
        ram_raddr   <= 8'd0;
    end
    else if(wen &&(addr == (p_BASEADDR_W + `ADDR_ram_waddr))) begin
        ram_waddr   <= wdata[7:0];
    end
    else if(wen &&(addr == (p_BASEADDR_W + `ADDR_ram_raddr))) begin
        ram_raddr   <= wdata[7:0];
    end
    else begin
        ram_waddr   <= ram_waddr;
        ram_raddr   <= ram_raddr;
    end
end

// write data
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        ram_wreq    <= 1'b0;
        ram_wdata   <= 16'd0;
    end
    else if(wen &&(addr == (p_BASEADDR_W + `ADDR_ram_wdata))) begin
        ram_wreq    <= 1'b1;
        ram_wdata   <= wdata;
    end
    else begin
        ram_wreq    <= 1'b0;
        ram_wdata   <= 16'd0;
    end
end


endmodule
