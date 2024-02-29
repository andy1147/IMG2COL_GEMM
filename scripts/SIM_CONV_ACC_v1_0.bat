
del .\work\wave
del .\work\*.lxt
del .\work\CONV_ACC_v1_0.vcd 

cd ./work
iverilog -o wave -g2005-sv -f ../filelist/CONV_ACC_v1_0.f 
vvp -n wave -lxt2
gtkwave CONV_ACC_v1_0.vcd
@REM del *.lxt
@REM del wave
@REM del CONV_ACC_v1_0.vcd
cd ..