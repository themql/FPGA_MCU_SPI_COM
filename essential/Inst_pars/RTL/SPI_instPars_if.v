`define WIDTH   (8)
// disable
// 00
// enable
// 01
// write register
// 02   regAddr     regData_0   regData_1
// read register
// 03   regAddr     00          00
// write fifo
// 04   dataCnt_0   dataCnt_1   data0_0     data0_1     ...         dataX_0     dataX_1
// read fifo
// 05   dataCnt_0   dataCnt_1   00          00          ...         00          00
// write ram
// 06   firstAddr   dataCnt_0   dataCnt_1   data0_0     data0_1     ...         dataX_0     dataX_1
// read ram
// 07   firstAddr   dataCnt_0   dataCnt_1   00          00          ...         00          00
`define OP_DISABLE      (0)
`define OP_ENABLE       (1)
`define OP_WRITEREG     (2)
`define OP_READREG      (3)
`define OP_WRITEFIFO    (4)
`define OP_READFIFO     (5)
`define OP_WRITERAM     (6)
`define OP_READRAM      (7)

`define REGADDR_sum     (0)
`define REGADDR_num1    (1)
`define REGADDR_num2    (2)
`define REGADDR_num3    (3)
`define REGADDR_en      (4)


module SPI_instPars_if #(
    parameter RAM_SIZE  = 256    
)
(
    input   wire            clk,
    input   wire            rst_n,

    input   wire            spi_scl,
    input   wire            spi_sdi,
    output  wire            spi_sdo,
    input   wire            spi_sel,
    // reg interface
    input   wire    [15:0]  i_sum,
    output  wire    [15:0]  o_num1,
    output  wire    [15:0]  o_num2,
    output  wire    [15:0]  o_num3,
    output  wire            en,
    // fifo interface
    output  reg             fifo_wreq,
    output  reg     [15:0]  fifo_wdata,
    input   wire            fifo_wfull,
    output  reg             fifo_rreq,
    input   wire    [15:0]  fifo_rdata,
    input   wire            fifo_rempty,
    // ram interface
    output  reg             ram_wreq,
    output  reg     [7:0]   ram_waddr,
    output  reg     [15:0]  ram_wdata,
    output  reg     [7:0]   ram_raddr,
    input   wire    [15:0]  ram_rdata
);


// SPI
reg     [`WIDTH-1:0]    SPI_Din;
wire    [`WIDTH-1:0]    SPI_Dout;
wire                    SPI_Data_begin;
wire                    SPI_Data_end;

