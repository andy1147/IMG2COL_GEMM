


`include "../src/config.v"

module ctrl_unit (

    //from axi bus
        input clk,     //sys
        input rstn,  //sys
        input enable, //sys enbale
        input conv_en,//sys_conv ,a impluse siginal

        input [`TENSOR_SIZE-1:0] axi_tensor_size, 
        input [`KERNEL_SIZE-1:0] axi_kernel_size, 
        input [`CHANNELS_SIZE-1:0] axi_channels, 
        input [`STRIDE_SIZE-1:0] axi_stride, 
        input [`KERNEL_NUMS_SIZE-1 :0] axi_kernel_nums,

    //from self
        input w_done,
        input n_para_done,
        input [`TENSOR_SIZE-1:0] n_ofs, 


        output reg [`TENSOR_SIZE-1:0] tensor_size, 
        output reg [`KERNEL_SIZE-1:0] kernel_size, 
        output reg [`CHANNELS_SIZE-1:0] channels, 
        output reg [`STRIDE_SIZE-1:0] stride, 
        output reg [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,


        output reg start_conv,  // the conv circuit start work;

        output reg [`TENSOR_SIZE-1:0] n_tensor_size


        
        
);
    

    localparam IDLE = 3'b001;
    localparam FIRST_CONV = 3'b010;
    localparam NEXT_CONV= 3'b100;






//reg [`TENSOR_SIZE-1:0] n_tensor_size;
reg [`CHANNELS_SIZE-1:0] n_channels;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        n_tensor_size <= 0;
        n_channels <= 0;
    end
    else if(n_para_done)begin
        n_tensor_size <= n_ofs +1;
        n_channels <= axi_kernel_nums;
    end
end






    reg [2:0] current_state;
    reg [2:0] next_state;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            current_state <= IDLE;
        end
        else if(enable) begin
            current_state <= next_state;
        end
    end




    always @(*) begin
        case (current_state)
            IDLE: begin
                if(conv_en)begin
                    next_state = FIRST_CONV;
                end
                else begin
                    next_state = IDLE;
                end
            end
            FIRST_CONV:begin
                if(conv_en)begin
                    next_state = NEXT_CONV;
                end
                else begin
                    next_state = FIRST_CONV;
                end
            end
            NEXT_CONV:begin
                if(conv_en)begin
                    next_state = NEXT_CONV;
                end
                else begin
                    next_state = NEXT_CONV;
                end
            end
            default: next_state = IDLE;
        endcase
    end

reg conv_en_sync1;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        conv_en_sync1 <= 0;
    end
    else if(enable)begin
        conv_en_sync1 <= conv_en;
    end
end

always @(posedge clk ) begin
    if(conv_en_sync1 && current_state==FIRST_CONV)begin
        tensor_size <= axi_tensor_size;
        kernel_size <= axi_kernel_size;
        channels <= axi_channels;
        stride <= axi_stride;
        kernel_nums <= axi_kernel_nums;
    end
    else if(conv_en_sync1 && current_state == NEXT_CONV) begin
        tensor_size <= n_tensor_size;
        kernel_size <= axi_kernel_size;
        channels <= n_channels;
        stride <= axi_stride;
        kernel_nums <= axi_kernel_nums;
    end
end



reg start_conv_reg;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        start_conv_reg <= 0;
    end
    else if(conv_en)begin
        start_conv_reg <= 1;
    end
    else if(w_done)begin
        start_conv_reg <= 0;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        start_conv <= 0;
    end
    else if(enable)begin
        start_conv <= start_conv_reg;
    end
end


endmodule