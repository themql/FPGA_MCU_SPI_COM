onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_main_spi/clk
add wave -noupdate /tb_main_spi/rst_n
add wave -noupdate -color Yellow /tb_main_spi/u_design_main_spi/spi_scl
add wave -noupdate -color Yellow /tb_main_spi/u_design_main_spi/spi_sdi
add wave -noupdate -color Yellow /tb_main_spi/u_design_main_spi/spi_sdo
add wave -noupdate -color Yellow /tb_main_spi/u_design_main_spi/spi_cs_addr
add wave -noupdate -color Yellow /tb_main_spi/u_design_main_spi/spi_cs_data
add wave -noupdate -radix hexadecimal /tb_main_spi/u_design_main_spi/w_addr
add wave -noupdate -radix hexadecimal /tb_main_spi/u_design_main_spi/w_wdata
add wave -noupdate -radix hexadecimal /tb_main_spi/u_design_main_spi/w_rdata
add wave -noupdate /tb_main_spi/u_design_main_spi/w_wen
add wave -noupdate /tb_main_spi/u_design_main_spi/w_ren
add wave -noupdate -color Cyan -radix hexadecimal /tb_main_spi/r_rece
add wave -noupdate -color Cyan -radix hexadecimal /tb_main_spi/data
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_sum_i
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_num1_o
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_num2_o
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_num3_o
add wave -noupdate /tb_main_spi/u_design_main_spi/w_sys_en
add wave -noupdate /tb_main_spi/u_design_main_spi/w_fifo_wreq
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_fifo_wdata
add wave -noupdate /tb_main_spi/u_design_main_spi/w_fifo_wfull
add wave -noupdate /tb_main_spi/u_design_main_spi/w_fifo_rreq
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_fifo_rdata
add wave -noupdate /tb_main_spi/u_design_main_spi/w_fifo_rempty
add wave -noupdate /tb_main_spi/u_design_main_spi/w_ram_wreq
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_ram_waddr
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_ram_wdata
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_ram_raddr
add wave -noupdate -radix unsigned /tb_main_spi/u_design_main_spi/w_ram_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3365 ns} 0}
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
WaveRestoreZoom {0 ns} {18439 ns}
