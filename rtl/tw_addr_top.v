





`include "../rtl/define.v"


module tw_addr_top (
        input clk,
        input rstn,
        input enable,

        input [`TENSOR_SIZE-1:0] tensor_size, 
        input [`KERNEL_SIZE-1:0] kernel_size, 
        input [`CHANNELS_SIZE-1:0] channels, 
        input [`STRIDE_SIZE-1:0] stride, 
        input [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,

        
        output  [`ADDR_SIZE-1:0]  o_tensor_addr,
        output  [`ADDR_SIZE-1:0]  o_weight_addr
);



wire done;
wire tensor_done;

tensor_addr  u_tensor_addr (
    .clk                     ( clk                                 ),
    .rstn                    ( rstn                                ),
    .enable                  ( enable                              ),
    .tensor_size             ( tensor_size    [`TENSOR_SIZE-1:0]   ),
    .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]   ),
    .channels                ( channels       [`CHANNELS_SIZE-1:0] ),
    .stride                  ( stride         [`STRIDE_SIZE-1:0]   ),

    .o_tensor_addr           ( o_tensor_addr  [`ADDR_SIZE-1:0]     ),
    .o_tensor_done                    ( tensor_done                         )
);
    

weight_addr  u_weight_addr (
    .clk                     ( clk                                     ),
    .rstn                    ( rstn                                    ),
    .enable                  ( enable                                  ),
    .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]       ),
    .channels                ( channels       [`CHANNELS_SIZE-1:0]     ),
    .kernel_nums             ( kernel_nums    [`KERNEL_NUMS_SIZE-1 :0] ),
    .tensor_done             ( tensor_done                             ),

    .o_weight_addr           ( o_weight_addr  [`ADDR_SIZE-1:0]         ),
    .done                    ( done                                    )
);



endmodule