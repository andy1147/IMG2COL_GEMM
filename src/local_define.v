
///DATA_PATH

`define Qream
//`define Administrator


`ifdef Qream
    `define DATA_PATH "C:/Users/Qdream/OneDrive/Projects/IMG2COL/python/img2col/data/"
`endif 

`ifdef Administrator
    `define DATA_PATH "C:/Users/Administrator/OneDrive/Projects/IMG2COL/python/img2col/data/"
`endif 





///SIM

`define SIM_DETAIL
`define DETAIL_NUM 0


//`define SIM_ALL





///MEM

`define SIM_MEM

`ifdef SIM_MEM
    `define MEM_LENGTH 1024000
    `define SIM_GROUP_NUMS_SIZE 8
`endif 


