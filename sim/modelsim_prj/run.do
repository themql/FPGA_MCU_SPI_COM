quit -sim
.main clear

vlib work
vmap work work

vlog ../tb_main.v
vlog ../../RTL/*.v

vsim -t ns -novopt +notimingchecks work.tb_main
run -all