// enabled extended mode, Mode A is the default mode for SRAM/PSRAM memory type 
//-------------------------------------
// width addr       16
// width data       16
//-------------------------------------
`define WIDTH_ADDR  (16)
`define WIDTH_DATA  (16)


module design_main_fsmc #(
    parameter sim_present = 0
)(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [`WIDTH_ADDR-1:0]   fsmc_A,
    inout   wire    [`WIDTH_DATA-1:0]   fsmc_D,
    input   wire                        fsmc_NE,
    input   wire                        fsmc_NWE,
    input   wire                        fsmc_NOE
);


wire    [`WIDTH_DATA-1:0]   fsmc_wdata;
wire    [`WIDTH_DATA-1:0]   fsmc_rdata;


// IOBuf
generate
    if(sim_present) begin : simIOBuf
        assign fsmc_wdata = fsmc_D;
        assign fsmc_D     = (!fsmc_NOE) ?fsmc_rdata :{`WIDTH_DATA{1'bz}};
    end
    else begin : FPGAIOBuf
        genvar IOBuf_i;

        for (IOBuf_i = 0; IOBuf_i < `WIDTH_DATA; IOBuf_i = IOBuf_i + 1) begin : Block_FPGAIOBuf
            fpga_IOBuf u_fpga_IOBuf(
                .datain  (fsmc_rdata[IOBuf_i] ),
                .oe      (!fsmc_NOE           ),
                .dataio  (fsmc_D[IOBuf_i]     ),
                .dataout (fsmc_wdata[IOBuf_i] )
            );
        end
    end
endgenerate


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

fsmc_sync_if 
#(
    .p_WIDTH_ADDR ( `WIDTH_ADDR ),
    .p_WIDTH_DATA ( `WIDTH_DATA )
)
u_fsmc_sync_if(
    .clk        (clk        ),
    .rst_n      (rst_n      ),

    .fsmc_A     (fsmc_A     ),
    .fsmc_wdata (fsmc_wdata ),
    .fsmc_rdata (fsmc_rdata ),
    .fsmc_NE    (fsmc_NE    ),
    .fsmc_NWE   (fsmc_NWE   ),
    .fsmc_NOE   (fsmc_NOE   ),

    .addr       (w_addr       ),
    .wdata      (w_wdata      ),
    .rdata      (w_rdata      ),
    .wen        (w_wen        ),
    .ren        (w_ren        )
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