SPI #(
    .width (`WIDTH )
)
u_SPI(
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .spi_scl    (spi_scl    ),
    .spi_sdi    (spi_sdi    ),
    .spi_sdo    (spi_sdo    ),
    .spi_sel    (spi_sel    ),
    .Din        (SPI_Din        ),
    .Dout       (SPI_Dout       ),
    .Data_begin (SPI_Data_begin ),
    .Data_end   (SPI_Data_end   )
);

// register define
reg     [15:0]      rnum1;
reg     [15:0]      rnum2;
reg     [15:0]      rnum3;
reg                 ren;

assign o_num1 = rnum1;
assign o_num2 = rnum2;
assign o_num3 = rnum3;
assign en = ren;

// parsing FSM
reg     [7:0]       state_c;
reg     [7:0]       state_n;

reg     [15:0]      fsm_addr;
reg     [15:0]      fsm_data;
reg     [15:0]      fsm_cnt;

localparam  s_idle                  = 0,
            s_opDect                = 1,

            s_disable               = 5,
            s_enable                = 6,

            s_writeReg_getAddr      = 10,
            s_writeReg_writeData_0  = 11,
            s_writeReg_writeData_1  = 12,

            s_readReg_getAddr       = 20,
            s_readReg_readData_0    = 21,
            s_readReg_readData_1    = 22,

            s_writeFIFO_getCNT_0    = 30,
            s_writeFIFO_getCNT_1    = 31,
            s_writeFIFO_writeData_0 = 32,
            s_writeFIFO_writeData_1 = 33,

            s_readFIFO_getCNT_0     = 40,
            s_readFIFO_getCNT_1     = 41,
            s_readFIFO_readData_0   = 42,
            s_readFIFO_readData_1   = 43,

            s_writeRAM_getFirstAddr = 50,
            s_writeRAM_getCNT_0     = 51,
            s_writeRAM_getCNT_1     = 52,
            s_writeRAM_setAddr      = 53,
            s_writeRAM_writeData_0  = 54,
            s_writeRAM_writeData_1  = 55,

            s_readRAM_getFirstAddr  = 60,
            s_readRAM_getCNT_0      = 61,
            s_readRAM_getCNT_1      = 62,
            s_readRAM_setAddr       = 63,
            s_readRAM_readData_0    = 64,
            s_readRAM_readData_1    = 65;


always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
        state_c <= s_idle;
    else
        state_c <= state_n;
end

always @(*) begin
    case (state_c)
        s_idle                  : begin
            if(SPI_Data_begin)
                state_n = s_opDect;
            else
                state_n = state_c;
        end
        s_opDect                : begin
            if(SPI_Data_end)
                case (SPI_Dout)
                    `OP_DISABLE     : state_n = s_disable; 
                    `OP_ENABLE      : state_n = s_enable;
                    `OP_WRITEREG    : state_n = s_writeReg_getAddr;
                    `OP_READREG     : state_n = s_readReg_getAddr;
                    `OP_WRITEFIFO   : state_n = s_writeFIFO_getCNT_0;
                    `OP_READFIFO    : state_n = s_readFIFO_getCNT_0;
                    `OP_WRITERAM    : state_n = s_writeRAM_getFirstAddr;
                    `OP_READRAM     : state_n = s_readRAM_getFirstAddr;
                    default         : state_n = s_idle; 
                endcase
            else
                state_n = state_c;
        end

        s_disable               : begin
            state_n = s_idle;
        end
        s_enable                : begin
            state_n = s_idle;
        end

        s_writeReg_getAddr      : begin
            if(SPI_Data_end)
                state_n = s_writeReg_writeData_0;
            else
                state_n = state_c;
        end
        s_writeReg_writeData_0  : begin
            if(SPI_Data_end)
                state_n = s_writeReg_writeData_1;
            else
                state_n = state_c;
        end
        s_writeReg_writeData_1  : begin
            if(SPI_Data_end)
                state_n = s_idle;
            else
                state_n = state_c;
        end

        s_readReg_getAddr       : begin
            if(SPI_Data_end)
                state_n = s_readReg_readData_0;
            else
                state_n = state_c;
        end
        s_readReg_readData_0    : begin
            if(SPI_Data_end)
                state_n = s_readReg_readData_1;
            else
                state_n = state_c;
        end
        s_readReg_readData_1    : begin
            if(SPI_Data_end)
                state_n = s_idle;
            else
                state_n = state_c;
        end

        s_writeFIFO_getCNT_0    : begin
            if(SPI_Data_end)
                state_n = s_writeFIFO_getCNT_1;
            else
                state_n = state_c;
        end
        s_writeFIFO_getCNT_1    : begin
            if(SPI_Data_end)
                state_n = s_writeFIFO_writeData_0;
            else
                state_n = state_c;
        end
        s_writeFIFO_writeData_0 : begin
            if(SPI_Data_end)
                state_n = s_writeFIFO_writeData_1;
            else
                state_n = state_c;
        end
        s_writeFIFO_writeData_1 : begin
            if(SPI_Data_end)
                if(fsm_cnt == 1)
                    state_n = s_idle;
                else
                    state_n = s_writeFIFO_writeData_0;
            else
                state_n = state_c;
        end

        s_readFIFO_getCNT_0     : begin
            if(SPI_Data_end)
                state_n = s_readFIFO_getCNT_1;
            else
                state_n = state_c;
        end
        s_readFIFO_getCNT_1     : begin
            if(SPI_Data_end)
                state_n = s_readFIFO_readData_0;
            else
                state_n = state_c;
        end
        s_readFIFO_readData_0   : begin
            if(SPI_Data_end)
                state_n = s_readFIFO_readData_1;
            else
                state_n = state_c;
        end
        s_readFIFO_readData_1   : begin
            if(SPI_Data_end)
                if(fsm_cnt == 1)
                    state_n = s_idle;
                else
                    state_n = s_readFIFO_readData_0;
            else
                state_n = state_c;
        end

        s_writeRAM_getFirstAddr : begin
            if(SPI_Data_end)
                state_n = s_writeRAM_getCNT_0;
            else
                state_n = state_c;
        end
        s_writeRAM_getCNT_0     : begin
            if(SPI_Data_end)
                state_n = s_writeRAM_getCNT_1;
            else
                state_n = state_c;
        end
        s_writeRAM_getCNT_1     : begin
            if(SPI_Data_end)
                state_n = s_writeRAM_setAddr;
            else
                state_n = state_c;
        end
        s_writeRAM_setAddr      : begin
            state_n = s_writeRAM_writeData_0;
        end
        s_writeRAM_writeData_0  : begin
            if(SPI_Data_end)
                state_n = s_writeRAM_writeData_1;
            else
                state_n = state_c;
        end
        s_writeRAM_writeData_1  : begin
            if(SPI_Data_end)
                if(fsm_cnt == 1)
                    state_n = s_idle;
                else
                    state_n = s_writeRAM_setAddr;
            else
                state_n = state_c;
        end

        s_readRAM_getFirstAddr  : begin
            if(SPI_Data_end)
                state_n = s_readRAM_getCNT_0;
            else
                state_n = state_c;
        end
        s_readRAM_getCNT_0      : begin
            if(SPI_Data_end)
                state_n = s_readRAM_getCNT_1;
            else
                state_n = state_c;
        end
        s_readRAM_getCNT_1      : begin
            if(SPI_Data_end)
                state_n = s_readRAM_readData_0;
            else
                state_n = state_c;
        end
        s_readRAM_setAddr       : begin
            state_n = s_readRAM_readData_0;
        end
        s_readRAM_readData_0    : begin
            if(SPI_Data_end)
                state_n = s_readRAM_readData_1;
            else
                state_n = state_c;
        end
        s_readRAM_readData_1    : begin
            if(SPI_Data_end)
                if(fsm_cnt == 1)
                    state_n = s_idle;
                else
                    state_n = s_readRAM_setAddr;
            else
                state_n = state_c;
        end
        default: state_n = s_idle;
    endcase
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        rnum1   <= 16'd0;
        rnum2   <= 16'd0;
        rnum3   <= 16'd0;
        ren     <= 1'd0;

        fifo_wreq   <= 1'b0;
        fifo_wdata  <= 16'd0;

        ram_wreq    <= 1'b0;
        ram_waddr   <= 8'd0;
        ram_wdata   <= 16'd0;
        ram_raddr   <= 8'd0;

        fsm_addr    <= 16'd0;
        fsm_data    <= 16'd0;
        fsm_cnt     <= 16'd0;
    end
    else begin
        case (state_c)
            s_idle                  : begin
                fifo_wreq   <= 1'b0;
                fifo_wdata  <= 16'd0;

                ram_wreq    <= 1'b0;
                ram_waddr   <= 8'd0;
                ram_wdata   <= 16'd0;
                ram_raddr   <= 8'd0;

                fsm_addr    <= 16'd0;
                fsm_data    <= 16'd0;
                fsm_cnt     <= 16'd0;
            end
            s_opDect                : begin
            end

            s_disable               : begin
                ren <= 1'b0;
            end
            s_enable                : begin
                ren <= 1'b1;
            end

            s_writeReg_getAddr      : begin
                if(SPI_Data_end)
                    fsm_addr <= {8'd0, SPI_Dout};
            end
            s_writeReg_writeData_0  : begin
                if(SPI_Data_end)
                    fsm_data[15:8] <= SPI_Dout;
            end
            s_writeReg_writeData_1  : begin
                if(SPI_Data_end)
                    case (fsm_addr)
                        `REGADDR_num1   : rnum1 <= {fsm_data[15:8], SPI_Dout};
                        `REGADDR_num2   : rnum2 <= {fsm_data[15:8], SPI_Dout};
                        `REGADDR_num3   : rnum3 <= {fsm_data[15:8], SPI_Dout};
                        default         : ; 
                    endcase
            end

            s_readReg_getAddr       : begin
                if(SPI_Data_end)
                    case (SPI_Dout)
                        `REGADDR_sum    : fsm_data <= i_sum;
                        `REGADDR_num1   : fsm_data <= rnum1;
                        `REGADDR_num2   : fsm_data <= rnum2;
                        `REGADDR_num3   : fsm_data <= rnum3;
                        `REGADDR_en     : fsm_data <= {15'd0, ren};
                        default         : fsm_data <= 16'd0;
                    endcase
            end
            s_readReg_readData_0    : begin
            end
            s_readReg_readData_1    : begin
            end

            s_writeFIFO_getCNT_0    : begin
                if(SPI_Data_end)
                    fsm_cnt[15:8] <= SPI_Dout;
            end
            s_writeFIFO_getCNT_1    : begin
                if(SPI_Data_end)
                    fsm_cnt[7:0] <= SPI_Dout;
            end
            s_writeFIFO_writeData_0 : begin
                fifo_wreq       <= 1'b0;
                if(SPI_Data_end)
                    fsm_data[15:8] <= SPI_Dout;
            end
            s_writeFIFO_writeData_1 : begin
                if(SPI_Data_end) begin
                    fifo_wreq   <= (fifo_wfull) ?1'b0 :1'b1;
                    fifo_wdata  <= {fsm_data[15:8], SPI_Dout};
                    fsm_cnt     <= fsm_cnt - 16'd1;
                end
                else begin
                    fifo_wreq   <= 1'b0;
                end
            end

            s_readFIFO_getCNT_0     : begin
                if(SPI_Data_end)
                    fsm_cnt[15:8] <= SPI_Dout;
            end
            s_readFIFO_getCNT_1     : begin
                if(SPI_Data_end)
                    fsm_cnt[7:0] <= SPI_Dout;
            end
            s_readFIFO_readData_0   : begin
            end
            s_readFIFO_readData_1   : begin
                if(SPI_Data_end) begin
                    fsm_cnt     <= fsm_cnt - 16'd1;
                end
            end

            s_writeRAM_getFirstAddr : begin
                if(SPI_Data_end)
                    fsm_addr <= {8'd0, SPI_Dout};
            end
            s_writeRAM_getCNT_0     : begin
                if(SPI_Data_end)
                    fsm_cnt[15:8] <= SPI_Dout;
            end
            s_writeRAM_getCNT_1     : begin
                if(SPI_Data_end)
                    fsm_cnt[7:0] <= SPI_Dout;
            end
            s_writeRAM_setAddr      : begin
                ram_waddr <= (fsm_addr >= RAM_SIZE) ?8'd0 :fsm_addr[7:0];
                ram_wreq <= 1'b0;
            end
            s_writeRAM_writeData_0  : begin
                ram_wreq <= 1'b0;
                if(SPI_Data_end)
                    fsm_data[15:8] <= SPI_Dout;
            end
            s_writeRAM_writeData_1  : begin
                if(SPI_Data_end) begin
                    ram_wreq    <= (fsm_addr >= RAM_SIZE) ?1'b0 :1'b1;
                    ram_wdata   <= {fsm_data[15:8], SPI_Dout};
                    fsm_cnt     <= fsm_cnt - 16'd1;
                    fsm_addr    <= fsm_addr + 16'd1;
                end
                else begin
                    ram_wreq    <= 1'b0;
                end
            end

            s_readRAM_getFirstAddr  : begin
                if(SPI_Data_end)
                    fsm_addr <= {8'd0, SPI_Dout};
            end
            s_readRAM_getCNT_0      : begin
                if(SPI_Data_end)
                    fsm_cnt[15:8] <= SPI_Dout;
            end
            s_readRAM_getCNT_1      : begin
                if(SPI_Data_end)
                    fsm_cnt[7:0] <= SPI_Dout;
            end
            s_readRAM_setAddr       : begin
                ram_raddr <= (fsm_addr >= RAM_SIZE) ?8'd0 :fsm_addr[7:0];
            end
            s_readRAM_readData_0    : begin
            end
            s_readRAM_readData_1    : begin
                if(SPI_Data_begin) begin
                    fsm_cnt     <= fsm_cnt - 16'd1;
                    fsm_addr    <= fsm_addr + 16'd1;
                end
            end

            default                 : begin
                rnum1   <= 16'd0;
                rnum2   <= 16'd0;
                rnum3   <= 16'd0;
                ren     <= 1'd0;

                fifo_wreq   <= 1'b0;
                fifo_wdata  <= 16'd0;

                ram_wreq    <= 1'b0;
                ram_waddr   <= 8'd0;
                ram_wdata   <= 16'd0;
                ram_raddr   <= 8'd0;

                fsm_addr    <= 16'd0;
                fsm_data    <= 16'd0;
                fsm_cnt     <= 16'd0;
            end
        endcase
    end
end

always @(*) begin
    if(!rst_n) begin
        SPI_Din     = {`WIDTH{1'b0}};
        fifo_rreq   = 1'b0;

    end
    else begin
        SPI_Din     = {`WIDTH{1'b0}};
        fifo_rreq   = 1'b0;
        case (state_c)
            s_readReg_readData_0    : begin
                if(SPI_Data_begin)
                    SPI_Din = fsm_data[15:8];
            end
            s_readReg_readData_1    : begin
                if(SPI_Data_begin)
                    SPI_Din = fsm_data[7:0];
            end
            s_readFIFO_readData_0   : begin
                if(SPI_Data_begin)
                    SPI_Din = (fifo_rempty) ?8'd0 :fifo_rdata[15:8];
            end
            s_readFIFO_readData_1   : begin
                if(SPI_Data_begin) begin
                    SPI_Din     = (fifo_rempty) ?8'd0 :fifo_rdata[7:0];
                    fifo_rreq   = (fifo_rempty) ?1'b0 :1'b1;
                end
            end
            s_readRAM_readData_0:   begin
                if(SPI_Data_begin)
                    SPI_Din = (fsm_addr >= RAM_SIZE) ?8'd0 :ram_rdata[15:8];
            end
            s_readRAM_readData_1:   begin
                if(SPI_Data_begin)
                    SPI_Din = (fsm_addr >= RAM_SIZE) ?8'd0 :ram_rdata[7:0];
            end
            default ;
        endcase
    end
end


endmodule
