


`include "../src/config.v"

//add result_valid_temp_d1 siginal   2023.12.13

// add result_valid_temp <= (o_result_row_cnt==`S2P_SIZE-2 && o_result_col_cnt==`S2P_SIZE-1)?0:result_valid_temp;\
// fix when matrix_add_nums==0. result_valid_temp keep high,then buffer_result_cnt can not count;// add one special mode(matrix_add_nums==0)        2023.12.18
module matrix_add (
    input clk,
    input rstn,
    input enable,
    input tensor_done,
    input weight_done,
    input [1 :0] matrix_mul_done,
    input [`S2P_SIZE * `RESULT_SIZE -1 : 0] matrix_product,




    // input [`TENSOR_SIZE-1:0] tensor_size, 
    // input [`KERNEL_SIZE-1:0] kernel_size, 
    // input [`CHANNELS_SIZE-1:0] channels, 
    // input [`STRIDE_SIZE-1:0] stride, 
    // input [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,


    input [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] matrix_add_nums,

    //input [`TENSOR_SIZE*2 :0] img2col_t_num,

    //input [`KERNEL_NUMS_SIZE-1 :0] img2col_w_num,
    //input [`TENSOR_SIZE*2+`KERNEL_NUMS_SIZE :0] result_buffer_nums,


    input [`S2P_SIZE -1 :0] i2c_t_mat_last_nums,
    //input [`S2P_SIZE -1 :0] i2c_w_mat_last_nums,


    

    output  reg [`RESULT_SIZE -1 :0] o_result_reg,
    output  reg [3:0] o_result_valid_reg,   
    output reg o_conv_done_reg

);
wire [3:0]  o_result_valid;
wire [`RESULT_SIZE -1 :0] o_result;
reg o_conv_done;


// wire [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] matrix_add_nums ;

// assign matrix_add_nums = ((kernel_size * kernel_size *channels) %`S2P_SIZE==0)? (kernel_size * kernel_size *channels)/`S2P_SIZE :
//                             (kernel_size * kernel_size *channels)/`S2P_SIZE +1;  ///shift to realize /


// wire [`TENSOR_SIZE*2 :0] img2col_t_num;
// assign img2col_t_num = (((((tensor_size-kernel_size)/stride+1)*((tensor_size-kernel_size)/stride+1))) %`S2P_SIZE==0)? ((((tensor_size-kernel_size)/stride+1)*((tensor_size-kernel_size)/stride+1)))/`S2P_SIZE :
//                             (((tensor_size-kernel_size)/stride+1)*((tensor_size-kernel_size)/stride+1))/`S2P_SIZE +1;  ///shift to realize /


// wire [`KERNEL_NUMS_SIZE-1 :0] img2col_w_num;
// assign img2col_w_num = kernel_nums % `S2P_SIZE ==0 ? kernel_nums/`S2P_SIZE : kernel_nums/`S2P_SIZE +1;


// wire [`TENSOR_SIZE*2+`KERNEL_NUMS_SIZE :0] result_buffer_nums;
// assign result_buffer_nums = img2col_t_num * img2col_w_num;

// wire [`S2P_SIZE -1 :0] i2c_t_mat_last_nums;
// assign i2c_t_mat_last_nums=((((tensor_size-kernel_size)/stride+1)*((tensor_size-kernel_size)/stride+1))) % `S2P_SIZE;

// wire [`S2P_SIZE -1 :0] i2c_w_mat_last_nums;
// assign i2c_w_mat_last_nums=kernel_nums % `S2P_SIZE;








//********************************************************************************************************************
reg [`S2P_SIZE :0] o_result_row_cnt;
reg [`S2P_SIZE :0] o_result_col_cnt;

