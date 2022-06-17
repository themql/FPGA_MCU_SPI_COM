module design_main #(
    parameter sim_present = 0
)
(
    input   wire            clk,
    input   wire            rst_n,

    input   wire            spi_scl,
    input   wire            spi_sdi,
    output  wire            spi_sdo,
    input   wire            spi_sel
);


wire [15:0] i_sum;
wire [15:0] o_num1;
wire [15:0] o_num2;
wire [15:0] o_num3;

wire en;

wire            fifo_wreq;
wire [15:0]     fifo_wdata;
wire            fifo_wfull;
wire            fifo_rreq;
wire [15:0]     fifo_rdata;
wire            fifo_rempty;

wire            ram_wreq;
wire [7:0]      ram_waddr;
wire [15:0]     ram_wdata;
wire [7:0]      ram_raddr;
wire [15:0]     ram_rdata;


SPI_instPars_if u_SPI_instPars_if(
    .clk         (clk         ),
    .rst_n       (rst_n       ),

    .spi_scl     (spi_scl     ),
    .spi_sdi     (spi_sdi     ),
    .spi_sdo     (spi_sdo     ),
    .spi_sel     (spi_sel     ),

    .i_sum       (i_sum       ),
    .o_num1      (o_num1      ),
    .o_num2      (o_num2      ),
    .o_num3      (o_num3      ),
    .en          (en          ),

    .fifo_wreq   (fifo_wreq   ),
    .fifo_wdata  (fifo_wdata  ),
    .fifo_wfull  (fifo_wfull  ),
    .fifo_rreq   (fifo_rreq   ),
    .fifo_rdata  ((en) ?fifo_rdata :16'd0 ),
    .fifo_rempty (fifo_rempty ),

    .ram_wreq    (ram_wreq    ),
    .ram_waddr   (ram_waddr   ),
    .ram_wdata   (ram_wdata   ),
    .ram_raddr   (ram_raddr   ),
    .ram_rdata   ((en) ?ram_rdata :16'd0 )
);


assign i_sum = (en) ?o_num1 + o_num2 + o_num3 :16'd0;


// fifo
fpga_fifo u_fpga_fifo(
    .wrclk   (clk         ),
    .wrreq   ((en) ?fifo_wreq  :1'b0  ),
    .data    ((en) ?fifo_wdata :16'd0 ),
    .wrfull  (fifo_wfull  ),

    .rdclk   (clk         ),
    .rdreq   ((en) ?fifo_rreq  :1'b0  ),
    .q       (fifo_rdata  ),
    .rdempty (fifo_rempty )
);


// ram
fpga_ram u_fpga_ram(
    .wrclock   (clk       ),
    .wren      ((en) ?ram_wreq  :1'b0  ),
    .wraddress (ram_waddr ),
    .data      ((en) ?ram_wdata :16'd0 ),

    .rdclock   (clk       ),
    .rdaddress (ram_raddr ),
    .q         (ram_rdata )
);


endmodule
