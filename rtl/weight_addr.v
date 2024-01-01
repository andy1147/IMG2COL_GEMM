


`include "../rtl/define.v"

//add tensor_done siginal .; if(tensor_done) then buffer_row_cnt +1 and next buffer row.
// fix the error at padding_flag,delay 1 clk, avoid the last data missing. 2023.12.11

`define STATE_SIZE 6
module weight_addr (
    input clk,
    input rstn,
    input enable,

    
    input tensor_done,

    // input [`KERNEL_SIZE-1:0] kernel_size, 
    // input [`CHANNELS_SIZE-1:0] channels,  
    // input [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,


    input [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] buffer_col_nums,
    input [`KERNEL_NUMS_SIZE-1 : 0] buffer_row_nums,
    input [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0] img2col_w_width,
    input [`S2P_SIZE-1 : 0] kernel_nums_rem,
    input [`S2P_SIZE-1 : 0] img2col_w_width_rem,


    output  [`ADDR_SIZE-1:0]  o_weight_addr,
    output reg o_addr_valid,
    output reg padding_valid,
    output o_weight_done
);




// wire [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] buffer_col_nums;
// assign buffer_col_nums = ((kernel_size * kernel_size *channels) %`S2P_SIZE==0)? (kernel_size * kernel_size *channels)/`S2P_SIZE :
//                             (kernel_size * kernel_size *channels)/`S2P_SIZE +1;  ///shift to realize /

// wire [`KERNEL_NUMS_SIZE-1 : 0] buffer_row_nums;
// assign buffer_row_nums = kernel_nums % `S2P_SIZE ==0 ? kernel_nums/`S2P_SIZE : kernel_nums/`S2P_SIZE +1;

// wire [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0] img2col_w_width;
// assign img2col_w_width = kernel_size*kernel_size*channels;


// wire [`S2P_SIZE-1 : 0] kernel_nums_rem;
// wire [`S2P_SIZE-1 : 0] img2col_w_width_rem;

// assign kernel_nums_rem = (kernel_nums % `S2P_SIZE)-1 ;
// assign img2col_w_width_rem = (kernel_size*kernel_size*channels % `S2P_SIZE) -1;



//********************************************************************************************************
localparam IDLE = `STATE_SIZE'd1 ;
localparam SELF_ADD = `STATE_SIZE'd2 ;
localparam SWITCH_KERNEL = `STATE_SIZE'd4 ;
localparam SWITCH_BUFFER = `STATE_SIZE'd8;
//localparam SWITCH_BUFFER = `STATE_SIZE'd16;



reg [`ADDR_SIZE-1 :0] weight_addr;

reg [`ADDR_SIZE-1 :0] base_point;

reg [`STATE_SIZE-1 : 0] current_state;
reg [`STATE_SIZE-1 : 0] next_state;




//for each buffer,count for their row and col
reg [`S2P_SIZE-1 : 0] s2p_size_row_cnt;
reg [`S2P_SIZE-1 : 0] s2p_size_col_cnt; 


// buffer row count in entir matrix
reg [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] buffer_col_cnt; 
reg [`KERNEL_NUMS_SIZE-1 : 0] buffer_row_cnt; 





//********************************************************************************************************





wire s2p_size_col_cnt_full;
assign s2p_size_col_cnt_full = s2p_size_col_cnt==`S2P_SIZE-1;
wire s2p_size_row_cnt_full;
assign s2p_size_row_cnt_full = s2p_size_row_cnt==`S2P_SIZE-1;



always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        o_addr_valid<=0;
    end
    else begin
        o_addr_valid <= enable;
    end
    
end


always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        s2p_size_row_cnt <= 0;
        s2p_size_col_cnt <= 0;
        buffer_col_cnt <= 0;
        buffer_row_cnt <= 0;
    end
    else if(enable)begin
            s2p_size_col_cnt <= (s2p_size_col_cnt_full) ?  0 : s2p_size_col_cnt +1;

            s2p_size_row_cnt <= (s2p_size_row_cnt_full && s2p_size_col_cnt_full) ?  0 :
                            (s2p_size_col_cnt_full)? s2p_size_row_cnt +1 : 
                            s2p_size_row_cnt;
            buffer_col_cnt <= (s2p_size_row_cnt_full && s2p_size_col_cnt_full)? 
                            (buffer_col_cnt==buffer_col_nums)?0:buffer_col_cnt+1 :buffer_col_cnt;
            buffer_row_cnt <= (tensor_done && buffer_col_cnt == buffer_col_nums && buffer_row_cnt==buffer_row_nums-1 && s2p_size_row_cnt_full && s2p_size_col_cnt_full)? 0 :
                                (tensor_done && buffer_col_cnt == buffer_col_nums && s2p_size_row_cnt_full && s2p_size_col_cnt_full) ? 
                                buffer_row_cnt +1 :
                                buffer_row_cnt;
        // end 
    end
end




reg [`ADDR_SIZE -1 :0] base_point_left_down;
reg [`ADDR_SIZE -1 :0] base_point_right_up;
reg [`ADDR_SIZE -1 :0] base_point_left_up;


