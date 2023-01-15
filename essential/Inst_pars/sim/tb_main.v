`timescale 1ns/1ps
module tb_main;


// design_main Parameters  
parameter sim_present  = 0;

// design_main Inputs
reg   clk;
reg   rst_n;
reg   spi_scl;
reg   spi_sdi;
reg   spi_sel;

// design_main Outputs
wire  spi_sdo;

design_main #(
    .sim_present ( sim_present ))
 u_design_main (
    .clk                     ( clk       ),
    .rst_n                   ( rst_n     ),
    .spi_scl                 ( spi_scl   ),
    .spi_sdi                 ( spi_sdi   ),
    .spi_sel                 ( spi_sel   ),

    .spi_sdo                 ( spi_sdo   )
);


localparam SPI_SCL_DELAY    = 50;
localparam SPI_CSN_DELAY    = 50;
localparam SPI_WIDTH        = 8 ;

`define bufSize (1024)
reg [SPI_WIDTH-1:0] Buf_send [0:`bufSize-1];
reg [SPI_WIDTH-1:0] Buf_rece [0:`bufSize-1];

task masterSendRece;
    input  [15:0]            size;

    begin : b_spi_send_rece
        integer i, i_size;

        for (i_size = 0; i_size < size; i_size = i_size + 1) begin
            #SPI_CSN_DELAY spi_sel = 0;
            for(i = 0; i < SPI_WIDTH; i = i + 1) begin
                spi_sdi = Buf_send[i_size][SPI_WIDTH-1-i];
                // ___|---|
                #SPI_SCL_DELAY spi_scl = 1;
                Buf_rece[i_size][SPI_WIDTH-i-1] = spi_sdo;
                #SPI_SCL_DELAY spi_scl = 0;
            end
            #SPI_CSN_DELAY spi_sel = 1;
            #40 ;
        end
    end
endtask


integer i;
integer flag_fifo_pass;
integer flag_ram_pass;
reg [15:0] r_rece;
reg [15:0] data [2:0];

always #10 clk = ~ clk;

initial begin
    clk = 0;
    rst_n = 0;
    spi_scl = 0;
    spi_sdi = 0;
    spi_sel = 1;
    r_rece = 0;
    data[0] = 0;
    data[1] = 0;
    data[2] = 0;
#100
    rst_n = 1;
    // en
    Buf_send[0] = 8'h01;
    #100 masterSendRece(1);
    $write("Check out!!! The under tests are using bigEndian!\n");
    // test register
    $write("test register\n");
    for(i = 0; i < 10; i = i + 1) begin
        data[0] = {$random};
        data[1] = {$random};
        data[2] = {$random};

        Buf_send[0] = 8'h02;
        Buf_send[1] = 8'h01;
        Buf_send[2] = data[0][15:8];
        Buf_send[3] = data[0][7:0];
        #100 masterSendRece(4);
        Buf_send[0] = 8'h02;
        Buf_send[1] = 8'h02;
        Buf_send[2] = data[1][15:8];
        Buf_send[3] = data[1][7:0];
        #100 masterSendRece(4);
        Buf_send[0] = 8'h02;
        Buf_send[1] = 8'h03;
        Buf_send[2] = data[2][15:8];
        Buf_send[3] = data[2][7:0];
        #100 masterSendRece(4);
        Buf_send[0] = 8'h03;
        Buf_send[1] = 8'h00;
        Buf_send[2] = 8'h00;
        Buf_send[3] = 8'h00;
        #100 masterSendRece(4);

        r_rece = {Buf_rece[2], Buf_rece[3]};
        if(r_rece == (data[0] + data[1] + data[2])) begin
            $write("test%d pass\n", i);
        end
        else begin
            $write("test%d failed, data0:%h, data1:%h, data2:%h, rece:%h\n", i, data[0], data[1], data[2], r_rece);
        end
    end
    $write("\n");
#100000;
    // test fifo
    $write("test fifo\n");
    r_rece = 16'd0;
    flag_fifo_pass = 1;
    // write
    Buf_send[0] = 8'h04;
    Buf_send[1] = 16'd300 / 256;
    Buf_send[2] = 16'd300 % 256;
    for (i = 0; i < 300; i = i + 1) begin
        data[0] = 1000 + i;
        Buf_send[3+i*2] = data[0] / 256;
        Buf_send[4+i*2] = data[0] % 256;
    end
    #5000 masterSendRece(603);
    // read
    Buf_send[0] = 8'h05;
    Buf_send[1] = 16'd300 / 256;
    Buf_send[2] = 16'd300 % 256;
    for (i = 0; i < 300; i = i + 1) begin
        Buf_send[3+i*2] = 8'h00;
        Buf_send[4+i*2] = 8'h00;
    end
    #5000 masterSendRece(603);

    for (i = 0; (i < 256) && flag_fifo_pass; i = i + 1) begin
        r_rece = {Buf_rece[3+i*2], Buf_rece[4+i*2]};
        if(r_rece == 1000 + i)
            ;
        else begin
            $write("test%d failed, rece:%d\n", i, r_rece);
            flag_fifo_pass = 0;
        end
    end
    for (i = 256; (i < 300) && flag_fifo_pass; i = i + 1) begin
        r_rece = {Buf_rece[3+i*2], Buf_rece[4+i*2]};
        if(r_rece == 16'd0)
            ;
        else begin
            $write("test%d failed, rece:%d\n", i, r_rece);
            flag_fifo_pass = 0;
        end
    end
    if(flag_fifo_pass)
        $write("FIFO test pass!\n");
    $write("\n");
#100000;
    // test ram
    $write("test ram\n");
    r_rece = 16'd0;
    flag_ram_pass = 1;
    // write
    Buf_send[0] = 8'h06;
    Buf_send[1] = 8'h00;
    Buf_send[2] = 8'h00;
    Buf_send[3] = 16'd300 / 256;
    Buf_send[4] = 16'd300 % 256;
    for (i = 0; i < 300; i = i + 1) begin
        data[0] = 1000 + i;
        Buf_send[5+i*2] = data[0] / 256;
        Buf_send[6+i*2] = data[0] % 256;
    end
    #5000 masterSendRece(605);
    // read
    Buf_send[0] = 8'h07;
    Buf_send[1] = 8'h00;
    Buf_send[2] = 8'h00;
    Buf_send[3] = 16'd300 / 256;
    Buf_send[4] = 16'd300 % 256;
    for (i = 0; i < 10; i = i + 1) begin
        Buf_send[5+i*2] = 8'h00;
        Buf_send[6+i*2] = 8'h00;
    end
    #5000 masterSendRece(605);

    for (i = 0; (i < 256) && flag_fifo_pass; i = i + 1) begin
        r_rece = {Buf_rece[5+i*2], Buf_rece[6+i*2]};
        if(r_rece == 1000 + i)
            ;
        else begin
            $write("test%d failed, rece:%d\n", i, r_rece);
            flag_ram_pass = 0;
        end
    end
    for (i = 256; (i < 300) && flag_fifo_pass; i = i + 1) begin
        r_rece = {Buf_rece[5+i*2], Buf_rece[6+i*2]};
        if(r_rece == 16'd0)
            ;
        else begin
            $write("test%d failed, rece:%d\n", i, r_rece);
            flag_ram_pass = 0;
        end
    end
    if(flag_ram_pass)
        $write("RAM test pass!\n");
    $write("\n");

    $write("Simulation finish!\n");
    $stop;
end

endmodule
