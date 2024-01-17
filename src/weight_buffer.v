


`include "../rtl/define.v"
module weight_buffer (
    input clk,
    input rstn,
    input enable,


    input [`ADDR_SIZE-1:0]  weight_addr,
    input w_addr_valid,

    input upd_w_vld,
    input upd_w_addr,
    input upd

);
    
endmodule