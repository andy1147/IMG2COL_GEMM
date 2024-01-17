

`include "../rtl/define.v"


module data_process (

    input clk,
    input rstn,
    input start, //keep 
    input t_padding_zero,
    input w_padding_zero,

    input [`DATA_WIDTH-1 :0] i_tensor_data,
    input [`DATA_WIDTH-1 :0] i_weight_data,


    output  [`S2P_SIZE**2* `DATA_WIDTH -1 : 0] o_matrix_tensor,
    output  [`S2P_SIZE**2* `DATA_WIDTH -1 : 0] o_matrix_weight,
    output   flag_buffer //pluse

);



reg start_sync;
reg t_padding_zero_sync;
reg w_padding_zero_sync;


wire [`DATA_WIDTH-1 :0] t_data_fix;
wire [`DATA_WIDTH-1 :0] w_data_fix;


always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        start_sync <= 0;
        t_padding_zero_sync <= 0;
        w_padding_zero_sync <= 0;
    end
    else begin
        start_sync <= start;
        t_padding_zero_sync <= t_padding_zero;
        w_padding_zero_sync <= w_padding_zero;
    end
end


assign t_data_fix = (t_padding_zero_sync)?0:i_tensor_data;
assign w_data_fix = (w_padding_zero_sync)?0:i_weight_data;


reg [`S2P_SIZE**2* `DATA_WIDTH -1 : 0] t_buffer;
reg [`S2P_SIZE**2* `DATA_WIDTH -1 : 0] w_buffer;
reg [$clog2(`S2P_SIZE**2)-1 :0] tw_cnt;
reg flag_buffer_reg;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        t_buffer <= 0;
        w_buffer <= 0;
        // tw_cnt <= 0;
        // flag_buffer_reg <= 0;
    end
    else begin
        // tw_cnt <= (tw_cnt==`S2P_SIZE**2-1)?0:tw_cnt+1;
        // flag_buffer_reg <= (tw_cnt==`S2P_SIZE**2-1);
        t_buffer[0 +: `DATA_WIDTH] <= t_data_fix;
        t_buffer[`S2P_SIZE**2 * `DATA_WIDTH -1 : `DATA_WIDTH] <= t_buffer[`S2P_SIZE**2*`DATA_WIDTH -1-`DATA_WIDTH : 0];
        w_buffer[0 +: `DATA_WIDTH] <= w_data_fix;
        w_buffer[`S2P_SIZE**2 * `DATA_WIDTH -1 : `DATA_WIDTH] <= w_buffer[`S2P_SIZE**2* `DATA_WIDTH -1-`DATA_WIDTH : 0];
    end
end




always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        tw_cnt <= 0;
        flag_buffer_reg <= 0;
    end
    else if(start_sync)begin
        tw_cnt <= (tw_cnt==`S2P_SIZE**2-1)?0:tw_cnt+1;
        flag_buffer_reg <= (tw_cnt==`S2P_SIZE**2-1);
    end
end



assign flag_buffer=flag_buffer_reg;
assign o_matrix_tensor = t_buffer;
assign o_matrix_weight = w_buffer;


    


endmodule