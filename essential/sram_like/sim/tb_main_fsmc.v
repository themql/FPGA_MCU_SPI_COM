`timescale 1ns/1ps
module tb_main_fsmc;



// design_main_fsmc Inputs      
reg   clk;
reg   rst_n;
reg   [15:0]  fsmc_A;
reg   fsmc_NE;
reg   fsmc_NWE;
reg   fsmc_NOE;

// design_main_fsmc Outputs


// design_main_fsmc Bidirs
wire  [15:0]  fsmc_D;

reg     [15:0]  fsmc_wdata;
wire    [15:0]  fsmc_rdata;

assign fsmc_rdata = fsmc_D;
assign fsmc_D = (fsmc_NOE) ?fsmc_wdata :{16{1'bz}};

design_main_fsmc #(
    .sim_present ( 1 ))
 u_design_main_fsmc (
    .clk                     ( clk        ),
    .rst_n                   ( rst_n      ),
    .fsmc_A                  ( fsmc_A     ),
    .fsmc_NE                 ( fsmc_NE    ),
    .fsmc_NWE                ( fsmc_NWE   ),
    .fsmc_NOE                ( fsmc_NOE   ),

    .fsmc_D                  ( fsmc_D     )
    // .fsmc_wdata              (fsmc_wdata),
    // .fsmc_rdata              (fsmc_rdata)
);



localparam FSMC_width_addr = 16;
localparam FSMC_width_data = 16;
localparam FSMC_ADDSET = 200;
localparam FSMC_DATAST = 200;

// mode A
task hostWrite;
    input   [FSMC_width_addr-1:0]   addr;
    input   [FSMC_width_data-1:0]   wdata;

    begin : Block_hostWrite
        fsmc_A = addr;

        fsmc_NE = 0;
        fsmc_NOE = 1;
        fsmc_NWE = 1;
        
        #FSMC_ADDSET
        fsmc_wdata = wdata;
        fsmc_NWE = 0;

        #FSMC_DATAST    // ingore the end one HCLK
        fsmc_NE = 1;
        fsmc_NOE = 1;
        fsmc_NWE = 1;
    end
endtask

task hostRead;
    input   [FSMC_width_addr-1:0]   addr;
    output  [FSMC_width_data-1:0]   rdata;

    begin : Block_hostRead
        fsmc_A = addr;

        fsmc_NE = 0;
        fsmc_NOE = 1;
        fsmc_NWE = 1;

        #FSMC_ADDSET
        fsmc_NOE = 0;

        #FSMC_DATAST
        fsmc_NE = 1;
        fsmc_NOE = 1;
        fsmc_NWE = 1;
        rdata = fsmc_rdata;
    end
endtask


integer i;
reg [15:0] hostRece;
reg [15:0] data [2:0];


always #10 clk =~clk;

initial begin
    clk = 0;
    rst_n = 0;
    fsmc_A = 'd0;
    fsmc_wdata = 'd0;
    fsmc_NE = 1;
    fsmc_NWE = 1;
    fsmc_NOE = 1;
    hostRece = 0;
    data[0] = 0;
    data[1] = 0;
    data[2] = 0;
    #1000 rst_n = 1;

    // en sys
    hostWrite(16'd4, 16'd1);
    // test sync register
    $write("test sync register\n");
    for( i = 0; i < 10;i = i + 1) begin
        data[0] = {$random};
        data[1] = {$random};
        data[2] = {$random};
        #100 hostWrite(16'd1, data[0]);
        #100 hostWrite(16'd2, data[1]);
        #100 hostWrite(16'd3, data[2]);
        #100 hostRead(16'd0, hostRece);
        if(hostRece == (data[0] + data[1] + data[2])) begin
            $write("test%d pass\n", i);
        end
        else begin
            $write("test%d failed, data0:%h, data1:%h, data2:%h, rece:%h\n", i, data[0], data[1], data[2], hostRece);
        end
    end
    $write("\n");

    // test fifo
    $write("test fifo\n");
    // write
    for (i = 0; i < 10; i = i + 1) begin
        #100 hostWrite(16'd5, i+1);
    end
    // read
    for (i = 0; i < 10; i = i + 1) begin
        #100 hostRead(16'd5, hostRece);
        if(hostRece == i+1)
            $write("test%d pass\n", i);
        else
            $write("test%d failed, rece:%d\n", i, hostRece);
    end
    $write("\n");

    // test ram
    $write("test ram\n");
    data[0] = 16'd0;
    hostRece = 16'd0;
    // write
    for (i = 0; i < 10; i = i + 1) begin
        #100 hostWrite(16'h0100+i, i+1);
    end
    // read
    for (i = 0; i < 10; i = i + 1) begin
        #100 hostRead(16'h0100+9-i, hostRece);
        if(hostRece == (9-i+1))
            $write("test%d pass\n", i);
        else
            $write("test%d failed, rece:%d\n", i, hostRece);
    end
    $write("\n");


    $write("Simulation finish!\n");
    $stop;
end

endmodule
