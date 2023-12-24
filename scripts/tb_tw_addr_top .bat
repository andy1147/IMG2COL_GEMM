iverilog -o wave  ../rtl/tensor_addr.v ../rtl/weight_addr.v ../rtl/tw_addr_top.v ../tb/tb_tw_addr_top.v 
vvp -n wave -lxt2
gtkwave tw_addr_top.vcd
