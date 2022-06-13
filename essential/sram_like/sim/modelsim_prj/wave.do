onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_main/u_design_main/clk
add wave -noupdate /tb_main/u_design_main/rst_n
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/spi_scl
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/spi_sdi
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/spi_sdo
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/spi_cs_addr
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/spi_cs_data
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_sramLike_if/SPI_Addr
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_sramLike_if/SPI_Din
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_sramLike_if/SPI_Dout
add wave -noupdate /tb_main/u_design_main/u_SPI_sramLike_if/SPI_Data_begin
add wave -noupdate /tb_main/u_design_main/u_SPI_sramLike_if/SPI_Data_end
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/r_rece
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal -childformat {{{/tb_main/data[2]} -radix hexadecimal} {{/tb_main/data[1]} -radix hexadecimal} {{/tb_main/data[0]} -radix hexadecimal}} -expand -subitemconfig {{/tb_main/data[2]} {-color Cyan -itemcolor Cyan -radix hexadecimal} {/tb_main/data[1]} {-color Cyan -itemcolor Cyan -radix hexadecimal} {/tb_main/data[0]} {-color Cyan -itemcolor Cyan -radix hexadecimal}} /tb_main/data
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/i_sum
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/o_num1
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/o_num2
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/o_num3
add wave -noupdate /tb_main/u_design_main/fifo_wreq
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/fifo_wdata
add wave -noupdate /tb_main/u_design_main/fifo_wfull
add wave -noupdate /tb_main/u_design_main/fifo_rreq
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/fifo_rdata
add wave -noupdate /tb_main/u_design_main/fifo_rempty
add wave -noupdate /tb_main/u_design_main/ram_wreq
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/ram_waddr
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/ram_wdata
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/ram_raddr
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/ram_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {36526 ns} 0}
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
WaveRestoreZoom {0 ns} {278145 ns}
