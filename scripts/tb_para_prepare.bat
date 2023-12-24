iverilog -o wave  ../rtl/para_prepare.v ../tb/tb_para_prepare.v 
vvp -n wave -lxt2
gtkwave para_prepare.vcd