quit -sim
.main clear

vlib work
vmap work work

vlog ../tb_main_fsmc.v
vlog ../../fsmc/RTL/design_main_fsmc.v
vlog ../../fsmc/RTL/fsmc_sync_if.v
vlog ../../fsmc/RTL/regBank.v
vlog ../../fsmc/RTL/regBank_async.v
vlog ../../../alt_ip/fpga_fifo.v
vlog ../../../alt_ip/fpga_ram.v

vsim -t ns -novopt +notimingchecks -L altera_mf_ver work.tb_main_fsmc

#do wave_fsmc.do
run -all