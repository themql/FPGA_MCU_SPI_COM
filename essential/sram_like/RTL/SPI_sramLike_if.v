// user register define
// Programmer's model
//-------------------------------------
// width addr       8
// width data       16
// write base addr  0
// read  base addr  128
//-------------------------------------
`define WIDTH_ADDR  (8)
`define WIDTH_DATA  (16)
`define WRITE_BASE  (0)
`define READ_BASE   (1 << (`WIDTH_ADDR - 1))
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

module SPI_sramLike_if (
    input   wire            clk,
    input   wire            rst_n,

    input   wire            spi_scl,
    input   wire            spi_sdi,
    output  wire            spi_sdo,
    input   wire            spi_cs_addr,
    input   wire            spi_cs_data,
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


// spi_dcs
wire    [`WIDTH_ADDR-1:0]   SPI_Addr;
reg     [`WIDTH_DATA-1:0]   SPI_Din;
wire    [`WIDTH_DATA-1:0]   SPI_Dout;
wire                        SPI_Data_begin;
wire                        SPI_Data_end;

SPI_DCS #(
    .width_addr (`WIDTH_ADDR ),
    .width_data (`WIDTH_DATA )
)
u_SPI_DCS(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .spi_scl     (spi_scl     ),
    .spi_sdi     (spi_sdi     ),
    .spi_sdo     (spi_sdo     ),
    .spi_cs_addr (spi_cs_addr ),
    .spi_cs_data (spi_cs_data ),
    .Din         (SPI_Din         ),
    .Addr        (SPI_Addr        ),
    .Dout        (SPI_Dout        ),
    .Data_begin  (SPI_Data_begin  ),
    .Data_end    (SPI_Data_end    )
);


// register define
reg     [15:0]      rnum1;
reg     [15:0]      rnum2;
reg     [15:0]      rnum3;
reg                 rctrl;


// read
always @(*) begin
    if(SPI_Data_begin) begin
        case (SPI_Addr)
            (`READ_BASE + `ADDR_SUM)  : SPI_Din = i_sum;
            (`READ_BASE + `ADDR_NUM1) : SPI_Din = rnum1;
            (`READ_BASE + `ADDR_NUM2) : SPI_Din = rnum2;
            (`READ_BASE + `ADDR_NUM3) : SPI_Din = rnum3;
            (`READ_BASE + `ADDR_fifo_r) : SPI_Din     = fifo_rdata;
            (`READ_BASE + `ADDR_ram_rdata) : SPI_Din = ram_rdata;
            (`READ_BASE + `ADDR_CTRL) : SPI_Din = {15'd0, rctrl};
            default : SPI_Din = {`WIDTH_DATA{1'b0}};
        endcase
    end
    else 
        SPI_Din = {`WIDTH_DATA{1'b0}};
end


// register write
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        rnum1    <= 16'd0;
        rnum2    <= 16'd0;
        rnum3    <= 16'd0;
        rctrl    <= 1'd0;
    end
    else if(SPI_Data_end) begin
        case (SPI_Addr)
            (`WRITE_BASE + `ADDR_NUM1) : rnum1 <= SPI_Dout;
            (`WRITE_BASE + `ADDR_NUM2) : rnum2 <= SPI_Dout;
            (`WRITE_BASE + `ADDR_NUM3) : rnum3 <= SPI_Dout;
            (`WRITE_BASE + `ADDR_CTRL) : rctrl <= SPI_Dout[0];
            default : ;
        endcase
    end
    else ;
end

// register interface
assign o_num1 = rnum1;
assign o_num2 = rnum2;
assign o_num3 = rnum3;
assign en     = rctrl;


// fifo write
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        fifo_wreq   <= 1'b0;
        fifo_wdata  <= 16'd0;
    end
    else if(SPI_Data_end &&(SPI_Addr == (`WRITE_BASE + `ADDR_fifo_w))) begin
        fifo_wreq   <= (fifo_wfull) ?1'b0 :1'b1;
        fifo_wdata  <= SPI_Dout;
    end
    else begin
        fifo_wreq   <= 1'b0;
        fifo_wdata  <= 16'd0;
    end
end

// fifo read
always @(*) begin
    if(SPI_Data_begin &&(SPI_Addr == (`READ_BASE + `ADDR_fifo_r))) begin
        fifo_rreq = (fifo_rempty) ?1'b0 :1'b1;
    end
    else begin
        fifo_rreq = 1'b0;
    end
end


// ram addr
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        ram_waddr   <= 8'd0;
        ram_raddr   <= 8'd0;
    end
    else if(SPI_Data_end &&(SPI_Addr == (`WRITE_BASE + `ADDR_ram_waddr))) begin
        ram_waddr   <= SPI_Dout[7:0];
    end
    else if(SPI_Data_end &&(SPI_Addr == (`WRITE_BASE + `ADDR_ram_raddr))) begin
        ram_raddr   <= SPI_Dout[7:0];
    end
    else begin
        ram_waddr   <= ram_waddr;
        ram_raddr   <= ram_raddr;
    end
end

// ram write
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        ram_wreq    <= 1'b0;
        ram_wdata   <= 16'd0;
    end
    else if(SPI_Data_end &&(SPI_Addr == (`WRITE_BASE + `ADDR_ram_wdata))) begin
        ram_wreq    <= 1'b1;
        ram_wdata   <= SPI_Dout;
    end
    else begin
        ram_wreq    <= 1'b0;
        ram_wdata   <= 16'd0;
    end
end


endmodule
