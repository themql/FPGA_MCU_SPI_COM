//-------------------------------------
// width addr       8
// width data       16
//-------------------------------------
`define WIDTH_ADDR  (8)
`define WIDTH_DATA  (16)


module design_main_spi #(
    parameter sim_present = 0
)
(
    input   wire            clk,
    input   wire            rst_n,

    input   wire            spi_scl,
    input   wire            spi_sdi,
    output  wire            spi_sdo,
    input   wire            spi_cs_addr,
    input   wire            spi_cs_data
);


wire    [`WIDTH_ADDR-1:0]   w_addr;
wire    [`WIDTH_DATA-1:0]   w_wdata;
wire    [`WIDTH_DATA-1:0]   w_rdata;
wire                        w_wen;
wire                        w_ren;

wire    [15:0]              w_sum_i;
wire    [15:0]              w_num1_o;
wire    [15:0]              w_num2_o;
wire    [15:0]              w_num3_o;
wire                        w_sys_en;

wire                        w_fifo_wreq;
wire    [15:0]              w_fifo_wdata;
wire                        w_fifo_wfull;
wire                        w_fifo_rreq;
wire    [15:0]              w_fifo_rdata;
wire                        w_fifo_rempty;

wire                        w_ram_wreq;
wire    [7:0]               w_ram_waddr;
wire    [15:0]              w_ram_wdata;
wire    [7:0]               w_ram_raddr;
wire    [15:0]              w_ram_rdata;


SPI_DCS_if 
#(
    .width_addr ( `WIDTH_ADDR ),
    .width_data ( `WIDTH_DATA )
)
u_SPI_DCS_if(
    .clk         (clk         ),
    .rst_n       (rst_n       ),

    .spi_scl     (spi_scl     ),
    .spi_sdi     (spi_sdi     ),
    .spi_sdo     (spi_sdo     ),
    .spi_cs_addr (spi_cs_addr ),
    .spi_cs_data (spi_cs_data ),

    .Din         (w_rdata     ),
    .Addr        (w_addr      ),
    .Dout        (w_wdata     ),
    .Data_begin  (w_ren       ),
    .Data_end    (w_wen       )
);


regBank 
#(
    .p_WIDTH_ADDR ( `WIDTH_ADDR ),
    .p_WIDTH_DATA ( `WIDTH_DATA )
)
u_regBank(
    .clk         (clk         ),
    .rst_n       (rst_n       ),

    .addr        (w_addr        ),
    .wdata       (w_wdata       ),
    .rdata       (w_rdata       ),
    .wen         (w_wen         ),
    .ren         (w_ren         ),

    .sum_i       (w_sum_i       ),
    .num1_o      (w_num1_o      ),
    .num2_o      (w_num2_o      ),
    .num3_o      (w_num3_o      ),
    .sys_en      (w_sys_en      ),

    .fifo_wreq   (w_fifo_wreq   ),
    .fifo_wdata  (w_fifo_wdata  ),
    .fifo_wfull  (w_fifo_wfull  ),
    .fifo_rreq   (w_fifo_rreq   ),
    .fifo_rdata  (w_fifo_rdata  ),
    .fifo_rempty (w_fifo_rempty ),

    .ram_wreq    (w_ram_wreq    ),
    .ram_waddr   (w_ram_waddr   ),
    .ram_wdata   (w_ram_wdata   ),
    .ram_raddr   (w_ram_raddr   ),
    .ram_rdata   (w_ram_rdata   )
);



// simple logic sum = num1 + num2 + num3
assign w_sum_i = (w_sys_en) ?(w_num1_o + w_num2_o + w_num3_o) :16'd0;


// fifo
wire        fifo_wrclk;
wire        fifo_wrreq;
wire [15:0] fifo_data;
wire        fifo_wrfull;

wire        fifo_rdclk;
wire        fifo_rdreq;
wire [15:0] fifo_q;
wire        fifo_rdempty;

fpga_fifo u_fpga_fifo(
    .wrclk   (fifo_wrclk   ),
    .wrreq   (fifo_wrreq   ),
    .data    (fifo_data    ),
    .wrfull  (fifo_wrfull  ),

    .rdclk   (fifo_rdclk   ),
    .rdreq   (fifo_rdreq   ),
    .q       (fifo_q       ),
    .rdempty (fifo_rdempty )
);

assign fifo_wrclk       = clk;
assign fifo_wrreq       = (w_sys_en) ?w_fifo_wreq :1'b0;
assign fifo_data        = (w_sys_en) ?w_fifo_wdata :16'd0;
assign w_fifo_wfull     = fifo_wrfull;

assign fifo_rdclk       = clk;
assign fifo_rdreq       = (w_sys_en) ?w_fifo_rreq :1'b0;
assign w_fifo_rdata     = (w_sys_en) ?fifo_q :16'd0;
assign w_fifo_rempty    = fifo_rdempty;


// ram
wire        ram_wrclock;
wire        ram_wren;
wire [7:0]  ram_wraddress;
wire [15:0] ram_data;

wire        ram_rdclock;
wire [7:0]  ram_rdaddress;
wire [15:0] ram_q;

fpga_ram u_fpga_ram(
    .wrclock   (ram_wrclock   ),
    .wren      (ram_wren      ),
    .wraddress (ram_wraddress ),
    .data      (ram_data      ),

    .rdclock   (ram_rdclock   ),
    .rdaddress (ram_rdaddress ),
    .q         (ram_q         )
);

assign ram_wrclock      = clk;
assign ram_wren         = (w_sys_en) ?w_ram_wreq :1'b0;
assign ram_wraddress    = (w_sys_en) ?w_ram_waddr :8'd0;
assign ram_data         = (w_sys_en) ?w_ram_wdata :16'd0;

assign ram_rdclock      = clk;
assign ram_rdaddress    = (w_sys_en) ?w_ram_raddr :8'd0;
assign w_ram_rdata      = (w_sys_en) ?ram_q :16'd0;


endmodule
