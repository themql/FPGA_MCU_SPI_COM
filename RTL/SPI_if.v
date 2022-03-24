module SPI_if (
    input   wire            clk,
    input   wire            rst_n,

    input   wire            spi_scl,
    input   wire            spi_sdi,
    output  wire            spi_sdo,
    input   wire            spi_cs_cmd,
    input   wire            spi_cs_data,

    input   wire    [15:0]  i_reg0,
    output  wire    [15:0]  o_reg1,
    output  wire    [15:0]  o_reg2,
    output  wire    [15:0]  o_reg3
);


// spi
localparam  width_cmd   = 8;
localparam  width_data  = 16;

wire    [width_cmd -1:0]    Dcmd;
reg     [width_data-1:0]    Din;
wire    [width_data-1:0]    Dout;
wire                        done_cmd;
wire                        done_data;

Drv_SPI 
#(
    .width_cmd  (width_cmd  ),
    .width_data (width_data )
)
u_Drv_SPI(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .spi_scl     (spi_scl     ),
    .spi_sdi     (spi_sdi     ),
    .spi_sdo     (spi_sdo     ),
    .spi_cs_cmd  (spi_cs_cmd  ),
    .spi_cs_data (spi_cs_data ),
    .Din         (Din         ),
    .Dcmd        (Dcmd        ),
    .Dout        (Dout        ),
    .done_cmd    (done_cmd    ),
    .done_data   (done_data   )
);


// user register define
//-------------------------------------
// Programmer's model
// 0    R   reg0    sum of reg1~3
//              /bit info
// 1    RW  reg1
// 2    RW  reg2
// 3    RW  reg3
//-------------------------------------
reg     [15:0]   reg0;
reg     [15:0]   reg1;
reg     [15:0]   reg2;
reg     [15:0]   reg3;


localparam WRITE_BASE   = 0;
localparam READ_BASE    = (1 << (width_cmd - 1));

// register write
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        reg1    <= {width_data{1'b0}};
        reg2    <= {width_data{1'b0}};
        reg3    <= {width_data{1'b0}};
    end
    else if(done_data) begin
        case (Dcmd)
            (WRITE_BASE + 0) : ;
            (WRITE_BASE + 1) : reg1 <= Dout;
            (WRITE_BASE + 2) : reg2 <= Dout;
            (WRITE_BASE + 3) : reg3 <= Dout;
            default: ;
        endcase
    end
    else ;
end

// register read
always @(*) begin
    if(done_cmd) begin
        case (Dcmd)
            (READ_BASE + 0) : Din = reg0;
            (READ_BASE + 1) : Din = reg1;
            (READ_BASE + 2) : Din = reg2;
            (READ_BASE + 3) : Din = reg3;
            default         : Din = {width_data{1'b0}};
        endcase
    end
    else ;
end


// register interface
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        reg0 <= {width_data{1'b0}};
    else
        reg0 <= i_reg0;
end

assign o_reg1 = reg1;
assign o_reg2 = reg2;
assign o_reg3 = reg3;


endmodule
