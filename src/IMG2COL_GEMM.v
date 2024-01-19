

`include "../src/config.v"

module IMG2COL_GEMM (
        input clk,
        input rstn,
        input start,

        input [`SHIFT_WIDTH-1:0]   shift,

        input [`TENSOR_SIZE-1:0] tensor_size, 
        input [`KERNEL_SIZE-1:0] kernel_size, 
        input [`CHANNELS_SIZE-1:0] channels, 
        input [`STRIDE_SIZE-1:0] stride, 
        input [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,
        

        output [`ADDR_SIZE -1 :0] o_result_addr,
        output [`DATA_WIDTH-1 :0]  o_result_save,
        output result_w_ena,
        output result_w_vld,
        output w_done,


        input  [`DATA_WIDTH-1 :0] tensor_data,
        input  [`DATA_WIDTH-1 :0] weight_data,

        output  [`ADDR_SIZE-1:0]  tensor_addr,
        output o_t_addr_valid,
        output [`ADDR_SIZE-1:0]  weight_addr,
        output o_w_addr_valid,

        output para_done,
        output [`TENSOR_SIZE-1:0] n_ofs

);





wire [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] matrix_tensor;
wire [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] matrix_weight;
wire flag_buffer;
wire enable;
wire o_rstn;


wire [`S2P_SIZE* `RESULT_SIZE -1 : 0]  matrix_product;
wire [1:0] matrix_mul_done;



wire  [`RESULT_SIZE -1 :0] result;
wire [3:0] result_valid;
wire conv_done;

wire tensor_done;
wire weight_done;




wire   [`S2P_SIZE-1 : 0]  img2col_t_length_rem  ;
wire   [`TENSOR_SIZE + `STRIDE_SIZE -1 :0]  t_mul_s  ;
wire   [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0]  buffer_row_nums_t  ;
wire   [`TENSOR_SIZE-1:0]  out_feature_size  ;
wire   [`ADDR_SIZE-1:0]  switch_row_add_nums  ;
wire   [`ADDR_SIZE-1 : 0]  switch_channel_add_nums  ;


wire   [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0]  buffer_col_nums  ;
wire   [`KERNEL_NUMS_SIZE-1 : 0]  buffer_row_nums_w  ;
wire   [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0]  img2col_w_width  ;
wire   [`S2P_SIZE-1 : 0]  kernel_nums_rem    ;
wire   [`S2P_SIZE-1 : 0]  img2col_w_width_rem  ;



wire   [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0]  matrix_add_nums  ;
//wire   [`TENSOR_SIZE*2 :0]  img2col_t_num_ma    ;
//wire   [`KERNEL_NUMS_SIZE-1 :0]  img2col_w_num  ;
//wire   [`TENSOR_SIZE*2+`KERNEL_NUMS_SIZE :0]  result_buffer_nums  ;
wire   [`S2P_SIZE -1 :0]  i2c_t_mat_last_nums  ;
//wire   [`S2P_SIZE -1 :0]  i2c_w_mat_last_nums  ;


//wire   [`TENSOR_SIZE*2 :0]  img2col_t_num_rp    ;
wire   [`ADDR_SIZE-1:0]  switch_kernel_group_addnums  ;
wire   [`ADDR_SIZE-1:0]  switch_kernel_addnums  ;



assign para_done = enable;
assign n_ofs = out_feature_size;

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
    .o_rstn                  ( o_rstn                                                            ),


    .o_t_addr_itlr           ( img2col_t_length_rem    [`S2P_SIZE-1 : 0]                                ),
    .o_t_addr_tms            ( t_mul_s     [`TENSOR_SIZE + `STRIDE_SIZE -1 :0]              ),
    .o_t_addr_brn            ( buffer_row_nums_t     [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .o_t_addr_ofs            ( out_feature_size     [`TENSOR_SIZE-1:0]                               ),
    .o_t_addr_sran           ( switch_row_add_nums   [`ADDR_SIZE-1:0]                                 ),
    .o_t_addr_scan           ( switch_channel_add_nums    [`ADDR_SIZE-1:0]                                 ),

    .o_w_addr_bcn            ( buffer_col_nums     [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .o_w_addr_brn            ( buffer_row_nums_w    [`KERNEL_NUMS_SIZE-1 : 0]                        ),
    .o_w_addr_iww            ( img2col_w_width     [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0]  ),
    .o_w_addr_knr            ( kernel_nums_rem     [`S2P_SIZE-1 : 0]                                ),
    .o_w_addr_iwwr           ( img2col_w_width_rem    [`S2P_SIZE-1 : 0]                                ),

    .o_mat_add_man           ( matrix_add_nums    [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .o_mat_add_itmln         ( i2c_t_mat_last_nums  [`S2P_SIZE -1 :0]                                ),
    .o_res_pro_skga          ( switch_kernel_group_addnums   [`ADDR_SIZE-1:0]                                 ),
    .o_res_pro_ska           ( switch_kernel_addnums    [`ADDR_SIZE-1:0]                                 )
);






img2col  u_img2col (
    //input
    .clk                     ( clk                                                ),
    .rstn                    ( o_rstn                                               ),
    .enable                  ( enable                                             ),

    .kernel_size              ( kernel_size              [`KERNEL_SIZE-1:0]                               ),
    .stride                   ( stride                   [`STRIDE_SIZE-1:0]                               ),
    .img2col_t_length_rem     ( img2col_t_length_rem     [`S2P_SIZE-1 : 0]                                ),
    .t_mul_s                  ( t_mul_s                  [`TENSOR_SIZE + `STRIDE_SIZE -1 :0]              ),
    .buffer_row_nums_t        ( buffer_row_nums_t        [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .out_feature_size         ( out_feature_size         [`TENSOR_SIZE-1:0]                               ),
    .switch_row_add_nums      ( switch_row_add_nums      [`ADDR_SIZE-1:0]                                 ),
    .switch_channel_add_nums  ( switch_channel_add_nums  [`ADDR_SIZE-1 : 0]                               ),
    .buffer_col_nums          ( buffer_col_nums          [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .buffer_row_nums_w        ( buffer_row_nums_w        [`KERNEL_NUMS_SIZE-1 : 0]                        ),
    .img2col_w_width          ( img2col_w_width          [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0]  ),
    .kernel_nums_rem          ( kernel_nums_rem          [`S2P_SIZE-1 : 0]                                ),
    .img2col_w_width_rem      ( img2col_w_width_rem      [`S2P_SIZE-1 : 0]                                ),
    //input from ram
    .i_tensor_data           ( tensor_data    [`DATA_WIDTH-1 :0]                  ),
    .i_weight_data           ( weight_data    [`DATA_WIDTH-1 :0]                  ),
    //output
    .o_tensor_addr           ( tensor_addr    [`ADDR_SIZE-1:0]                    ),
    .o_t_addr_valid          ( o_t_addr_valid                                     ),
    .o_tensor_done            (tensor_done),
    .o_weight_addr           ( weight_addr    [`ADDR_SIZE-1:0]                    ),
    .o_w_addr_valid          ( o_w_addr_valid                                     ),
    .o_weight_done            (weight_done),
    .o_matrix_tensor         ( matrix_tensor  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0]   ),
    .o_matrix_weight         ( matrix_weight  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0]   ),
    .flag_buffer             ( flag_buffer                                        )
);



(* keep_hierarchy="no" *)
matrix_mul  u_matrix_mul (
//input
    .clk                     ( clk                                                ),
    .rstn                    ( o_rstn                                               ),
    .flag_buffer             ( flag_buffer                                        ),
    .tensor_data             ( matrix_tensor  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0]  ),
    .weight_data             ( matrix_weight  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0]  ),
//output
    .matrix_product          ( matrix_product  [`S2P_SIZE * `RESULT_SIZE -1 : 0] ),
    .matrix_mul_done         ( matrix_mul_done                                      )
);




matrix_add  u_matrix_add (
    //input
    .clk                     ( clk                                                 ),
    .rstn                    ( o_rstn                                                ),
    .enable                  (enable                                               ),
    .matrix_mul_done         ( matrix_mul_done                                     ),
    .matrix_product          ( matrix_product   [`S2P_SIZE * `RESULT_SIZE -1 : 0] ),
    .tensor_done            (tensor_done),
    .weight_done            (weight_done),


    .matrix_add_nums         ( matrix_add_nums      [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .i2c_t_mat_last_nums     ( i2c_t_mat_last_nums  [`S2P_SIZE -1 :0]                                ),
    //output
    .o_result_reg                ( result         [`RESULT_SIZE -1 :0]               ),
    .o_result_valid_reg          ( result_valid                                      ),
    .o_conv_done_reg             ( conv_done                                           )        
);




result_save  u_result_save (
    //input
    .clk                     ( clk                                 ),
    .rstn                    ( o_rstn                                ),
    .result                  ( result         [`RESULT_SIZE -1 :0] ),
    .shift                   ( shift [`SHIFT_WIDTH-1:0]           ),
    .result_valid            ( result_valid                ),
    .conv_done               ( conv_done                           ),
    .switch_kernel_group_addnums  ( switch_kernel_group_addnums  [`ADDR_SIZE-1:0]     ),
    .switch_kernel_addnums        ( switch_kernel_addnums        [`ADDR_SIZE-1:0]     ),
    //output
    .o_result_addr           ( o_result_addr  [`ADDR_SIZE -1 :0]   ),
    .o_result_save           ( o_result_save       [`DATA_WIDTH -1 :0] ),
    .result_w_vld            ( result_w_vld                                 ),
    .w_done                  ( w_done                              ),
    .result_w_ena            ( result_w_ena                                 )
);





endmodule