`timescale 1ns/1ps
module SPI_DCS_Drc_tb;
    

// SPI_DCS_Drv Parameters  
parameter width_cmd   = 8 ;
parameter width_data  = 16;

// SPI_DCS_Drv Inputs
reg   clk;
reg   rst_n;
reg   spi_scl;
reg   spi_sdi;
reg   spi_cs_cmd;
reg   spi_cs_data;
reg   [width_data-1:0]  Din;

// SPI_DCS_Drv Outputs
wire  spi_sdo;
wire  [width_cmd-1 :0]  Dcmd;
wire  [width_data-1:0]  Dout;
wire  done_cmd;
wire  done_data;

SPI_DCS_Drv #(
    .width_cmd  ( 8  ),
    .width_data ( 16 ))
 u_SPI_DCS_Drv (
    .clk                     ( clk           ),
    .rst_n                   ( rst_n         ),
    .spi_scl                 ( spi_scl       ),
    .spi_sdi                 ( spi_sdi       ),
    .spi_cs_cmd              ( spi_cs_cmd    ),
    .spi_cs_data             ( spi_cs_data   ),
    .Din                     ( Din           ),

    .spi_sdo                 ( spi_sdo       ),
    .Dcmd                    ( Dcmd          ),
    .Dout                    ( Dout          ),
    .done_cmd                ( done_cmd      ),
    .done_data               ( done_data     )
);



parameter PERIOD = 20;
parameter RST_ING = 1'b0;

initial begin
    clk = 0;
    forever #(PERIOD/2) clk = ~clk;
end

task sys_reset;
input [31:0] reset_time;
begin
    rst_n = RST_ING;
    # reset_time;
    rst_n = ~RST_ING;
end
endtask

task terminate;
begin
    $write("Simulation Successful!\n");
    $stop;
end
endtask

parameter SPI_SCL_DELAY = 50;
parameter SPI_CSN_DELAY = 50;

task masterSendCMD;
input [width_cmd-1:0] Din_cmd;
begin : block_sendCMD
    integer i;

    #SPI_CSN_DELAY spi_cs_cmd = 0;
    for(i = 0; i < width_cmd; i = i + 1) begin
        spi_sdi = Din_cmd[width_cmd - 1 - i];
        // ___|---|
        #SPI_SCL_DELAY spi_scl = 1;
        #SPI_SCL_DELAY spi_scl = 0;
    end
    #SPI_CSN_DELAY spi_cs_cmd = 1;
end
endtask

task masterSendData;
input [width_data-1:0] Din_data;
begin : block_sendData
    integer i;

    #SPI_CSN_DELAY spi_cs_data = 0;
    for(i = 0; i < width_data; i = i + 1) begin
        spi_sdi = Din_data[width_data - 1 - i];
        // ___|---|
        #SPI_SCL_DELAY spi_scl = 1;
        #SPI_SCL_DELAY spi_scl = 0;
    end
    #SPI_CSN_DELAY spi_cs_data = 1;
end
endtask

task masterRece;
output [width_data-1:0] Dout;
begin : block_rece
    integer i;

    #SPI_CSN_DELAY spi_cs_data = 0;
    for(i = 0; i < width_data; i = i + 1) begin
        
        // ___|---|
        #SPI_SCL_DELAY spi_scl = 1;
        Dout[width_data-1-i] = spi_sdo;
        #SPI_SCL_DELAY spi_scl = 0;
        
    end
    #SPI_CSN_DELAY spi_cs_data = 1;
end
endtask


// reg [width_cmd-1:0] tmp_cmd;
reg [width_data-1:0] tmp_data;
reg [7:0] cnt;

initial begin
    spi_scl = 0;
    spi_sdi = 0;
    spi_cs_cmd  = 1;
    spi_cs_data = 1;
    Din = 0;
    tmp_data = 0;
    sys_reset(100);

    // slave cmd rece test 
    $write("slave cmd rece test\n");
    for(cnt = 0; cnt < 16; cnt = cnt + 1) begin
        masterSendCMD(cnt);
        @(posedge done_cmd);
        if(cnt == Dcmd)
            $write("transmit: %d, receive: %d, ok\n", cnt, Dcmd);
        else begin
            $write("transmit: %d, receive: %d, error\n", cnt, Dcmd);
        end
    end
    #1_000
    for(cnt = 128; cnt < 144; cnt = cnt + 1) begin
        masterSendCMD(cnt);
        @(posedge done_cmd);
        if(cnt == Dcmd)
            $write("transmit: %d, receive: %d, ok\n", cnt, Dcmd);
        else begin
            $write("transmit: %d, receive: %d, error\n", cnt, Dcmd);
        end
    end


    // slave data rece test
    #10_000
    $write("\nslave data rece test\n");
    for(cnt = 0; cnt < 16; cnt = cnt + 1) begin
        tmp_data = {$random};
        masterSendData(tmp_data);
        @(posedge done_data);
        if(tmp_data == Dout) begin
            $write("transmit: %d, receive: %d, ok\n",tmp_data, Dout);
        end
        else begin
            $write("transmit: %d, receive: %d, error\n",tmp_data, Dout);
        end
    end


    // slave data send test
    #10_000
    $write("\nslave data send test\n");
    for(cnt = 0; cnt < 16; cnt = cnt + 1) begin
        Din = {$random};
        masterRece(tmp_data);
        @(posedge done_data);
        if(Din == tmp_data) begin
            $write("transmit: %d, receive: %d, ok\n",Din, tmp_data);
        end
        else begin
            $write("transmit: %d, receive: %d, error\n",Din, tmp_data);
        end
    end


    terminate;
end

 endmodule