module SPI_MP_Ctrl #(
    parameter width_cmd   = 8,
    parameter width_data  = 16,
    parameter space_max   = 16,
    parameter space_width = 4
)
(
    input  clk,
    input  rst_n,

    input  spi_scl,
    input  spi_sdi,
    output spi_sdo,
    input  spi_cs_cmd,
    input  spi_cs_data,

    output reg [width_cmd-1:0] Dcmd,

    input  [width_data-1:0] Din0,
    input  [width_data-1:0] Din1,
    input  [width_data-1:0] Din2,
    input  [width_data-1:0] Din3,
    input  [width_data-1:0] Din4,
    input  [width_data-1:0] Din5,
    input  [width_data-1:0] Din6,
    input  [width_data-1:0] Din7,

    output reg [width_data-1:0] Dout0,
    output reg [width_data-1:0] Dout1,
    output reg [width_data-1:0] Dout2,
    output reg [width_data-1:0] Dout3,
    output reg [width_data-1:0] Dout4,
    output reg [width_data-1:0] Dout5,
    output reg [width_data-1:0] Dout6,
    output reg [width_data-1:0] Dout7
);


wire [width_cmd -1:0] w_spi_Dcmd;
wire [width_data-1:0] w_spi_Dout;
wire w_spi_done_cmd;
wire w_spi_done_data;

reg  [width_data-1:0] r_Transmit;


// load Dcmd always
always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        Dcmd <= 0;
    else
        Dcmd <= w_spi_Dcmd;
end


// load r_Transmit at done_cmd
always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        r_Transmit <= 0;
    else if(w_spi_done_cmd) begin
        case (Dcmd[space_width-1:0])
            0 : r_Transmit <= Din0;
            1 : r_Transmit <= Din1;
            2 : r_Transmit <= Din2;
            3 : r_Transmit <= Din3;
            4 : r_Transmit <= Din4;
            5 : r_Transmit <= Din5;
            6 : r_Transmit <= Din6;
            7 : r_Transmit <= Din7;
            default: r_Transmit <= 0;
        endcase
    end
    else begin
        r_Transmit <= r_Transmit;
    end
end

// load DoutX at done_data
always @(posedge clk , negedge rst_n) begin
    if(!rst_n) begin
        Dout0 <= 0;
        Dout1 <= 0;
        Dout2 <= 0;
        Dout3 <= 0;
        Dout4 <= 0;
        Dout5 <= 0;
        Dout6 <= 0;
        Dout7 <= 0;
    end
    else if(w_spi_done_data) begin
        case (Dcmd[space_width-1:0])
            8 : Dout0 <= w_spi_Dout;
            9 : Dout1 <= w_spi_Dout;
            10: Dout2 <= w_spi_Dout;
            11: Dout3 <= w_spi_Dout;
            12: Dout4 <= w_spi_Dout;
            13: Dout5 <= w_spi_Dout;
            14: Dout6 <= w_spi_Dout;
            15: Dout7 <= w_spi_Dout;
            default: begin
                Dout0 <= Dout0;
                Dout1 <= Dout1;
                Dout2 <= Dout2;
                Dout3 <= Dout3;
                Dout4 <= Dout4;
                Dout5 <= Dout5;
                Dout6 <= Dout6;
                Dout7 <= Dout7;
            end
        endcase
    end
    else begin
        Dout0 <= Dout0;
        Dout1 <= Dout1;
        Dout2 <= Dout2;
        Dout3 <= Dout3;
        Dout4 <= Dout4;
        Dout5 <= Dout5;
        Dout6 <= Dout6;
        Dout7 <= Dout7;
    end
end


// SPI_Drv
SPI_DCS_Drv 
#(
    .width_cmd  (width_cmd  ),
    .width_data (width_data )
)
u_SPI_DCS_Drv(
    .clk         (clk         ),
    .rst_n       (rst_n       ),

    .spi_scl     (spi_scl     ),
    .spi_sdi     (spi_sdi     ),
    .spi_sdo     (spi_sdo     ),
    .spi_cs_cmd  (spi_cs_cmd  ),
    .spi_cs_data (spi_cs_data ),

    .Din         (r_Transmit        ),
    .Dcmd        (w_spi_Dcmd        ),
    .Dout        (w_spi_Dout        ),
    .done_cmd    (w_spi_done_cmd    ),
    .done_data   (w_spi_done_data   )
);

    
endmodule