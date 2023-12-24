
del wave
del TOP.vcd 
@REM $FILENAME=TOP
@REM echo $FILENAME $FILENAME.vcd
@REM echo $FILENAME"vcd"
@REM del %FILE_NAME%.vcd  %FILENAME%.lxt wave

cd ./work

iverilog -o wave -g2005-sv -f ../filelist/TOP.f  
vvp -n wave -lxt2
gtkwave TOP.vcd
del *.lxt
cd ..