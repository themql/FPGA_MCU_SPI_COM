onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_main/clk
add wave -noupdate /tb_main/rst_n
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/spi_scl
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/spi_sdi
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/spi_sel
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/spi_sdo
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_instPars/i_sum
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_instPars/rnum1
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_instPars/rnum2
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_instPars/rnum3
add wave -noupdate /tb_main/u_design_main/u_instPars/ren
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_instPars/fifo_wreq
add wave -noupdate -color Yellow -itemcolor Yellow -radix hexadecimal /tb_main/u_design_main/u_instPars/fifo_wdata
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_instPars/fifo_wfull
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_instPars/fifo_rreq
add wave -noupdate -color Yellow -itemcolor Yellow -radix hexadecimal /tb_main/u_design_main/u_instPars/fifo_rdata
add wave -noupdate -color Yellow -itemcolor Yellow /tb_main/u_design_main/u_instPars/fifo_rempty
add wave -noupdate /tb_main/u_design_main/u_instPars/ram_wreq
add wave -noupdate -radix unsigned /tb_main/u_design_main/u_instPars/ram_waddr
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_instPars/ram_wdata
add wave -noupdate -radix unsigned /tb_main/u_design_main/u_instPars/ram_raddr
add wave -noupdate -radix hexadecimal /tb_main/u_design_main/u_instPars/ram_rdata
add wave -noupdate -color Violet -radix hexadecimal /tb_main/u_design_main/u_instPars/Din
add wave -noupdate -color Violet -radix hexadecimal /tb_main/u_design_main/u_instPars/Dout
add wave -noupdate -color Violet /tb_main/u_design_main/u_instPars/transBegin
add wave -noupdate -color Violet /tb_main/u_design_main/u_instPars/transEnd
add wave -noupdate -radix unsigned /tb_main/u_design_main/u_instPars/statec
add wave -noupdate -radix unsigned /tb_main/u_design_main/u_instPars/staten
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14763 ns} 0}
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
WaveRestoreZoom {0 ns} {33283 ns}
