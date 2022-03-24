onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_main/u_design_main/u_SPI_if/clk
add wave -noupdate /tb_main/u_design_main/u_SPI_if/rst_n
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_if/spi_scl
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_if/spi_sdi
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_if/spi_sdo
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_if/spi_cs_cmd
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_SPI_if/spi_cs_data
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_if/Dcmd
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_if/Din
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_SPI_if/Dout
add wave -noupdate /tb_main/u_design_main/u_SPI_if/done_cmd
add wave -noupdate /tb_main/u_design_main/u_SPI_if/done_data
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/u_SPI_if/reg0
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/u_SPI_if/reg1
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/u_SPI_if/reg2
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/u_SPI_if/reg3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14030 ns} 0}
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
WaveRestoreZoom {6305 ns} {22918 ns}
