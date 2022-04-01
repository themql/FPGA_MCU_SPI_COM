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
add wave -noupdate /tb_main/u_design_main/u_SPI_if/begin_data
add wave -noupdate /tb_main/u_design_main/u_SPI_if/end_data
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal -childformat {{{/tb_main/u_design_main/u_SPI_if/register0[15]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[14]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[13]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[12]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[11]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[10]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[9]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[8]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[7]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[6]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[5]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[4]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[3]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[2]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[1]} -radix unsigned} {{/tb_main/u_design_main/u_SPI_if/register0[0]} -radix unsigned}} -subitemconfig {{/tb_main/u_design_main/u_SPI_if/register0[15]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[14]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[13]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[12]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[11]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[10]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[9]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[8]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[7]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[6]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[5]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[4]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[3]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[2]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[1]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned} {/tb_main/u_design_main/u_SPI_if/register0[0]} {-color Cyan -height 15 -itemcolor Cyan -radix unsigned}} /tb_main/u_design_main/u_SPI_if/register0
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/u_SPI_if/register1
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/u_SPI_if/register2
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/u_SPI_if/register3
add wave -noupdate -radix hexadecimal /tb_main/r_rece
add wave -noupdate -radix hexadecimal -childformat {{{/tb_main/data[2]} -radix hexadecimal} {{/tb_main/data[1]} -radix hexadecimal} {{/tb_main/data[0]} -radix hexadecimal}} -subitemconfig {{/tb_main/data[2]} {-height 15 -radix hexadecimal} {/tb_main/data[1]} {-height 15 -radix hexadecimal} {/tb_main/data[0]} {-height 15 -radix hexadecimal}} /tb_main/data
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/fifo_wreq
add wave -noupdate -color Yellow -itemcolor Yellow -radix unsigned /tb_main/u_design_main/fifo_wdata
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/fifo_wfull
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/fifo_rreq
add wave -noupdate -color Yellow -itemcolor Yellow -radix unsigned /tb_main/u_design_main/fifo_rdata
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/fifo_rempty
add wave -noupdate -color Cyan -itemcolor Cyan /tb_main/u_design_main/ram_wreq
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/ram_waddr
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/ram_wdata
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/ram_raddr
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /tb_main/u_design_main/ram_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {211377 ns} 0}
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
WaveRestoreZoom {0 ns} {275205 ns}
