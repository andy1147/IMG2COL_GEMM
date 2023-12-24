iverilog -o wave  ../rtl/tensor_addr.v ../tb/tb_tensor_addr.v 
vvp -n wave -lxt2
gtkwave tenosr_addr.vcd
