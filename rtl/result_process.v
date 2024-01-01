

`include "../rtl/define.v"
module result_process (
    input clk,
    input rstn,
    input [`RESULT_SIZE -1 :0] result,
    input [3:0] result_valid,
    input conv_done,

    
    // input [`TENSOR_SIZE -1 :0] tensor_size,
    // input [`KERNEL_SIZE-1:0] kernel_size, 
    // input [`STRIDE_SIZE-1:0] stride, 


   // input [`TENSOR_SIZE*2 :0] img2col_t_num,
    //input [`ADDR_SIZE-1:0] o_feature_size,
    input [`ADDR_SIZE-1:0] switch_kernel_group_addnums,
    input [`ADDR_SIZE-1:0] switch_kernel_addnums,



    output reg [`ADDR_SIZE -1 :0] o_result_addr,
    output reg [`RESULT_SIZE -1 :0] o_result_save,
    output reg wea,
    output reg w_done,
    output reg ena

);





// wire [`TENSOR_SIZE*2 :0] img2col_t_num;
// assign img2col_t_num = (((((tensor_size-kernel_size)/stride+1)*((tensor_size-kernel_size)/stride+1))) %`S2P_SIZE==0)? ((((tensor_size-kernel_size)/stride+1)*((tensor_size-kernel_size)/stride+1)))/`S2P_SIZE :
//                             (((tensor_size-kernel_size)/stride+1)*((tensor_size-kernel_size)/stride+1))/`S2P_SIZE +1;  


// wire [`ADDR_SIZE-1:0] o_feature_size;
// assign o_feature_size = ((tensor_size-kernel_size)/stride +1)**2;


// wire [`ADDR_SIZE-1:0] switch_kernel_group_addnums;
// wire [`ADDR_SIZE-1:0] switch_kernel_addnums;
// assign switch_kernel_group_addnums = o_feature_size*`S2P_SIZE -(img2col_t_num-1)*`S2P_SIZE;
// assign switch_kernel_addnums = o_feature_size-`S2P_SIZE+1 ;


//**********************************************************************************************************************************************

// reg [`TENSOR_SIZE :0] img2col_t_cnt;
wire result_valid_pos;
reg [`ADDR_SIZE -1 :0] base_point;



// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         img2col_t_cnt <= 0;
//     end
//     else begin
//         img2col_t_cnt <=(result_valid_pos && result_valid[1])? (img2col_t_cnt == img2col_t_num)?1 :  img2col_t_cnt+1 : img2col_t_cnt;
//     end
// end


// reg result_valid1_d1;
// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         result_valid1_d1 <= 0;
//     end
//     else begin
//         result_valid1_d1 <= result_valid[1];
//     end
// end

// assign result_valid_pos = result_valid[1] && ~ result_valid1_d1;

assign result_valid_pos = result_valid[2];





reg [$clog2(`S2P_SIZE)-1 :0] cnt;



always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        o_result_addr <= 0;
        cnt <=0;
        ena <= 0;
        base_point <= 0;
    end
    else if(result_valid[1])begin
        ena <= 1;
        if(result_valid_pos)begin
            o_result_addr <= base_point;

            base_point <=(result_valid[3])?base_point+ switch_kernel_group_addnums : base_point +  `S2P_SIZE;
            cnt <= (cnt== `S2P_SIZE-1)?0:cnt;
        end
        else if(cnt== `S2P_SIZE-1)begin
            o_result_addr <= o_result_addr +switch_kernel_addnums;
            cnt <= 0;
        end
        else if(ena)begin
            cnt <= cnt +1;
            o_result_addr <= o_result_addr +1;
        end
    end
end



always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        o_result_save <= 0;
        wea <= 0;
        w_done <= 0;
    end
    else begin
        if(conv_done)begin
            w_done <= 1;
            wea <= 0;
            o_result_save <= 0;
        end
        else begin
            wea <= result_valid[0];
            o_result_save <= result;
            w_done <= 0;
        end
        
    end
end
    
endmodule