

`include "../src/config.v"


module CONV_ACC (


//GLOBAL PORTS
        input clk,     //sys
        input rstn,  //sys

//OUTPUT W_DONE
        output w_done,
//AXI_LITE
        //global ports
        input enable, //sys enbale
        input conv_en,//sys_conv ,a impluse siginal


        //ctrl_unit ports
        input [`TENSOR_SIZE-1:0] axi_tensor_size, 
        input [`KERNEL_SIZE-1:0] axi_kernel_size, 
        input [`CHANNELS_SIZE-1:0] axi_channels, 
        input [`STRIDE_SIZE-1:0] axi_stride, 
        input [`KERNEL_NUMS_SIZE-1 :0] axi_kernel_nums,

        ///IMG2COL_GEMM ports 
        input [`SHIFT_WIDTH-1:0]   shift,


//AXI_STREAM
        //ifmap_buffer ports 
        input [`DATA_WIDTH-1 :0] ifmap_w_data,
        input ifmap_w_valid,
        input ifmap_w_last,
        output  ifmap_w_ready,


        input r_ready,
        output  [`DATA_WIDTH-1 :0] r_data,
        output  r_valid,
        output  r_last,


        //weight buffer ports
        output  weight_w_ready,
        input [`DATA_WIDTH-1:0] weight_w_data,
        input weight_w_valid,
        input weight_w_last

);
    




wire [`TENSOR_SIZE-1:0] tensor_size;
wire [`KERNEL_SIZE-1:0] kernel_size;
wire [`CHANNELS_SIZE-1:0] channels;
wire [`STRIDE_SIZE-1:0] stride;
wire [`KERNEL_NUMS_SIZE-1 :0] kernel_nums;


//wire w_done;
wire n_para_done;
wire [`TENSOR_SIZE-1:0] n_ofs;
wire start_conv;


wire [`TENSOR_SIZE*2 :0] n_T_sub_K_div_S2;
wire [`TENSOR_SIZE + `TENSOR_SIZE + `KERNEL_NUMS_SIZE -1 : 0] n_ifmap_num;

ctrl_unit  u_ctrl_unit (
    .clk                     ( clk                                       ),
    .rstn                    ( rstn                                      ),

    .enable                  ( enable                                    ),
    .conv_en                 ( conv_en                                   ),

    .axi_tensor_size         ( axi_tensor_size  [`TENSOR_SIZE-1:0]       ),
    .axi_kernel_size         ( axi_kernel_size  [`KERNEL_SIZE-1:0]       ),
    .axi_channels            ( axi_channels     [`CHANNELS_SIZE-1:0]     ),
    .axi_stride              ( axi_stride       [`STRIDE_SIZE-1:0]       ),
    .axi_kernel_nums         ( axi_kernel_nums  [`KERNEL_NUMS_SIZE-1 :0] ),

    .w_done                  ( w_done                                    ),
    .n_para_done             ( n_para_done                               ),
    .n_ofs                   ( n_ofs            [`TENSOR_SIZE-1:0]       ),
    .n_T_sub_K_div_S2        ( n_T_sub_K_div_S2                          ),

    .tensor_size             ( tensor_size      [`TENSOR_SIZE-1:0]       ),
    .kernel_size             ( kernel_size      [`KERNEL_SIZE-1:0]       ),
    .channels                ( channels         [`CHANNELS_SIZE-1:0]     ),
    .stride                  ( stride           [`STRIDE_SIZE-1:0]       ),
    .kernel_nums             ( kernel_nums      [`KERNEL_NUMS_SIZE-1 :0] ),

    .start_conv              ( start_conv                                ),
    .n_ifmap_num             ( n_ifmap_num                               )
);


wire [`DATA_WIDTH-1 :0] tensor_data;
wire [`DATA_WIDTH-1 :0] weight_data;
wire [`ADDR_SIZE -1 :0] result_addr;
wire [`DATA_WIDTH-1 :0] result_data; 

wire [`ADDR_SIZE-1:0] tensor_addr;
wire t_addr_valid;
wire [`ADDR_SIZE-1:0] weight_addr;
wire w_addr_valid;

wire result_w_ena;
wire result_w_vld;

IMG2COL_GEMM  u_IMG2COL_GEMM (
    .clk                     ( clk                                      ),
    .rstn                    ( rstn                                     ),

    .start                   ( start_conv                               ),

    .shift                   ( shift           [`SHIFT_WIDTH-1:0]       ),

    .tensor_size             ( tensor_size     [`TENSOR_SIZE-1:0]       ),
    .kernel_size             ( kernel_size     [`KERNEL_SIZE-1:0]       ),
    .channels                ( channels        [`CHANNELS_SIZE-1:0]     ),
    .stride                  ( stride          [`STRIDE_SIZE-1:0]       ),
    .kernel_nums             ( kernel_nums     [`KERNEL_NUMS_SIZE-1 :0] ),

    .tensor_data             ( tensor_data     [`DATA_WIDTH-1 :0]       ),
    .weight_data             ( weight_data     [`DATA_WIDTH-1 :0]       ),

    .o_result_addr           ( result_addr     [`ADDR_SIZE -1 :0]       ),
    .o_result_save           ( result_data     [`DATA_WIDTH-1 :0]       ),
    .result_w_ena            ( result_w_ena                             ),
    .result_w_vld            ( result_w_vld                             ),

    .w_done                  ( w_done                                   ),

    .tensor_addr             ( tensor_addr     [`ADDR_SIZE-1:0]         ),
    .o_t_addr_valid          ( t_addr_valid                             ),
    .weight_addr             ( weight_addr     [`ADDR_SIZE-1:0]         ),
    .o_w_addr_valid          ( w_addr_valid                             ),

    .para_done               ( n_para_done                              ),
    .n_ofs                   ( n_ofs            [`TENSOR_SIZE-1:0]      ),
    .n_T_sub_K_div_S2        ( n_T_sub_K_div_S2                         )
);


