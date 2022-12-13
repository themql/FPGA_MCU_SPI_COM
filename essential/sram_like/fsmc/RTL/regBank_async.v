// user register define
// Programmer's model
//-------------------------------------
// 0   R   sum[15:0]     sum of num1~3
// 1   RW  num1[15:0]
// 2   RW  num2[15:0]
// 3   RW  num3[15:0]
// 4   RW  ctrl[0]
//              /0  en
//-------------------------------------
`define ADDR_SUM_ASYNC        0
`define ADDR_NUM1_ASYNC       1
`define ADDR_NUM2_ASYNC       2
`define ADDR_NUM3_ASYNC       3
`define ADDR_CTRL_ASYNC       4
//-------------------------------------


// write at posedge of wen
// read  at high level of ren
module regBank_async #(
    parameter   p_WIDTH_ADDR = 8,
    parameter   p_WIDTH_DATA = 16
)(
    input   wire                        rst_n,
    // register rw interface
    input   wire    [p_WIDTH_ADDR-1:0]  fsmc_A,
    input   wire    [p_WIDTH_DATA-1:0]  fsmc_wdata,
    output  wire    [p_WIDTH_DATA-1:0]  fsmc_rdata,
    input   wire                        fsmc_NE,
    input   wire                        fsmc_NWE,
    input   wire                        fsmc_NOE,
    // register interface
    input   wire    [15:0]              sum_i,
    output  wire    [15:0]              num1_o,
    output  wire    [15:0]              num2_o,
    output  wire    [15:0]              num3_o,
    output  wire                        sys_en
);


//-------------------------------------
// write base addr  0000_0000
// read  base addr  1000_0000
//-------------------------------------
localparam p_BASEADDR_W = 0;
localparam p_BASEADDR_R = (1 << (p_WIDTH_ADDR - 1));


wire [p_WIDTH_ADDR-1:0] addr;
wire [p_WIDTH_DATA-1:0] wdata;
reg  [p_WIDTH_DATA-1:0] rdata;
wire wen;
wire ren;

assign addr         = fsmc_A;
assign wdata        = fsmc_wdata;
assign fsmc_rdata   = rdata;
assign wen          = !fsmc_NE &&( fsmc_NOE) &&(!fsmc_NWE);
assign ren          = !fsmc_NE &&(!fsmc_NOE) &&( fsmc_NWE);


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
            (p_BASEADDR_R + `ADDR_SUM_ASYNC)          : rdata = sum_i;
            (p_BASEADDR_R + `ADDR_NUM1_ASYNC)         : rdata = reg_num1;
            (p_BASEADDR_R + `ADDR_NUM2_ASYNC)         : rdata = reg_num2;
            (p_BASEADDR_R + `ADDR_NUM3_ASYNC)         : rdata = reg_num3;
            (p_BASEADDR_R + `ADDR_CTRL_ASYNC)         : rdata = {15'd0, reg_ctrl};
            default                                   : rdata = {p_WIDTH_DATA{1'b0}};
        endcase
    end
    else begin
        rdata = {p_WIDTH_DATA{1'b0}};
    end
end

// write
always @(negedge wen, negedge rst_n) begin
    if(!rst_n) begin
        reg_num1 <= 16'd0;
        reg_num2 <= 16'd0;
        reg_num3 <= 16'd0;
        reg_ctrl <= 1'b0;
    end
    else begin
        case (addr)
            (p_BASEADDR_W + `ADDR_NUM1_ASYNC) : reg_num1 <= wdata;
            (p_BASEADDR_W + `ADDR_NUM2_ASYNC) : reg_num2 <= wdata;
            (p_BASEADDR_W + `ADDR_NUM3_ASYNC) : reg_num3 <= wdata;
            (p_BASEADDR_W + `ADDR_CTRL_ASYNC) : reg_ctrl <= wdata[0];
            default : ; 
        endcase
    end
end

// out wire
assign num1_o = reg_num1;
assign num2_o = reg_num2;
assign num3_o = reg_num3;
assign sys_en = reg_ctrl;


endmodule
