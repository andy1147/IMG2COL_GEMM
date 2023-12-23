
`include "../rtl/define.v"

module TOP (
        input clk,
        input rstn,
        input start,

        input [`TENSOR_SIZE-1:0] tensor_size, 
        input [`KERNEL_SIZE-1:0] kernel_size, 
        input [`CHANNELS_SIZE-1:0] channels, 
        input [`STRIDE_SIZE-1:0] stride, 
        input [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,

        output [`RESULT_SIZE-1:0] dout,
        output w_done


);
    









wire  [`DATA_WIDTH-1 :0] tensor_data;
wire  [`DATA_WIDTH-1 :0] weight_data;

wire [`ADDR_SIZE-1:0] tensor_addr;
wire [`ADDR_SIZE-1:0] weight_addr;
wire t_addr_valid;
wire w_addr_valid;


wire [`ADDR_SIZE -1 :0] result_addr;
wire [`RESULT_SIZE -1 :0] result_save;
wire ena;
wire wea;




   IMG2COL_GEMM_TOP  u_IMG2COL_GEMM_TOP (
    .clk                     ( clk                                     ),
    .rstn                    ( rstn                                    ),
    .start                   ( start                                  ),
    .tensor_size             ( tensor_size    [`TENSOR_SIZE-1:0]       ),
    .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]       ),
    .channels                ( channels       [`CHANNELS_SIZE-1:0]     ),
    .stride                  ( stride         [`STRIDE_SIZE-1:0]       ),
    .kernel_nums             ( kernel_nums    [`KERNEL_NUMS_SIZE-1 :0] ),
    .tensor_data             ( tensor_data    [`DATA_WIDTH-1 :0]       ),
    .weight_data             ( weight_data    [`DATA_WIDTH-1 :0]       ),
    //output
    .o_result_addr           ( result_addr  [`ADDR_SIZE -1 :0]         ),
    .o_result_save           ( result_save  [`RESULT_SIZE -1 :0]       ),
    .ena                     ( ena                                     ),
    .wea                     ( wea                                     ),
    .w_done                  ( w_done                                  ),
    .tensor_addr             ( tensor_addr    [`ADDR_SIZE-1:0]         ),
    .o_t_addr_valid          ( t_addr_valid                            ),
    .weight_addr             ( weight_addr    [`ADDR_SIZE-1:0]         ),
    .o_w_addr_valid          ( w_addr_valid                            )
    );






    ram_t u_RAM_tensor(
        .clka(clk),
        .addra(tensor_addr),
        .ena(t_addr_valid),////t_addr_valid
        .wea(1'b0),
        .dina(`DATA_WIDTH'b0),
        .douta(tensor_data)
    );

    ram_w u_RAM_weight(
        .clka(clk),
        .addra(weight_addr),
        .ena(w_addr_valid),
        .wea(1'b0),
        .dina(`DATA_WIDTH'b0),
        .douta(weight_data)
    );




wire wea_ram_save;
wire [`ADDR_SIZE -1 :0] ram_save_addr;
reg [`ADDR_SIZE -1 :0] addr;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        addr <=0;
    end
    else if(w_done)begin
        addr<=addr+1;
    end
end

assign wea_ram_save =(w_done)? 0: wea;
assign ram_save_addr = (w_done)?addr:result_addr;

    ram_save u_RAM_save(
        .clka(clk),
        .addra(ram_save_addr),
        .ena(ena),
        .wea(wea_ram_save),
        .dina(result_save),
        .douta(dout)
    );



endmodule