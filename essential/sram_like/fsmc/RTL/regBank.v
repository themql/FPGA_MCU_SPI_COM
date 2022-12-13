// user register define
// Programmer's model
//-------------------------------------
// 0x0000   R   sum[15:0]     sum of num1~3
// 0x0001   RW  num1[15:0]
// 0x0002   RW  num2[15:0]
// 0x0003   RW  num3[15:0]
// 0x0004   RW  ctrl[0]
//              /0  en
// 0x0005   RW  fifo_data[15:0]
// 0x0100   RW  ram_data[15:0]
// |
// 0x01FF   
//-------------------------------------
`define ADDR_SUM        0
`define ADDR_NUM1       1
`define ADDR_NUM2       2
`define ADDR_NUM3       3
`define ADDR_CTRL       4
`define ADDR_fifo_data  5
`define ADDR_ram_data_b 16'h0100
`define ADDR_ram_data_e 16'h01FF
//-------------------------------------


module regBank #(
    parameter   p_WIDTH_ADDR = 16,
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


// For ram read operation, the first clock need to load raddr and it's the second clock that can read the data out
// all read operations are delayed by one clock
reg r_ren;

always @(posedge clk) begin
    r_ren <= ren;
end


// register 
// define
reg     [15:0]      reg_num1;
reg     [15:0]      reg_num2;
reg     [15:0]      reg_num3;
reg                 reg_ctrl;

// read
always @(*) begin
    if(r_ren) begin
        if((addr >= `ADDR_ram_data_b) &&(addr <= `ADDR_ram_data_e)) begin
            rdata = ram_rdata;
        end
        else begin
            case (addr)
                (`ADDR_SUM)         : rdata = sum_i;
                (`ADDR_NUM1)        : rdata = reg_num1;
                (`ADDR_NUM2)        : rdata = reg_num2;
                (`ADDR_NUM3)        : rdata = reg_num3;
                (`ADDR_CTRL)        : rdata = {15'd0, reg_ctrl};
                (`ADDR_fifo_data)   : rdata = fifo_rdata;
                default             : rdata = {p_WIDTH_DATA{1'b0}};
            endcase
        end
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
            (`ADDR_NUM1) : reg_num1 <= wdata;
            (`ADDR_NUM2) : reg_num2 <= wdata;
            (`ADDR_NUM3) : reg_num3 <= wdata;
            (`ADDR_CTRL) : reg_ctrl <= wdata[0];
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
    if(r_ren &&(addr == (`ADDR_fifo_data))) begin
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
    else if(wen &&(addr == (`ADDR_fifo_data))) begin
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
always @(*) begin
    if(!rst_n) begin
        ram_waddr   = 8'd0;
        ram_raddr   = 8'd0;
    end
    else if(wen &&((addr >= `ADDR_ram_data_b) &&(addr <= `ADDR_ram_data_e))) begin
        ram_waddr   = addr[7:0];
    end
    else if(ren &&((addr >= `ADDR_ram_data_b) &&(addr <= `ADDR_ram_data_e))) begin
        ram_raddr   = addr[7:0];
    end
    else begin
        ram_waddr   = ram_waddr;
        ram_raddr   = ram_raddr;
    end
end

// write data
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        ram_wreq    <= 1'b0;
        ram_wdata   <= 16'd0;
    end
    else if(wen &&((addr >= `ADDR_ram_data_b) &&(addr <= `ADDR_ram_data_e))) begin
        ram_wreq    <= 1'b1;
        ram_wdata   <= wdata;
    end
    else begin
        ram_wreq    <= 1'b0;
        ram_wdata   <= 16'd0;
    end
end


endmodule
