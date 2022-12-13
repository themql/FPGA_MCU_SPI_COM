// enabled extended mode, Mode A is the default mode for SRAM/PSRAM memory type 
module fsmc_sync_if #(
    parameter   p_WIDTH_ADDR = 8,
    parameter   p_WIDTH_DATA = 16 
)(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire    [p_WIDTH_ADDR-1:0]  fsmc_A,
    input   wire    [p_WIDTH_DATA-1:0]  fsmc_wdata,
    output  reg     [p_WIDTH_DATA-1:0]  fsmc_rdata,
    input   wire                        fsmc_NE,
    input   wire                        fsmc_NWE,
    input   wire                        fsmc_NOE,

    output  wire    [p_WIDTH_ADDR-1:0]  addr,
    output  wire    [p_WIDTH_DATA-1:0]  wdata,
    input   wire    [p_WIDTH_DATA-1:0]  rdata,
    output  wire                        wen,
    output  wire                        ren
);


assign addr         = fsmc_A;
assign wdata        = fsmc_wdata;

// For ram read operation, the first clock need to load raddr and it's the second clock that can read the data out
// all read operations are delayed by one clock
reg r_ren;

always @(posedge clk) begin
    r_ren <= ren;
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        fsmc_rdata <= {p_WIDTH_DATA{1'b0}};
    end
    else if(r_ren)begin
        fsmc_rdata <= rdata;
    end
    else begin
        fsmc_rdata <= fsmc_rdata;
    end
end


reg [1:0] r_wr;
reg [1:0] r_rd;

// write at the posedge of fsmc_NWE (negedge of r_wr)
// read  at the negedge of fsmc_NOE (posedge of r_rd)
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        r_wr <= 2'b00;
        r_rd <= 2'b00;
    end
    else begin
        r_wr <= {r_wr[0], (!fsmc_NE &&( fsmc_NOE) &&(!fsmc_NWE))};
        r_rd <= {r_rd[0], (!fsmc_NE &&(!fsmc_NOE) &&( fsmc_NWE))};
    end
end

assign wen = ( r_wr[1]) &(!r_wr[0]);
assign ren = (!r_rd[1]) &( r_rd[0]);


endmodule