always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        base_point_left_down <= 0;
        base_point_right_up <= 0;
        base_point_left_up <=0;
    end
    else if (enable)begin
        
        if(s2p_size_col_cnt_full && s2p_size_row_cnt==0)begin
            base_point_left_down <= weight_addr +1;
        end

        if(s2p_size_col_cnt==0 && s2p_size_row_cnt_full && buffer_col_cnt == 0)begin
            base_point_right_up <= base_point;
        end
        if(buffer_col_cnt == 0 && s2p_size_col_cnt==0 && s2p_size_row_cnt==0)begin
            base_point_left_up <= base_point;
        end
    end
    
end


always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        base_point <= 0;
    end
    else if(enable)begin
        if(buffer_col_cnt == buffer_col_nums && next_state ==SWITCH_BUFFER)begin
            if(tensor_done)begin
                base_point <= base_point_right_up + img2col_w_width;
            end
            else begin
                base_point <= base_point_left_up;
            end
            
        end
        else if(next_state == SWITCH_BUFFER)begin
            base_point <= base_point_left_down + 1;
        end
        else if(next_state == SWITCH_KERNEL)begin
            base_point <= base_point + img2col_w_width;
        end
    end
    
end



wire padding_flag;
wire end_padding_flag;



assign end_padding_flag = (buffer_row_cnt== buffer_row_nums-1) ? (s2p_size_row_cnt > kernel_nums_rem ) : 0;

assign padding_flag = (buffer_col_cnt == buffer_col_nums)? (s2p_size_col_cnt > img2col_w_width_rem) : 0; //when kkc%8==0, then -1 is very large(1111111) . so keep 0;




always @(posedge clk or  negedge rstn) begin
    if(!rstn) begin          
        current_state <= IDLE;       
    end       
    else if (enable)begin           
        current_state <= next_state;    
    end   
end


always @(*) begin
    case (current_state)
        IDLE:begin
            next_state = SELF_ADD;
        end
        SELF_ADD:begin
            if(s2p_size_col_cnt_full && s2p_size_row_cnt_full)begin
                next_state = SWITCH_BUFFER;
            end
            else if(s2p_size_col_cnt==`S2P_SIZE -1)begin
                next_state = SWITCH_KERNEL;
            end
            else begin
                next_state = SELF_ADD;
            end
        end 
        SWITCH_BUFFER:begin
            next_state = SELF_ADD;
        end
        SWITCH_KERNEL: begin
            next_state = SELF_ADD;
        end
        default:next_state=IDLE ;
    endcase
    
end



always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        weight_addr <= 0;
    end
    else if(enable)begin
        if(padding_flag || end_padding_flag)begin
            weight_addr <= 0;
        end
        else begin
            case (current_state)
                IDLE:begin
                    weight_addr <= 0;
                end
                SELF_ADD:begin
                    weight_addr <= weight_addr +1;
                end
                SWITCH_KERNEL:begin
                    weight_addr <= base_point; 
                end 
                SWITCH_BUFFER:begin
                    weight_addr <= base_point ;
                end
                default: weight_addr <= 0;
            endcase
        end
    end

end

// reg done_temp;
// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         done_temp <=0;
//         done <= 0;
//     end
//     else if( tensor_done && buffer_row_cnt==buffer_row_nums-1 && buffer_col_cnt==buffer_col_nums-1 && s2p_size_col_cnt==`S2P_SIZE-1 && s2p_size_row_cnt==`S2P_SIZE-1)begin
//         done_temp <=1;
//     end
//     else begin
//         done <= done_temp;
//     end
// end

assign o_weight_done = tensor_done && buffer_row_cnt==buffer_row_nums-1;

assign o_weight_addr = weight_addr;
    
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        padding_valid <= 0;
    end
    else if(enable)begin
        padding_valid <= end_padding_flag || padding_flag;
    end
end


endmodule