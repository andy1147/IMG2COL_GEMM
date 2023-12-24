iverilog -o wave -g2005-sv -f ../filelist/IMG2COL_GEMM.f  
vvp -n wave -lxt2
gtkwave IMG2COL_GEMM.vcd