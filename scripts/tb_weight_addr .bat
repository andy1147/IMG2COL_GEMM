iverilog -o wave  ../rtl/weight_addr.v ../tb/tb_weight_addr.v 
vvp -n wave -lxt2
gtkwave weight_addr.vcd
