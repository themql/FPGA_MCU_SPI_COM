onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_main/clk
add wave -noupdate /tb_main/rst_n
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/spi_scl
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/spi_sdi
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/spi_sel
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/spi_sdo
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/rnum1
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/rnum2
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/rnum3
add wave -noupdate /tb_main/u_design_main/u_SPI_instPars_if/ren
add wave -noupdate -radix unsigned /tb_main/u_design_main/u_SPI_instPars_if/state_c
add wave -noupdate -radix unsigned /tb_main/u_design_main/u_SPI_instPars_if/state_n
add wave -noupdate /tb_main/u_design_main/u_SPI_instPars_if/SPI_Data_begin
add wave -noupdate /tb_main/u_design_main/u_SPI_instPars_if/SPI_Data_end
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/SPI_Din
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/SPI_Dout
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/fsm_addr
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/fsm_data
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/fsm_cnt
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_instPars_if/fifo_wreq
add wave -noupdate -color Yellow -itemcolor Yellow -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/fifo_wdata
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_instPars_if/fifo_wfull
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_instPars_if/fifo_rreq
add wave -noupdate -color Yellow -itemcolor Yellow -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/fifo_rdata
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_instPars_if/fifo_rempty
add wave -noupdate /tb_main/u_design_main/u_SPI_instPars_if/ram_wreq
add wave -noupdate -radix unsigned /tb_main/u_design_main/u_SPI_instPars_if/ram_waddr
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/ram_wdata
add wave -noupdate -radix unsigned /tb_main/u_design_main/u_SPI_instPars_if/ram_raddr
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_instPars_if/ram_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {318367 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1366113 ns}
