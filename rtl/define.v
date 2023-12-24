
///DATA_PATH

`define Qream
//`define Administrator


`ifdef Qream
    `define DATA_PATH "C:/Users/Qdream/OneDrive/Projects/IMG2COL/python/img2col/data/"
`endif 

`ifdef Administrator
    `define DATA_PATH "C:/Users/Administrator/OneDrive/Projects/IMG2COL/python/img2col/data/"
`endif 


///RTL _PARA
`define TENSOR_SIZE 16
`define KERNEL_SIZE 5
`define KERNEL_NUMS_SIZE 8
`define CHANNELS_SIZE 8
`define STRIDE_SIZE 4


`define ADDR_SIZE 32
`define DATA_WIDTH 8
`define RESULT_SIZE 32

// buffer size
`define S2P_SIZE  8






///SIM

//`define SIM_DETAIL
`define DETAIL_NUM 0


`define SIM_ALL





///MEM

`define SIM_MEM

`ifdef SIM_MEM
    `define MEM_LENGTH 1024000
    `define SIM_GROUP_NUMS_SIZE 8
`endif 


