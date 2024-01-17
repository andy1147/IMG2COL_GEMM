
del ./work/wave
del ./work/*.lxt
del ./work/one_conv.vcd 
@REM $FILENAME=one_conv
@REM echo $FILENAME $FILENAME.vcd
@REM echo $FILENAME"vcd"
@REM del %FILE_NAME%.vcd  %FILENAME%.lxt wave

cd ./work

iverilog -o wave -g2005-sv -f ../filelist/SIM_ONE_CONV.f  
vvp -n wave -lxt2
gtkwave one_conv.vcd
@REM del *.lxt
@REM del wave
@REM del one_conv.vcd
cd ..