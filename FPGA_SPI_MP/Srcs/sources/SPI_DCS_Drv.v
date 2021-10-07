// SPI0 Pos沿采样 Neg沿准备数据
module SPI_DCS_Drv #(
    parameter width_cmd  = 8,
    parameter width_data = 16
)
(
    input                       clk,
    input                       rst_n,

    input                       spi_scl,
    input                       spi_sdi,
    output reg                  spi_sdo,
    input                       spi_cs_cmd,
    input                       spi_cs_data,

    input      [width_data-1:0] Din,
    output reg [width_cmd-1 :0] Dcmd,
    output reg [width_data-1:0] Dout,
    output reg                  done_cmd,
    output reg                  done_data
);


reg [width_data-1:0] r_Din;

reg [1:0] r_spi_scl;
wire pos_spi_scl;
wire neg_spi_scl;

reg [1:0] r_spi_cs_cmd;
wire pos_spi_cs_cmd;
wire neg_spi_cs_cmd;
wire en_spi_cs_cmd;

reg [1:0] r_spi_cs_data;
wire pos_spi_cs_data;
wire neg_spi_cs_data;
wire en_spi_cs_data;


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
        r_spi_cs_cmd <= 2'b00;
    else
        r_spi_cs_cmd <= {r_spi_cs_cmd[0], spi_cs_cmd};
end

assign pos_spi_cs_cmd = (!r_spi_cs_cmd[1]) &( r_spi_cs_cmd[0]);
assign neg_spi_cs_cmd = ( r_spi_cs_cmd[1]) &(!r_spi_cs_cmd[0]);
assign en_spi_cs_cmd  = (!r_spi_cs_cmd[1]) &(!r_spi_cs_cmd[0]);

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        r_spi_cs_data <= 2'b00;
    else
        r_spi_cs_data <= {r_spi_cs_data[0], spi_cs_data};
end

assign pos_spi_cs_data = (!r_spi_cs_data[1]) &( r_spi_cs_data[0]);
assign neg_spi_cs_data = ( r_spi_cs_data[1]) &(!r_spi_cs_data[0]);
assign en_spi_cs_data  = (!r_spi_cs_data[1]) &(!r_spi_cs_data[0]);


// receive part
always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        Dcmd <= 0;
    else if(neg_spi_cs_cmd)
        Dcmd <= 0;
    else if(en_spi_cs_cmd)
        if(pos_spi_scl)
            Dcmd[width_cmd-1:0] <= {Dcmd[width_cmd-2:0], spi_sdi};
        else
            Dcmd <= Dcmd;
    else
    Dcmd <= Dcmd;
end

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        done_cmd <= 1'b0;
    else if(pos_spi_cs_cmd)
        done_cmd <= 1'b1;
    else
        done_cmd <= 1'b0;
end

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        Dout <= 0;
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

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
        done_data <= 1'b0;
    else if(pos_spi_cs_data)
        done_data <= 1'b1;
    else
        done_data <= 1'b0;
end


// transmit part
always @(posedge clk , negedge rst_n) begin
    if(!rst_n) begin
        spi_sdo <= 1'b0;
        r_Din <= 0;
    end
    else if(neg_spi_cs_data) begin
        spi_sdo <= r_Din[width_data-1];
        r_Din[width_data-1:0] <= {r_Din[width_data-2:0], 1'b0};
    end
    else if(en_spi_cs_data)
        if(neg_spi_scl) begin
            spi_sdo <= r_Din[width_data-1];
            r_Din[width_data-1:0] <= {r_Din[width_data-2:0], 1'b0};
        end
        else begin
            spi_sdo <= spi_sdo;
            r_Din <= r_Din;
        end
    else begin
        spi_sdo <= spi_sdo;
        r_Din <= Din;
    end
end


endmodule