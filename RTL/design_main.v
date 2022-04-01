module design_main #(
    parameter sim_present = 0
)
(
    input   wire            clk,
    input   wire            rst_n,

    input   wire            spi_scl,
    input   wire            spi_sdi,
    output  wire            spi_sdo,
    input   wire            spi_cs_cmd,
    input   wire            spi_cs_data
);


wire [15:0] i_register0;
wire [15:0] o_register1;
wire [15:0] o_register2;
wire [15:0] o_register3;

wire            fifo_wreq;
wire [15:0]     fifo_wdata;
wire            fifo_wfull;
wire            fifo_rreq;
wire [15:0]     fifo_rdata;
wire            fifo_rempty;

wire            ram_wreq;
wire [6:0]      ram_waddr;
wire [15:0]     ram_wdata;
wire [6:0]      ram_raddr;
wire [15:0]     ram_rdata;


SPI_if u_SPI_if(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .spi_scl     (spi_scl     ),
    .spi_sdi     (spi_sdi     ),
    .spi_sdo     (spi_sdo     ),
    .spi_cs_cmd  (spi_cs_cmd  ),
    .spi_cs_data (spi_cs_data ),

    .i_register0 (i_register0 ),
    .o_register1 (o_register1 ),
    .o_register2 (o_register2 ),
    .o_register3 (o_register3 ),

    .fifo_wreq   (fifo_wreq   ),
    .fifo_wdata  (fifo_wdata  ),
    .fifo_wfull  (fifo_wfull  ),
    .fifo_rreq   (fifo_rreq   ),
    .fifo_rdata  (fifo_rdata  ),
    .fifo_rempty (fifo_rempty ),

    .ram_wreq    (ram_wreq    ),
    .ram_waddr   (ram_waddr   ),
    .ram_wdata   (ram_wdata   ),
    .ram_raddr   (ram_raddr   ),
    .ram_rdata   (ram_rdata   )
);


assign i_register0 = o_register1 + o_register2 + o_register3;


// fifo
fpga_fifo u_fpga_fifo(
    .wrclk   (clk         ),
    .wrreq   (fifo_wreq   ),
    .data    (fifo_wdata  ),
    .wrfull  (fifo_wfull  ),

    .rdclk   (clk         ),
    .rdreq   (fifo_rreq   ),
    .q       (fifo_rdata  ),
    .rdempty (fifo_rempty )
);


// ram
fpga_ram u_fpga_ram(
    .wrclock   (clk       ),
    .wren      (ram_wreq  ),
    .wraddress (ram_waddr ),
    .data      (ram_wdata ),

    .rdclock   (clk       ),
    .rdaddress (ram_raddr ),
    .q         (ram_rdata )
);


endmodule
