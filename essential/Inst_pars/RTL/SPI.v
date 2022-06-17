// SPI mode0 (Posedge sampling, Negedge load data)
module SPI #(
    parameter width = 8
)
(
    input   wire                clk,
    input   wire                rst_n,

    input   wire                spi_scl,
    input   wire                spi_sdi,
    output  reg                 spi_sdo,
    input   wire                spi_sel,

    input   wire    [width-1:0] Din,
    output  reg     [width-1:0] Dout,
    output  reg                 Data_begin,
    output  reg                 Data_end
);


reg     [width-1:0]     r_Din;

reg     [1:0]           r_spi_scl;
wire                    pos_spi_scl;
wire                    neg_spi_scl;

reg     [1:0]           r_spi_sel;
wire                    pos_spi_sel;
wire                    neg_spi_sel;
wire                    en_spi_sel;


// edge detect
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        r_spi_scl <= 2'b00;
        r_spi_sel <= 2'b11;
    end
    else begin
        r_spi_scl <= {r_spi_scl[0], spi_scl};
        r_spi_sel <= {r_spi_sel[0], spi_sel};
    end
end

assign pos_spi_scl = (!r_spi_scl[1]) &( r_spi_scl[0]);
assign neg_spi_scl = ( r_spi_scl[1]) &(!r_spi_scl[0]);
assign pos_spi_sel = (!r_spi_sel[1]) &( r_spi_sel[0]);
assign neg_spi_sel = ( r_spi_sel[1]) &(!r_spi_sel[0]);
assign en_spi_sel  = (!r_spi_sel[1]) &(!r_spi_sel[0]);

always @(*) begin
    Data_begin  = neg_spi_sel;
    Data_end    = pos_spi_sel;
end

// receive part
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        Dout <= {width{1'b0}};
    else if(neg_spi_sel)
        Dout <= {width{1'b0}};
    else if(en_spi_sel)
        if(pos_spi_scl)
            Dout[width-1:0] <= {Dout[width-2:0], spi_sdi};
        else
            Dout <= Dout;
    else
        Dout <= Dout;
end


// transmit part
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        spi_sdo <= 1'b0;
        r_Din   <= {width{1'b0}};
    end
    else if(neg_spi_sel) begin
        spi_sdo <= Din[width-1];
        r_Din   <= {Din[width-2:0], 1'b0};
    end
    else if(en_spi_sel)
        if(neg_spi_scl) begin
            spi_sdo <= r_Din[width-1];
            r_Din   <= {r_Din[width-2:0], 1'b0};
        end
        else begin
            spi_sdo <= spi_sdo;
            r_Din   <= r_Din;
        end
    else begin
        spi_sdo <= 1'b0;
        r_Din   <= {width{1'b0}};
    end
end


endmodule
