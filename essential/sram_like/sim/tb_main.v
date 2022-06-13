`timescale 1ns/1ps
module tb_main;


// design_main Inputs 
reg   clk;
reg   rst_n;
reg   spi_scl;        
reg   spi_sdi;
reg   spi_cs_addr;
reg   spi_cs_data;

// design_main Outputs
wire  spi_sdo;

design_main #(
    .sim_present ( 1 ))
 u_design_main (
    .clk                     ( clk           ),
    .rst_n                   ( rst_n         ),
    .spi_scl                 ( spi_scl       ),
    .spi_sdi                 ( spi_sdi       ),
    .spi_cs_addr             ( spi_cs_addr   ),
    .spi_cs_data             ( spi_cs_data   ),

    .spi_sdo                 ( spi_sdo       )
);

localparam SPI_SCL_DELAY = 50;
localparam SPI_CSN_DELAY = 50;
localparam width_addr   = 8 ;
localparam width_data  = 16;

task masterSendAddr;
    input [width_addr-1:0] Din_addr;

    begin : block_sendAddr
        integer i;

        #SPI_CSN_DELAY spi_cs_addr = 0;
        for(i = 0; i < width_addr; i = i + 1) begin
            spi_sdi = Din_addr[width_addr - 1 - i];
            // ___|---|
            #SPI_SCL_DELAY spi_scl = 1;
            #SPI_SCL_DELAY spi_scl = 0;
        end
        #SPI_CSN_DELAY spi_cs_addr = 1;
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


integer i;
reg [15:0] r_rece;
reg [15:0] data [2:0];

always #10 clk = ~ clk;

initial begin
    clk = 0;
    rst_n = 0;
    spi_scl = 0;
    spi_sdi = 0;
    spi_cs_addr = 1;
    spi_cs_data = 1;
    r_rece = 0;
    data[0] = 0;
    data[1] = 0;
    data[2] = 0;
#100
    rst_n = 1;
    // en
    #100 masterSendAddr(8'd8);
    #100 masterSendData(16'd1);
    // test register
    $write("test register\n");
    for(i = 0; i < 10; i = i + 1) begin
        data[0] = {$random};
        data[1] = {$random};
        data[2] = {$random};
        #100 masterSendAddr(8'd1);
        #100 masterSendData(data[0]);
        #100 masterSendAddr(8'd2);
        #100 masterSendData(data[1]);
        #100 masterSendAddr(8'd3);
        #100 masterSendData(data[2]);
        #100 masterSendAddr(8'd128);
        #100 masterRece(r_rece);
        if(r_rece == (data[0] + data[1] + data[2])) begin
            $write("test%d pass\n", i);
        end
        else begin
            $write("test%d failed, data0:%h, data1:%h, data2:%h, rece:%h\n", i, data[0], data[1], data[2], r_rece);
        end
    end
    $write("\n");

    // test fifo
    $write("test fifo\n");
    data[0] = 16'd0;
    r_rece = 16'd0;
    // write
    #100 masterSendAddr(8'd4);
    for (i = 0; i < 10; i = i + 1) begin
        data[0] = i+1;
        #100 masterSendData(data[0]);
    end
    // read
    #100 masterSendAddr(8'd132);
    for (i = 0; i < 10; i = i + 1) begin
        #100 masterRece(r_rece);
        if(r_rece == i+1)
            $write("test%d pass\n", i);
        else
            $write("test%d failed, rece:%d\n", i, r_rece);
    end
    $write("\n");

    // test ram
    $write("test ram\n");
    data[0] = 16'd0;
    r_rece = 16'd0;
    // write
    for (i = 0; i < 10; i = i + 1) begin
        #100 masterSendAddr(8'd5);
        #100 masterSendData(i);
        #100 masterSendAddr(8'd7);
        data[0] = i+1;
        #100 masterSendData(data[0]);
    end
    // read
    for (i = 0; i < 10; i = i + 1) begin
        #100 masterSendAddr(8'd6);
        #100 masterSendData(9-i);
        #100 masterSendAddr(8'd128+7);
        #100 masterRece(r_rece);
        if(r_rece == (9-i+1))
            $write("test%d pass\n", i);
        else
            $write("test%d failed, rece:%d\n", i, r_rece);
    end
    $write("\n");

    $write("Simulation finish!\n");
    $stop;
end

endmodule
