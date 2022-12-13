quit -sim
.main clear

vlib work
vmap work work

vlog ../tb_main_spi.v
vlog ../../spi/RTL/design_main_spi.v
vlog ../../spi/RTL/SPI_DCS_if.v
vlog ../../spi/RTL/regBank.v
vlog ../../../alt_ip/fpga_fifo.v
vlog ../../../alt_ip/fpga_ram.v

vsim -t ns -novopt +notimingchecks -L altera_mf_ver work.tb_main_spi

# do wave_spi.do
run -all