

`include "../../rtl/define.v"

module IMG2COL_GEMM (
        input clk,
        input rstn,
        input enable,

        input [`TENSOR_SIZE-1:0] tensor_size, 
        input [`KERNEL_SIZE-1:0] kernel_size, 
        input [`CHANNELS_SIZE-1:0] channels, 
        input [`STRIDE_SIZE-1:0] stride, 
        input [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,
        output  [`RESULT_SIZE -1 :0] o_result,
        output w_done,
        output [`RESULT_SIZE -1 :0] dout
        


);
wire conv_done;
    

wire [1:0] o_result_valid;


wire [`ADDR_SIZE -1 :0] result_addr;
wire [`RESULT_SIZE -1 :0]  o_result_save;
wire ena;
wire wea;
// wire o_result_valid;
// wire o_conv_done;

wire [`ADDR_SIZE-1:0]  tensor_addr;
wire [`ADDR_SIZE-1:0]  weight_addr;
wire  [`DATA_WIDTH-1 :0] tensor_data;
wire  [`DATA_WIDTH-1 :0] weight_data;


wire [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] matrix_tensor;
wire [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] matrix_weight;
wire flag_buffer;

wire matrix_mul_done;

 wire [`S2P_SIZE**2 * `RESULT_SIZE -1 : 0]  matrix_product;
  //wire  [`RESULT_SIZE -1 :0]  o_result   ;

//wire [`S2P_SIZE-1 : 0] buffer_row_nums;
//wire weight_done;
//wire result_valid_fix;


img2col  u_img2col (
    .clk                     ( clk                                                ),
    .rstn                    ( rstn                                               ),
    .enable                  ( enable                                             ),
    .tensor_size             ( tensor_size      [`TENSOR_SIZE-1:0]                ),
    .kernel_size             ( kernel_size      [`KERNEL_SIZE-1:0]                ),
    .channels                ( channels         [`CHANNELS_SIZE-1:0]              ),
    .stride                  ( stride           [`STRIDE_SIZE-1:0]                ),
    .kernel_nums             ( kernel_nums      [`KERNEL_NUMS_SIZE-1 :0]          ),
    .i_tensor_data           ( tensor_data    [`DATA_WIDTH-1 :0]                  ),
    .i_weight_data           ( weight_data    [`DATA_WIDTH-1 :0]                  ),

    .o_tensor_addr           ( tensor_addr    [`ADDR_SIZE-1:0]                    ),
    .o_weight_addr           ( weight_addr    [`ADDR_SIZE-1:0]                    ),
    .o_matrix_tensor         ( matrix_tensor  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0]   ),
    .o_matrix_weight         ( matrix_weight  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0]   ),
    .flag_buffer             ( flag_buffer                                        )
    //.buffer_row_nums         (buffer_row_nums  ),
   // .o_weight_done          (weight_done)
   // .o_result_valid_fix          (result_valid_fix)
);


    ram_t u_RAM_tensor(
        .clka(clk),
        .addra(tensor_addr),
        .ena(enable),
        .wea(1'b0),
        .dina(`DATA_WIDTH'b0),
        .douta(tensor_data)
    );

    ram_w u_RAM_weight(
        .clka(clk),
        .addra(weight_addr),
        .ena(enable),
        .wea(1'b0),
        .dina(`DATA_WIDTH'b0),
        .douta(weight_data)
    );


    ram_save u_RAM_save(
        .clka(clk),
        .addra(result_addr),
        .ena(ena),
        .wea(wea),
        .dina(o_result_save),
        .douta(dout)
    );

matrix_mul  u_matrix_mul (
    .clk                     ( clk                                                ),
    .rstn                    ( rstn                                               ),
    .flag_buffer             ( flag_buffer                                        ),
    .tensor_data             ( matrix_tensor  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0]  ),
    .weight_data             ( matrix_weight  [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0]  ),

    .matrix_product          ( matrix_product  [`S2P_SIZE**2 * `RESULT_SIZE -1 : 0] ),
    .matrix_mul_done                    (matrix_mul_done                                               )
);

matrix_add  u_matrix_add (
    .clk                     ( clk                                                 ),
    .rstn                    ( rstn                                                ),
    .matrix_mul_done                    ( matrix_mul_done                                                ),
   // .result_valid_fix               (result_valid_fix),


    .tensor_size             ( tensor_size      [`TENSOR_SIZE-1:0]                ),
    .kernel_size             ( kernel_size      [`KERNEL_SIZE-1:0]                ),
    .channels                ( channels         [`CHANNELS_SIZE-1:0]              ),
    .stride                  ( stride           [`STRIDE_SIZE-1:0]                ),
    .kernel_nums             ( kernel_nums      [`KERNEL_NUMS_SIZE-1 :0]          ),
    
   // .weight_done              (weight_done),
    //.buffer_row_nums         ( buffer_row_nums  [`S2P_SIZE-1 : 0]                  ),
    .matrix_product          ( matrix_product   [`S2P_SIZE**2 * `RESULT_SIZE -1 : 0] ),

    .o_result                ( o_result         [`RESULT_SIZE -1 :0]               ),
    .o_result_valid            (o_result_valid),
    .o_conv_done               (conv_done)
);




result_process  u_result_process (
    .clk                     ( clk                                 ),
    .rstn                    ( rstn                                ),
    .result                  ( o_result         [`RESULT_SIZE -1 :0] ),
    .result_valid            ( o_result_valid                ),
    .conv_done               ( conv_done                           ),
    .tensor_size             ( tensor_size    [`TENSOR_SIZE -1 :0] ),
    .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]   ),
    .stride                  ( stride         [`STRIDE_SIZE-1:0]   ),

    .o_result_addr           ( result_addr  [`ADDR_SIZE -1 :0]   ),
    .o_result_save           ( o_result_save       [`RESULT_SIZE -1 :0] ),
    .wea                     ( wea                                 ),
    .w_done                  ( w_done                              ),
    .ena                     ( ena                                 )
);





endmodule