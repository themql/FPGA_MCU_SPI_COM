quit -sim
.main clear

vlib work
vmap work work

vlog ../tb_main.v
vlog ../../RTL/*.v
vlog ../../../alt_ip/fpga_fifo.v
vlog ../../../alt_ip/fpga_ram.v

vsim -t ns -novopt +notimingchecks -L altera_mf_ver work.tb_main

# do wave.do
run -all