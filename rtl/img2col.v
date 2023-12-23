



`include "../rtl/define.v"
module img2col (

        input clk,
        input rstn,
        input enable,

        // input [`TENSOR_SIZE-1:0] tensor_size, 
        // input [`KERNEL_SIZE-1:0] kernel_size, 
        // input [`CHANNELS_SIZE-1:0] channels, 
        // input [`STRIDE_SIZE-1:0] stride, 
        // input [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,

        // TO tensor_addr
        input [`KERNEL_SIZE-1:0] kernel_size,
        input [`STRIDE_SIZE-1:0] stride,
        input [`S2P_SIZE-1 : 0] img2col_t_length_rem,
        input [`TENSOR_SIZE + `STRIDE_SIZE -1 :0] t_mul_s,
        input [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] buffer_row_nums_t,
        input [`TENSOR_SIZE-1:0] out_feature_size,
        input [`ADDR_SIZE-1:0]  switch_row_add_nums,
        input [`ADDR_SIZE-1 : 0] switch_channel_add_nums,


        // T0 weight_addr
        input [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] buffer_col_nums,
        input [`KERNEL_NUMS_SIZE-1 : 0] buffer_row_nums_w,
        input [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0] img2col_w_width,
        input [`S2P_SIZE-1 : 0] kernel_nums_rem,
        input [`S2P_SIZE-1 : 0] img2col_w_width_rem,
        

        input [`DATA_WIDTH-1 :0] i_tensor_data,
        input [`DATA_WIDTH-1 :0] i_weight_data,
        output  [`ADDR_SIZE-1:0]  o_tensor_addr,
        output o_t_addr_valid,
        output  [`ADDR_SIZE-1:0]  o_weight_addr,
        output o_w_addr_valid,


        output [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] o_matrix_tensor,
        output [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] o_matrix_weight,
        output flag_buffer

);
    





wire tensor_done;
wire t_addr_valid;
wire w_addr_valid;
wire t_padding_valid;
wire w_padding_valid;


assign o_w_addr_valid = w_addr_valid;
assign o_t_addr_valid = t_addr_valid;

tensor_addr  u_tensor_addr (
    .clk                     ( clk                                 ),
    .rstn                    ( rstn                                ),
    .enable                  ( enable                              ),

    // .tensor_size             ( tensor_size    [`TENSOR_SIZE-1:0]   ),
    // .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]   ),
    // .channels                ( channels       [`CHANNELS_SIZE-1:0] ),
    // .stride                  ( stride         [`STRIDE_SIZE-1:0]   ),
    
    .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]   ),
    .stride                  ( stride         [`STRIDE_SIZE-1:0]   ),
    .img2col_t_length_rem     ( img2col_t_length_rem     [`S2P_SIZE-1 : 0]                                ),
    .t_mul_s                  ( t_mul_s                  [`TENSOR_SIZE + `STRIDE_SIZE -1 :0]              ),
    .buffer_row_nums          ( buffer_row_nums_t        [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .out_feature_size         ( out_feature_size         [`TENSOR_SIZE-1:0]                               ),
    .switch_row_add_nums      ( switch_row_add_nums      [`ADDR_SIZE-1:0]                                 ),
    .switch_channel_add_nums  ( switch_channel_add_nums  [`ADDR_SIZE-1 : 0]                               ),


    .o_tensor_addr           ( o_tensor_addr  [`ADDR_SIZE-1:0]     ),
    .o_tensor_done           ( tensor_done                                ),
    .o_addr_valid            (t_addr_valid                         ),
    .padding_valid           (t_padding_valid)
);



weight_addr  u_weight_addr (
    .clk                     ( clk                                     ),
    .rstn                    ( rstn                                    ),
    .enable                  ( enable                                  ),
    .tensor_done             ( tensor_done                             ),

    // .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]       ),
    // .channels                ( channels       [`CHANNELS_SIZE-1:0]     ),
    // .kernel_nums             ( kernel_nums    [`KERNEL_NUMS_SIZE-1 :0] ),

    .buffer_col_nums         ( buffer_col_nums      [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] ),
    .buffer_row_nums         ( buffer_row_nums_w    [`KERNEL_NUMS_SIZE-1 : 0]                        ),
    .img2col_w_width         ( img2col_w_width      [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0]  ),
    .kernel_nums_rem         ( kernel_nums_rem      [`S2P_SIZE-1 : 0]                                ),
    .img2col_w_width_rem     ( img2col_w_width_rem  [`S2P_SIZE-1 : 0]                                ),

    .o_weight_addr           ( o_weight_addr  [`ADDR_SIZE-1:0]         ),
    .o_addr_valid            (w_addr_valid                         ),
    .padding_valid           (w_padding_valid)
);



data_process  u_data_process (
    .clk                     ( clk                                                ),
    .rstn                    ( rstn                                               ),
    .start                   ( t_addr_valid && w_addr_valid                       ),
    .t_padding_zero          ( t_padding_valid                                     ),
    .w_padding_zero          ( w_padding_valid                                     ),
    .i_tensor_data           ( i_tensor_data    [`DATA_WIDTH-1 :0]                ),
    .i_weight_data           ( i_weight_data    [`DATA_WIDTH-1 :0]                ),
    .o_matrix_tensor         ( o_matrix_tensor  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] ),
    .o_matrix_weight         ( o_matrix_weight  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] ),
    .flag_buffer             ( flag_buffer                                        )
);

endmodule