reg [`TENSOR_SIZE*2+`KERNEL_NUMS_SIZE :0] result_buffer_cnt;
reg [`TENSOR_SIZE*2 :0] img2col_t_cnt;



reg [`S2P_SIZE**2 *`RESULT_SIZE -1 : 0] result;

reg [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] matrix_add_cnt;


//********************************************************************************************************************


reg [1:0] matrix_mul_done1_delay;
reg matrix_mul_done0_delay;

integer i =0;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        matrix_add_cnt <= 0;
    end
    else if( matrix_mul_done1_delay[0])begin
        matrix_add_cnt <= (matrix_add_cnt==matrix_add_nums)?0:matrix_add_cnt+1;
    end 
end


always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        matrix_mul_done1_delay <= 0;
        matrix_mul_done0_delay <= 0;
    end
    else  begin
        matrix_mul_done1_delay <= {matrix_mul_done1_delay[0],matrix_mul_done[1]};
        matrix_mul_done0_delay <= matrix_mul_done[0];
    end
end


reg shift_all_reg;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        shift_all_reg <= 0;
    end
    else if(matrix_add_cnt == matrix_add_nums && matrix_mul_done[0])begin
        shift_all_reg <= 1;
    end
    else if(matrix_mul_done[0])begin
        shift_all_reg <= 0;
    end
end


wire shift_all;
assign shift_all= shift_all_reg;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        result <= 0;
    end
    else if(matrix_add_cnt==0 && matrix_mul_done[0])begin

        for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
            result[`S2P_SIZE **2 * `RESULT_SIZE -1 - i*`RESULT_SIZE -: `RESULT_SIZE] <=  
                        matrix_product[`S2P_SIZE * `RESULT_SIZE -1 - i*`RESULT_SIZE -: `RESULT_SIZE];
        end
        result[(`S2P_SIZE **2 - `S2P_SIZE)* `RESULT_SIZE -1 :`RESULT_SIZE ] <= result[(`S2P_SIZE **2 - `S2P_SIZE-1)* `RESULT_SIZE -1 :0];
        result[`RESULT_SIZE -1 :0] <= result[`S2P_SIZE **2 * `RESULT_SIZE -1  -: `RESULT_SIZE];
    end
    else if(matrix_mul_done[0]) begin

        for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
            result[`S2P_SIZE **2 * `RESULT_SIZE -1 - i*`RESULT_SIZE -: `RESULT_SIZE] <= 
                        result[`S2P_SIZE **2 * `RESULT_SIZE -`RESULT_SIZE-1 - i*`RESULT_SIZE -: `RESULT_SIZE] + 
                        matrix_product[`S2P_SIZE * `RESULT_SIZE -1 - i*`RESULT_SIZE -: `RESULT_SIZE];
        end
        result[(`S2P_SIZE **2 - `S2P_SIZE)* `RESULT_SIZE -1 :`RESULT_SIZE ] <= result[(`S2P_SIZE **2 - `S2P_SIZE-1)* `RESULT_SIZE -1 :0];
        result[`RESULT_SIZE -1 :0] <= result[`S2P_SIZE **2 * `RESULT_SIZE -1  -: `RESULT_SIZE];
    end

    else begin
        result <= {result[`S2P_SIZE **2 * `RESULT_SIZE -1 - `RESULT_SIZE : 0],result[`S2P_SIZE **2 * `RESULT_SIZE -1  -: `RESULT_SIZE]};
    end
end
    



 

 wire result_valid_temp;

 assign result_valid_temp = shift_all_reg;

