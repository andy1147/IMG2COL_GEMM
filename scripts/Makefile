
.PHONY:com cov clean dve verdi all
				
OUTPUT = IM2COL_GEMM

WORK_DIR=/home/ICer/ic_prjs/IMG2COL_GEMM/work/
FILELIST_PATH= /home/ICer/ic_prjs/IMG2COL_GEMM/filelist/
FILELIST_NAME=CONV_ACC_v1_0

SWITCH_DIR= cd ${WORK_DIR} && 
Debug_Tool=verdi

WAVE_MODE =0


ifeq (${Debug_Tool},dve)
debug=dve
endif
ifeq (${Debug_Tool},verdi)
debug=verdi
endif		




ifeq (${WAVE_MODE},1)
all:clean com sim ${debug}
else 
all:clean com sim
endif



#compile command
VCS = ${SWITCH_DIR}           \
	vcs -sverilog +v2k -fsdb +define+FSDB -timescale=1ns/1ns \
	-debug_all			    \
	-l compile.log                      \
		-cm line+cond+fsm+tgl    \
        +vcd+vcdpluson+memcbk    \
	-full64                           	


#simulation command
SIM = ./${OUTPUT} -l ${OUTPUT}.log



#start compile
com:
	${VCS} -f ${FILELIST_PATH}${FILELIST_NAME}.f
				
#start simulation
sim:
		${SWITCH_DIR}           \
		./simv -cm line+cond+fsm+tgl  +memcbk
				
#show the coverage
cov:
		${SWITCH_DIR}                   \
		dve -full64 -covdir *vdb &

#start debug commnd
dve:
		dve -full64 -vpd ${OUTPUT}.vpd &
verdi:
		${SWITCH_DIR}      \
		verdi -full64 -f ${FILELIST_PATH}${FILELIST_NAME}.f -ssf *.vcd & 


#clean some file
clean:
	${SWITCH_DIR}       \
	rm -rf ./*            \
	rm -rf ./csrc  *.vcd *.daidir ./csrc *.log *.vpd *.fsdb *.vdb simv* *.key *race.out* 


