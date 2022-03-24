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


wire [15:0] o_reg1;
wire [15:0] o_reg2;
wire [15:0] o_reg3;

SPI_if u_SPI_if(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .spi_scl     (spi_scl     ),
    .spi_sdi     (spi_sdi     ),
    .spi_sdo     (spi_sdo     ),
    .spi_cs_cmd  (spi_cs_cmd  ),
    .spi_cs_data (spi_cs_data ),

    .i_reg0      (o_reg1+o_reg2+o_reg3 ),
    .o_reg1      (o_reg1      ),
    .o_reg2      (o_reg2      ),
    .o_reg3      (o_reg3      )
);


endmodule