//  always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         o_result <= 0;
//     end
//     else if(result_valid_temp)begin
//         o_result<= result[`S2P_SIZE**2* `RESULT_SIZE -1 -: `RESULT_SIZE];
//     end
//  end



 assign o_result = result[`S2P_SIZE**2* `RESULT_SIZE -1 -: `RESULT_SIZE];

 reg result_valid_temp_d1 ;
 



always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        result_valid_temp_d1 <= 0;
    end
    else begin
        result_valid_temp_d1 <= result_valid_temp;
    end
end





wire result_valid_neg ;
wire result_valid_pos ;
assign result_valid_neg = (matrix_add_nums==0)?(o_result_row_cnt==`S2P_SIZE-1 && o_result_col_cnt==`S2P_SIZE-1):
                                ~result_valid_temp && result_valid_temp_d1;
assign result_valid_pos = (matrix_add_nums==0)? (o_result_row_cnt==0 && o_result_col_cnt==0):
                              result_valid_temp && ~ result_valid_temp_d1;






// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         result_buffer_cnt <= 0;
//         img2col_t_cnt <= 0;
//     end
//     else if(enable)begin
//         result_buffer_cnt <=(result_valid_neg)?(result_buffer_cnt==result_buffer_nums)?0: result_buffer_cnt+1:result_buffer_cnt;
//         img2col_t_cnt <=(result_valid_pos)? (img2col_t_cnt == img2col_t_num)?1 :  img2col_t_cnt+1 : img2col_t_cnt;
//     end
// end







always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        o_result_row_cnt <= 0;
        o_result_col_cnt <= 0;
    end
    else if(result_valid_temp)begin
        o_result_row_cnt <= (o_result_row_cnt==`S2P_SIZE-1)?0:o_result_row_cnt+1;
        o_result_col_cnt <= (o_result_row_cnt==`S2P_SIZE-1 && o_result_col_cnt==`S2P_SIZE-1)?0:
                            (o_result_row_cnt==`S2P_SIZE-1) ? o_result_col_cnt +1 :
                                o_result_col_cnt;
    end
    else begin
        o_result_row_cnt <=0;
        o_result_col_cnt <= 0;
    end
end




reg ready_t_padding;
reg ready_t_padding_special;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        ready_t_padding <= 0;
        ready_t_padding_special <= 0;
    end
    // else if(i2c_t_mat_last_nums==0)begin
    //     ready_t_padding <= 0;
    //     ready_t_padding_special <= 0;
    // end
    else if(tensor_done)begin
        ready_t_padding_special <= (matrix_add_nums==0)?1:0;
        ready_t_padding <= (matrix_add_nums==0)?0:1;
    end
    else if(ready_t_padding_special && result_valid_neg )begin
        ready_t_padding <= 1;
        ready_t_padding_special <= 0;
    end
    else if(result_valid_neg)begin
        ready_t_padding <= 0;
        ready_t_padding_special <= 0;
    end
end





reg t_result_valid_padding;
always @(*) begin
        if(i2c_t_mat_last_nums==0)begin
            t_result_valid_padding = result_valid_temp;
        end
        else if(ready_t_padding  &&  result_valid_temp)begin
            t_result_valid_padding = ( o_result_row_cnt >= i2c_t_mat_last_nums) ? 0: result_valid_temp;//when need to padding, then t_result_valid_padding is low
        end
        else begin
            t_result_valid_padding = result_valid_temp;
        end
end




// reg w_result_valid_padding;

// wire if_w_r_vlid_padding ;
// assign if_w_r_vlid_padding = (o_result_col_cnt > i2c_w_mat_last_nums-1) || ((o_result_col_cnt == i2c_w_mat_last_nums-1) && o_result_row_cnt == `S2P_SIZE-1);


// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         w_result_valid_padding <= 0;
//     end
//     else if(result_buffer_cnt >= (result_buffer_nums - img2col_t_num)   && result_valid_temp_d1)begin //(img2col_w_num-1) * img2col_t_num
//         if(matrix_add_nums==1)begin
//             w_result_valid_padding <= (o_result_row_cnt==`S2P_SIZE-1 && o_result_col_cnt==`S2P_SIZE-1)?result_valid_temp:
//                                         if_w_r_vlid_padding ? 0: result_valid_temp;
//         end
//         else begin
//             w_result_valid_padding <= if_w_r_vlid_padding ? 0: result_valid_temp;
//         end
        
//     end
//     else begin
//         w_result_valid_padding <= result_valid_temp;
//     end
// end





reg ready_done;
reg ready_done_special;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        ready_done <= 0;
        ready_done_special <= 0;
    end
    else if(weight_done)begin
        ready_done_special <= (matrix_add_nums==0)?1:0;
        ready_done <= (matrix_add_nums==0)?0:1;
    end
    else if(ready_done_special && result_valid_neg)begin
        ready_done <= 1;
        ready_done_special <= 0;
    end
end




always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        o_conv_done <= 0;
    end
    else if(ready_done && result_valid_neg)begin
        o_conv_done <= 1;
    end
end



assign o_result_valid[0] = result_valid_temp && t_result_valid_padding;// && w_result_valid_padding;
assign o_result_valid[1] = result_valid_temp;

// reg result_valid_pos_d1;
// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         result_valid_pos_d1 <= 0;
//     end
//     else begin
//         result_valid_pos_d1 <= result_valid_pos;
//     end
// end
assign o_result_valid[2] = result_valid_pos;
assign o_result_valid[3] = ready_t_padding;
    
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        o_result_reg <= 0;
        o_result_valid_reg <= 0;
        o_conv_done_reg <= 0;
    end
    else begin
        o_result_reg <= o_result;
        o_result_valid_reg <= o_result_valid;
        o_conv_done_reg <= o_conv_done;
    end
end

endmodule