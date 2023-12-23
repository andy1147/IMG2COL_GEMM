`timescale  1ns / 1ps

`include "../rtl/define.v"

module tb_para_prepare;

// para_prepare Parameters
parameter PERIOD  = 10;


// para_prepare Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   start                                = 0 ;
reg   [`TENSOR_SIZE-1:0]  tensor_size      = 85 ;
reg   [`KERNEL_SIZE-1:0]  kernel_size      = 2 ;
reg   [`CHANNELS_SIZE-1:0]  channels       = 18 ;
reg   [`STRIDE_SIZE-1:0]  stride           = 4 ;
reg   [`KERNEL_NUMS_SIZE-1 :0]  kernel_nums = 16 ;

// para_prepare Outputs
wire  enable                               ;
wire  [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0]  o_t_addr_brn ;
wire  [`TENSOR_SIZE-1:0]  o_t_addr_ofs     ;
wire  [`ADDR_SIZE-1:0]  o_t_addr_sran      ;
wire  [`ADDR_SIZE-1:0]  o_t_addr_scan      ;
wire  [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0]  o_w_addr_bcn ;
wire  [`KERNEL_NUMS_SIZE-1 : 0]  o_w_addr_brn ;
wire  [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0]  o_w_addr_iww ;
wire  [`S2P_SIZE-1 : 0]  o_w_addr_knr      ;
wire  [`S2P_SIZE-1 : 0]  o_w_addr_iwwr     ;
wire  [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0]  o_mat_add_man ;
wire  [`TENSOR_SIZE*2 :0]  o_mat_add_itn   ;
wire  [`KERNEL_NUMS_SIZE-1 :0]  o_mat_add_iwn ;
wire  [`TENSOR_SIZE*2+`KERNEL_NUMS_SIZE :0]  o_mat_add_rbn ;
wire  [`S2P_SIZE -1 :0]  o_mat_add_itmln   ;
wire  [`S2P_SIZE -1 :0]  o_mat_add_iwmln   ;
wire  [`TENSOR_SIZE*2 :0]  o_res_pro_itn   ;
wire  [`ADDR_SIZE-1:0]  o_res_pro_ofs      ;
wire  [`ADDR_SIZE-1:0]  o_res_pro_skga     ;
wire  [`ADDR_SIZE-1:0]  o_res_pro_ska      ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
    #(18) start=1;
end

para_prepare  u_para_prepare (
    .clk                     ( clk                                                               ),
    .rstn                    ( rstn                                                              ),
    .start                   ( start                                                             ),
    .tensor_size             ( tensor_size      [`TENSOR_SIZE-1:0]                               ),
    .kernel_size             ( kernel_size      [`KERNEL_SIZE-1:0]                               ),
    .channels                ( channels         [`CHANNELS_SIZE-1:0]                             ),
    .stride                  ( stride           [`STRIDE_SIZE-1:0]                               ),
    .kernel_nums             ( kernel_nums      [`KERNEL_NUMS_SIZE-1 :0]                         ),

    .enable                  ( enable                                                            ),
    .o_t_addr_brn            ( o_t_addr_brn     [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .o_t_addr_ofs            ( o_t_addr_ofs     [`TENSOR_SIZE-1:0]                               ),
    .o_t_addr_sran           ( o_t_addr_sran    [`ADDR_SIZE-1:0]                                 ),
    .o_t_addr_scan           ( o_t_addr_scan    [`ADDR_SIZE-1:0]                                 ),
    .o_w_addr_bcn            ( o_w_addr_bcn     [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .o_w_addr_brn            ( o_w_addr_brn     [`KERNEL_NUMS_SIZE-1 : 0]                        ),
    .o_w_addr_iww            ( o_w_addr_iww     [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0]  ),
    .o_w_addr_knr            ( o_w_addr_knr     [`S2P_SIZE-1 : 0]                                ),
    .o_w_addr_iwwr           ( o_w_addr_iwwr    [`S2P_SIZE-1 : 0]                                ),
    .o_mat_add_man           ( o_mat_add_man    [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .o_mat_add_itn           ( o_mat_add_itn    [`TENSOR_SIZE*2 :0]                              ),
    .o_mat_add_iwn           ( o_mat_add_iwn    [`KERNEL_NUMS_SIZE-1 :0]                         ),
    .o_mat_add_rbn           ( o_mat_add_rbn    [`TENSOR_SIZE*2+`KERNEL_NUMS_SIZE :0]            ),
    .o_mat_add_itmln         ( o_mat_add_itmln  [`S2P_SIZE -1 :0]                                ),
    .o_mat_add_iwmln         ( o_mat_add_iwmln  [`S2P_SIZE -1 :0]                                ),
    .o_res_pro_itn           ( o_res_pro_itn    [`TENSOR_SIZE*2 :0]                              ),
    .o_res_pro_ofs           ( o_res_pro_ofs    [`ADDR_SIZE-1:0]                                 ),
    .o_res_pro_skga          ( o_res_pro_skga   [`ADDR_SIZE-1:0]                                 ),
    .o_res_pro_ska           ( o_res_pro_ska    [`ADDR_SIZE-1:0]                                 )
);


initial
begin            
    $dumpfile("para_prepare.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_para_prepare);    //tb模块名称
end


initial
begin
    #(PERIOD * 100);
    $finish;
end

endmodule