ifmap_buffer  u_ifmap_buffer (
    .clk                     ( clk                                ),
    .rstn                    ( rstn                               ),

    .enable                  ( enable                             ),
    .conv_en                 ( conv_en                            ),


    .w_data                  ( ifmap_w_data   [`DATA_WIDTH-1 :0]  ),
    .w_valid                 ( ifmap_w_valid                      ),
    .w_last                  ( ifmap_w_last                       ),
    .w_ready                 ( ifmap_w_ready                      ),

    .r_ready                 ( r_ready                            ),
    .r_data                  ( r_data         [`DATA_WIDTH-1 :0]  ),
    .r_valid                 ( r_valid                            ),
    .r_last                  ( r_last                             ),

    .w_done                  ( w_done                             ),
    .n_ifmap_num             ( n_ifmap_num                        ),

    .tensor_addr             ( tensor_addr    [`ADDR_SIZE-1:0]    ),
    .t_addr_vld              ( t_addr_valid                       ),
    .tensor_data             ( tensor_data    [`DATA_WIDTH-1 :0]  ),

    .result_addr             ( result_addr    [`ADDR_SIZE -1 :0]  ),
    .result_data             ( result_data    [`DATA_WIDTH -1 :0] ),
    .result_w_vld            ( result_w_vld                       ),
    .result_w_ena            ( result_w_ena                       )

);


weight_buffer  u_weight_buffer (
    .clk                     ( clk                            ),
    .rstn                    ( rstn                           ),

    .enable                  ( enable                         ),
    .conv_en                 ( conv_en                        ),

    .w_done                  ( w_done                         ),

    .w_ready                 ( weight_w_ready                 ),
    .w_data                  ( weight_w_data[`DATA_WIDTH-1:0] ),
    .w_valid                 ( weight_w_valid                 ),
    .w_last                  ( weight_w_last                  ),

    .weight_addr             ( weight_addr  [`ADDR_SIZE-1:0]  ),
    .w_addr_vld              ( w_addr_valid                   ),
    .weight_data             ( weight_data  [`DATA_WIDTH-1:0] )
);


endmodule
