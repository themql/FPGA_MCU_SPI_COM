// SPI mode0 (Posedge sampling, Negedge load data)
module SPI_DCS #(
    parameter width_addr = 8,
    parameter width_data = 16
)
(
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire                     spi_scl,
    input  wire                     spi_sdi,
    output reg                      spi_sdo,
    input  wire                     spi_cs_addr,
    input  wire                     spi_cs_data,

    input  wire [width_data-1:0]    Din,
    output reg  [width_addr-1:0]    Addr,
    output reg  [width_data-1:0]    Dout,
    output reg                      Data_begin,
    output reg                      Data_end
);


reg [width_data-1:0] r_Din;

reg     [1:0]   r_spi_scl;
wire            pos_spi_scl;
wire            neg_spi_scl;

reg     [1:0]   r_spi_cs_addr;
wire            pos_spi_cs_addr;
wire            neg_spi_cs_addr;
wire            en_spi_cs_addr;

reg     [1:0]   r_spi_cs_data;
wire            pos_spi_cs_data;
wire            neg_spi_cs_data;
wire            en_spi_cs_data;


// edge detect
always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        r_spi_scl <= 2'b00;
    else
        r_spi_scl <= {r_spi_scl[0], spi_scl};
end

assign pos_spi_scl = (!r_spi_scl[1]) &( r_spi_scl[0]);
assign neg_spi_scl = ( r_spi_scl[1]) &(!r_spi_scl[0]);

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        r_spi_cs_addr <= 2'b00;
    else
        r_spi_cs_addr <= {r_spi_cs_addr[0], spi_cs_addr};
end

assign pos_spi_cs_addr = (!r_spi_cs_addr[1]) &( r_spi_cs_addr[0]);
assign neg_spi_cs_addr = ( r_spi_cs_addr[1]) &(!r_spi_cs_addr[0]);
assign en_spi_cs_addr  = (!r_spi_cs_addr[1]) &(!r_spi_cs_addr[0]);

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        r_spi_cs_data <= 2'b00;
    else
        r_spi_cs_data <= {r_spi_cs_data[0], spi_cs_data};
end

assign pos_spi_cs_data = (!r_spi_cs_data[1]) &( r_spi_cs_data[0]);
assign neg_spi_cs_data = ( r_spi_cs_data[1]) &(!r_spi_cs_data[0]);
assign en_spi_cs_data  = (!r_spi_cs_data[1]) &(!r_spi_cs_data[0]);

always @(*) begin
    Data_begin = neg_spi_cs_data;
    Data_end   = pos_spi_cs_data;
end


// receive part
always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        Addr <= {width_addr{1'b0}};
    else if(neg_spi_cs_addr)
        Addr <= 0;
    else if(en_spi_cs_addr)
        if(pos_spi_scl)
            Addr[width_addr-1:0] <= {Addr[width_addr-2:0], spi_sdi};
        else
            Addr <= Addr;
    else
        Addr <= Addr;
end

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        Dout <= {width_data{1'b0}};
    else if(neg_spi_cs_data)
        Dout <= 0;
    else if(en_spi_cs_data)
        if(pos_spi_scl)
            Dout[width_data-1:0] <= {Dout[width_data-2:0], spi_sdi};
        else
            Dout <= Dout;
    else
        Dout <= Dout;
end


// transmit part
always @(posedge clk , negedge rst_n) begin
    if(!rst_n) begin
        spi_sdo <= 1'b0;
        r_Din   <= {width_data{1'b0}};
    end
    else if(neg_spi_cs_data) begin
        spi_sdo               <= Din[width_data-1];
        r_Din[width_data-1:0] <= {Din[width_data-2:0], 1'b0};
    end
    else if(en_spi_cs_data)
        if(neg_spi_scl) begin
            spi_sdo               <= r_Din[width_data-1];
            r_Din[width_data-1:0] <= {r_Din[width_data-2:0], 1'b0};
        end
        else begin
            spi_sdo <= spi_sdo;
            r_Din   <= r_Din;
        end
    else begin
        spi_sdo <= 1'b0;
        r_Din   <= {width_data{1'b0}};
    end
end


// make verilator happy
wire unused;
assign unused = pos_spi_cs_addr;


endmodule
