




`include "../rtl/define.v"
module result_save (
    input clk,
    input rstn,
    input [`RESULT_SIZE -1 :0] result,
    input [3:0]   shift,
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
    output reg signed [`DATA_WIDTH -1 :0] o_result_save,
    output reg result_w_vld, //high valid
    output reg w_done,
    output reg result_w_ena

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

wire result_valid_pos;
reg [`ADDR_SIZE -1 :0] base_point;



assign result_valid_pos = result_valid[2];





reg [$clog2(`S2P_SIZE)-1 :0] cnt;



always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        o_result_addr <= 0;
        cnt <=0;
        result_w_ena <= 0;
        base_point <= 0;
    end
    else if(result_valid[1])begin
        result_w_ena <= 1;
        if(result_valid_pos)begin
            o_result_addr <= base_point;

            base_point <=(result_valid[3])?base_point+ switch_kernel_group_addnums : base_point +  `S2P_SIZE;
            cnt <= (cnt== `S2P_SIZE-1)?0:cnt;
        end
        else if(cnt== `S2P_SIZE-1)begin
            o_result_addr <= o_result_addr +switch_kernel_addnums;
            cnt <= 0;
        end
        else if(result_w_ena)begin
            cnt <= cnt +1;
            o_result_addr <= o_result_addr +1;
        end
    end
end




wire signed [`DATA_WIDTH-1 :0] fix_result;
assign fix_result = ($signed(result) >>> shift) > 127 ? 127 :
                    ($signed(result) >>> shift) < -128 ?-128:
                    ($signed(result) >>> shift);




always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        o_result_save <= 0;
        result_w_vld <= 0;
        w_done <= 0;
    end
    else begin
        if(conv_done)begin
            w_done <= 1;
            result_w_vld <= 0;
            o_result_save <= 0;
        end
        else begin
            result_w_vld <= result_valid[0];
            o_result_save <= fix_result;
            w_done <= 0;
        end
    end
end
    
endmodule