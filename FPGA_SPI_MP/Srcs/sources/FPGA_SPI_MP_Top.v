module FPGA_SPI_MP_Top (
    input  clk,
    input  rst_n,

    input  spi_scl,
    input  spi_sdi,
    output spi_sdo,
    input  spi_cs_cmd,
    input  spi_cs_data,

    output wire [7:0]  w_cmd,
    output wire [15:0] mo_tmp0,
    output wire [15:0] mo_tmp1,
    output wire [15:0] mo_tmp2,
    output wire [15:0] mo_tmp3,
    output wire [15:0] mo_tmp4,
    output wire [15:0] mo_tmp5,
    output wire [15:0] mo_tmp6,
    output wire [15:0] mo_tmp7
);


// SPI_MP set
parameter width_cmd   = 8;
parameter width_data  = 16;
parameter channel_vaildNum  = 16;
parameter channel_addrWidth = 4;

wire [15:0] mi_tmp0 = 16'h11;
wire [15:0] mi_tmp1 = 16'h22;
wire [15:0] mi_tmp2 = 16'h33;
wire [15:0] mi_tmp3 = 16'h44;
wire [15:0] mi_tmp4 = 16'h55;
wire [15:0] mi_tmp5 = 16'h66;
wire [15:0] mi_tmp6 = 16'h77;
wire [15:0] mi_tmp7 = 16'h88;




SPI_MP_Ctrl 
#(
    .width_cmd   (width_cmd   ),
    .width_data  (width_data  ),
    .channel_vaildNum  (channel_vaildNum ),
    .channel_addrWidth (channel_addrWidth )
)
u_SPI_MP_Ctrl(
    .clk         (clk         ),
    .rst_n       (rst_n       ),

    .spi_scl     (spi_scl     ),
    .spi_sdi     (spi_sdi     ),
    .spi_sdo     (spi_sdo     ),
    .spi_cs_cmd  (spi_cs_cmd  ),
    .spi_cs_data (spi_cs_data ),

    .Dcmd        (w_cmd        ),
    .Din0        (mi_tmp0        ),
    .Din1        (mi_tmp1        ),
    .Din2        (mi_tmp2        ),
    .Din3        (mi_tmp3        ),
    .Din4        (mi_tmp4        ),
    .Din5        (mi_tmp5        ),
    .Din6        (mi_tmp6        ),
    .Din7        (mi_tmp7        ),

    .Dout0       (mo_tmp0       ),
    .Dout1       (mo_tmp1       ),
    .Dout2       (mo_tmp2       ),
    .Dout3       (mo_tmp3       ),
    .Dout4       (mo_tmp4       ),
    .Dout5       (mo_tmp5       ),
    .Dout6       (mo_tmp6       ),
    .Dout7       (mo_tmp7       )
);



endmodule