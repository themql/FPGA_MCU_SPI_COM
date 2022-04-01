module SPI_if (
    input   wire            clk,
    input   wire            rst_n,

    input   wire            spi_scl,
    input   wire            spi_sdi,
    output  wire            spi_sdo,
    input   wire            spi_cs_cmd,
    input   wire            spi_cs_data,
    // reg interface
    input   wire    [15:0]  i_register0,
    output  wire    [15:0]  o_register1,
    output  wire    [15:0]  o_register2,
    output  wire    [15:0]  o_register3,
    // fifo interface
    output  reg             fifo_wreq,
    output  reg     [15:0]  fifo_wdata,
    input   wire            fifo_wfull,
    output  reg             fifo_rreq,
    input   wire    [15:0]  fifo_rdata,
    input   wire            fifo_rempty
);


// spi
localparam  width_cmd   = 8;
localparam  width_data  = 16;

wire    [width_cmd -1:0]    Dcmd;
reg     [width_data-1:0]    Din;
wire    [width_data-1:0]    Dout;
wire                        begin_data;
wire                        end_data;

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
    .begin_data  (begin_data  ),
    .end_data    (end_data    )
);


// user register define
//-------------------------------------
// Programmer's model
// 0    R   register0    sum of register1~3
//              /bit info
// 1    RW  register1
// 2    RW  register2
// 3    RW  register3
// 4    R   register_fifo_r
//      W   register_fifo_w
//-------------------------------------
localparam REGADDR_register0 = 0;
localparam REGADDR_register1 = 1;
localparam REGADDR_register2 = 2;
localparam REGADDR_register3 = 3;
localparam REGADDR_fifo_rdata = 4;
localparam REGADDR_fifo_wdata = 4;

reg     [15:0]      register0;
reg     [15:0]      register1;
reg     [15:0]      register2;
reg     [15:0]      register3;



localparam WRITE_BASE   = 0;
localparam READ_BASE    = (1 << (width_cmd - 1));

// register write
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        register1    <= {width_data{1'b0}};
        register2    <= {width_data{1'b0}};
        register3    <= {width_data{1'b0}};
    end
    else if(end_data) begin
        case (Dcmd)
            (WRITE_BASE + REGADDR_register0) : ;
            (WRITE_BASE + REGADDR_register1) : register1 <= Dout;
            (WRITE_BASE + REGADDR_register2) : register2 <= Dout;
            (WRITE_BASE + REGADDR_register3) : register3 <= Dout;
            default : ;
        endcase
    end
    else ;
end

// register read
always @(*) begin
    if(begin_data) begin
        case (Dcmd)
            (READ_BASE + REGADDR_register0) : Din = register0;
            (READ_BASE + REGADDR_register1) : Din = register1;
            (READ_BASE + REGADDR_register2) : Din = register2;
            (READ_BASE + REGADDR_register3) : Din = register3;
            (READ_BASE + REGADDR_fifo_rdata) : Din = fifo_rdata;
            default : Din = {width_data{1'b0}};
        endcase
    end
    else 
        Din = {width_data{1'b0}};
end


// register interface
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        register0 <= {width_data{1'b0}};
    else
        register0 <= i_register0;
end

assign o_register1 = register1;
assign o_register2 = register2;
assign o_register3 = register3;


// fifo write
always @(*) begin
    if(end_data &&(Dcmd == (WRITE_BASE + REGADDR_fifo_wdata))) begin
        fifo_wreq   = (fifo_wfull) ?1'b0 :1'b1;
        fifo_wdata  = Dout;
    end
    else begin
        fifo_wreq   = 1'b0;
        fifo_wdata  = {width_data{1'b0}};
    end
end


// fifo read
always @(*) begin
    if(begin_data &&(Dcmd == (READ_BASE + REGADDR_fifo_rdata)))
        fifo_rreq = (fifo_rempty) ?1'b0 :1'b1;
    else
        fifo_rreq = 1'b0;
end


endmodule
