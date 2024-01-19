
`include "../src/config.v"





//add if(done),base_point and base_point_change_col reset;  read_padding_flag flag_s2p_size_col_cnt resset    2023.12.5
// change done siginal;                                       2023.12.5

// add output port o_addr_valid and padding_valid       2023.12.10
// fix the error at padding_flag,delay 1 clk, avoid the last data missing. 2023.12.11

// change kernel_size_row_cnt and kernel_col_cnt priority ,when (next_sate is SWITCH_RF) and  kernel_col/row_cnt full, choose SWITCH_RF 2023.12.12
// add (current_state==SWITCH_CHANNEL) for generate buffer_rightside. fix error when current state is SWITCH_CHANNEL on s2p_row_cnt full 2023.12.12

//add if(done), then col_cnt and row_cnt clear. 2023.12.13
//delete buffer_row_nums port   , matrix_add module generate by itself                2023.12.14


//fix when ((out_feature_size)+1) % `S2P_SIZE ==0, read_padding_flag <=1; but padding_flag == 0; entrue o_tensor_done can be generate ; 2023.12.18



`define STATE_SIZE 6


module tensor_addr 

(

  input clk,
  input rstn,
  input enable,

//   input [`TENSOR_SIZE-1:0] tensor_size, 
//   input [`KERNEL_SIZE-1:0] kernel_size,
//   input [`CHANNELS_SIZE-1:0] channels, 
//   input [`STRIDE_SIZE-1:0] stride, 


  input [`KERNEL_SIZE-1:0] kernel_size,
  input [`STRIDE_SIZE-1:0] stride, 
  input [`S2P_SIZE-1 : 0] img2col_t_length_rem,
  input [`TENSOR_SIZE + `STRIDE_SIZE -1 :0] t_mul_s,
  input [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] buffer_row_nums,
  input [`TENSOR_SIZE-1:0] out_feature_size,
  input [`ADDR_SIZE-1:0]  switch_row_add_nums,
  input [`ADDR_SIZE-1 : 0] switch_channel_add_nums,


  output  [`ADDR_SIZE-1:0]  o_tensor_addr,
  output  o_tensor_done,
  output  reg o_addr_valid,
  output reg padding_valid
);



// wire [`S2P_SIZE-1 : 0] img2col_t_length_rem;
// assign img2col_t_length_rem = (kernel_size * kernel_size *channels) %`S2P_SIZE-1 ;


// wire [`TENSOR_SIZE + `STRIDE_SIZE -1 :0] t_mul_s;
// assign t_mul_s = stride *tensor_size;

// //total nums for all buffer row
// wire [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] buffer_row_nums;
// assign buffer_row_nums = ((kernel_size * kernel_size *channels) %`S2P_SIZE==0)? (kernel_size * kernel_size *channels)/`S2P_SIZE :
//                             (kernel_size * kernel_size *channels)/`S2P_SIZE +1;  ///shift to realize /


// wire [`TENSOR_SIZE-1:0] out_feature_size;
// assign out_feature_size= (tensor_size-kernel_size)/stride ;


// wire [`ADDR_SIZE-1:0]  switch_row_add_nums;
// assign switch_row_add_nums = tensor_size -kernel_size +1;



// wire [`ADDR_SIZE-1 : 0] switch_channel_add_nums;
// assign switch_channel_add_nums = tensor_size * tensor_size - (kernel_size-1)*(tensor_size+1);







//**************************************************************************************************************


// Priority : NEXT_BUFFER > RF > CHANNEL > ROW > ADD

localparam IDLE = `STATE_SIZE'h1;
localparam SELF_ADD = `STATE_SIZE'h2;
localparam SWITCH_ROW=  `STATE_SIZE'h4;
localparam SWITCH_RF =  `STATE_SIZE'd8;
localparam SWITCH_NEXT_BUFF =  `STATE_SIZE'd16;
localparam SWITCH_CHANNEL=  `STATE_SIZE'd32;

reg done;


// current state and next state
reg [`STATE_SIZE-1 : 0] current_state;
reg [`STATE_SIZE-1 : 0] next_state;
reg [`ADDR_SIZE-1 : 0] tensor_addr;



//for each buffer,count for their row and col
(* max_fanout = "10" *) reg [`S2P_SIZE-1 : 0] s2p_size_row_cnt;
reg [`S2P_SIZE-1 : 0] s2p_size_col_cnt; 


// buffer row count in entir matrix
reg [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] buffer_cnt; 



//count for kerenl_size row and col, to change channel or  break ADD_SELF
(* DONT_TOUCH="TRUE" *)reg [`KERNEL_SIZE-1 :0 ] kernel_size_row_cnt;
(* DONT_TOUCH="TRUE" *)reg [`KERNEL_SIZE-1 :0 ] kernel_size_col_cnt;

(* DONT_TOUCH="TRUE" *)reg [`KERNEL_SIZE-1 :0 ] kernel_size_row_cnt_rep;
(* DONT_TOUCH="TRUE" *)reg [`KERNEL_SIZE-1 :0 ] kernel_size_col_cnt_rep;



// for each rf, count for their row and col
reg [`TENSOR_SIZE-1:0] row_cnt;
reg [`TENSOR_SIZE-1:0] col_cnt;


//for each buffer, base_point is the most left col (the position in s2p_size_row_cnt==0)
reg [`ADDR_SIZE-1 : 0] base_point;



//for each buffer, base_point is the most right col (the position in s2p_size_row_cnt==`S2P_SIZE -1)
//To produce the base_point in next buffer
reg [`ADDR_SIZE-1 : 0] buffer_rightside [0: `S2P_SIZE-1];



//for each buffer, their count must be sync in every s2p_size_col_cnt
reg [`KERNEL_SIZE-1 :0 ] kernel_size_row_cnt_save;
reg [`KERNEL_SIZE-1 :0 ] kernel_size_col_cnt_save;
reg [`ADDR_SIZE-1 : 0] row_cnt_save;
reg [`ADDR_SIZE-1 : 0] col_cnt_save;



//for buffer0(the most left col of the matrix ), save base_point when row_cnt is full
reg [`ADDR_SIZE-1:0] base_point_change_col;




//save information
integer i;
reg [`ADDR_SIZE -1 : 0] base_point_left_down_buff0;

reg flag_if_SWITCH_ROW;
reg flag_if_SWITCH_CHANNEL;

wire end_padding_flag;



wire padding_flag;
reg ready_padding_flag;
reg [`S2P_SIZE-1 : 0] flag_s2p_size_col_cnt;




//**************************************************************************************************************


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
        s2p_size_col_cnt <= 0;
        s2p_size_row_cnt <= 0;
        buffer_cnt <= 0;
    end
    else if(enable)begin
            s2p_size_row_cnt <= (s2p_size_row_cnt == `S2P_SIZE-1) ?  0 : s2p_size_row_cnt +1;

            s2p_size_col_cnt <= (s2p_size_col_cnt == `S2P_SIZE-1 && s2p_size_row_cnt == `S2P_SIZE-1) ?  0 :
                            (s2p_size_row_cnt == `S2P_SIZE-1)? s2p_size_col_cnt +1 : 
                            s2p_size_col_cnt;
            buffer_cnt <= (s2p_size_row_cnt == `S2P_SIZE-1 && s2p_size_col_cnt == `S2P_SIZE-1)? 
                            (buffer_cnt==buffer_row_nums)?0:buffer_cnt+1 :buffer_cnt;
        // end 
    end
end





always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        kernel_size_row_cnt <= 0;
        kernel_size_col_cnt <= 0;
        kernel_size_row_cnt_rep <= 0;
        kernel_size_col_cnt_rep <= 0;
    end
    else if(enable)begin


            if(next_state ==SWITCH_RF)begin
                kernel_size_col_cnt <= kernel_size_col_cnt_save;
            end
            else if(buffer_cnt==buffer_row_nums && next_state==SWITCH_NEXT_BUFF)begin
                kernel_size_col_cnt <=0;
            end
            else begin
                kernel_size_col_cnt <= (kernel_size_col_cnt==kernel_size-1 && kernel_size_row_cnt==kernel_size-1)?0:
                                        (kernel_size_row_cnt==kernel_size-1)?kernel_size_col_cnt +1 : kernel_size_col_cnt;
            end


            if(next_state ==SWITCH_RF)begin
                kernel_size_col_cnt_rep <= kernel_size_col_cnt_save;
            end
            else if(buffer_cnt==buffer_row_nums && next_state==SWITCH_NEXT_BUFF)begin
                kernel_size_col_cnt_rep <=0;
            end
            else begin
                kernel_size_col_cnt_rep <= (kernel_size_col_cnt_rep==kernel_size-1 && kernel_size_row_cnt_rep==kernel_size-1)?0:
                                        (kernel_size_row_cnt_rep==kernel_size-1)?kernel_size_col_cnt_rep +1 : kernel_size_col_cnt_rep;
            end
            // else if(kernel_size_col_cnt==kernel_size-1 && kernel_size_row_cnt==kernel_size-1)begin
            //     kernel_size_col_cnt <=0;
            // end
            // else if(kernel_size_row_cnt==kernel_size-1)begin //other state
            //     kernel_size_col_cnt <= kernel_size_col_cnt +1;
            // end






            if(next_state == SWITCH_RF)begin
                kernel_size_row_cnt <= kernel_size_row_cnt_save;
            end
            else if(buffer_cnt==buffer_row_nums && next_state==SWITCH_NEXT_BUFF)begin
                kernel_size_row_cnt <= 0;
            end
            else begin
                kernel_size_row_cnt <= (kernel_size_row_cnt==kernel_size-1)? 0 : kernel_size_row_cnt +1;
            end



            if(next_state == SWITCH_RF)begin
                kernel_size_row_cnt_rep <= kernel_size_row_cnt_save;
            end
            else if(buffer_cnt==buffer_row_nums && next_state==SWITCH_NEXT_BUFF)begin
                kernel_size_row_cnt_rep <= 0;
            end
            else begin
                kernel_size_row_cnt_rep <= (kernel_size_row_cnt_rep==kernel_size-1)? 0 : kernel_size_row_cnt_rep +1;
            end
            // else if(next_state == SELF_ADD)begin
            //     kernel_size_row_cnt <= (kernel_size_row_cnt==kernel_size-1)? 0 : kernel_size_row_cnt +1;
            // end
            // else if(next_state == SWITCH_NEXT_BUFF)begin
            //     kernel_size_row_cnt <= (kernel_size_row_cnt==kernel_size-1)? 0 : kernel_size_row_cnt +1;
            // end

            // else begin // next_state == SWITCH_ROW and next_state == SWITCH_CHANNEL 
            //     kernel_size_row_cnt <= (kernel_size_row_cnt==kernel_size-1)? 0 : kernel_size_row_cnt;
            // end

    end
end




always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        row_cnt <= 0;
        col_cnt <= 0;
    end
    else if(enable)begin
        if(done)begin
            row_cnt <= 0;
            col_cnt <= 0;
        end

        // else if(buffer_cnt== buffer_row_nums && (s2p_size_row_cnt == `S2P_SIZE-1 && s2p_size_col_cnt == `S2P_SIZE-1))begin //next buffer col
        //     row_cnt <= (row_cnt==out_feature_size)? 0: row_cnt+1 ;
        //     col_cnt <= (col_cnt==out_feature_size && row_cnt==out_feature_size)? 0:
        //                  (row_cnt==out_feature_size)?col_cnt+1 :col_cnt;
        // end
        // else if((s2p_size_row_cnt == `S2P_SIZE-1 && s2p_size_col_cnt == `S2P_SIZE-1)) begin
        //     row_cnt <= row_cnt_save;
        //     col_cnt <= col_cnt_save;
        // end
        // else if( (s2p_size_row_cnt == `S2P_SIZE-1))begin
        //     row_cnt <= (row_cnt==out_feature_size)? 0: row_cnt+1 ;
        //     col_cnt <= (col_cnt==out_feature_size && row_cnt==out_feature_size)? 0:
        //                  (row_cnt==out_feature_size)?col_cnt+1 :col_cnt;
        // end


        else if(s2p_size_row_cnt == `S2P_SIZE-1)begin
            if(buffer_cnt!=buffer_row_nums && s2p_size_col_cnt == `S2P_SIZE-1)begin
                row_cnt <= row_cnt_save;
                col_cnt <= col_cnt_save;
            end
            else begin
                row_cnt <= (row_cnt==out_feature_size)? 0: row_cnt+1 ;
                col_cnt <= (col_cnt==out_feature_size && row_cnt==out_feature_size)? 0:
                         (row_cnt==out_feature_size)?col_cnt+1 :col_cnt;
            end
            
        end

    end
end







always @(posedge clk or negedge rstn) begin
    if(!rstn)begin

        for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
            buffer_rightside[i]<=0;
        end        

        kernel_size_row_cnt_save <= 0;
        kernel_size_col_cnt_save <= 0;

        row_cnt_save <= 0;
        col_cnt_save <= 0;

        base_point_change_col <= 0;

        base_point_left_down_buff0 <=0;

    end
    else if(enable)begin

        if(buffer_cnt==0 && s2p_size_row_cnt ==0 && s2p_size_col_cnt == `S2P_SIZE -1 )begin
            base_point_left_down_buff0 <= base_point;
        end

        if(s2p_size_row_cnt == `S2P_SIZE -1)begin
            buffer_rightside[0] <= (current_state==SWITCH_CHANNEL)? tensor_addr+ switch_channel_add_nums :
                            (current_state==SWITCH_ROW)?(tensor_addr + switch_row_add_nums):tensor_addr+1;
            for(i=1;i<=`S2P_SIZE-1;i=i+1)begin
                buffer_rightside[i]<=buffer_rightside[i-1];
            end
        end

        
        if (s2p_size_col_cnt==0 && s2p_size_row_cnt ==0)begin
            kernel_size_row_cnt_save <= kernel_size_row_cnt_rep;
            kernel_size_col_cnt_save <= kernel_size_col_cnt_rep;
        end


        if(buffer_cnt==0 && s2p_size_col_cnt==0 && s2p_size_row_cnt ==0)begin
            row_cnt_save <= row_cnt;
            col_cnt_save <= col_cnt;
        end


        if(done)begin
            base_point_change_col <= 0;            //next then initial
        end
        // else if(row_cnt ==out_feature_size && ((buffer_cnt==0 && next_state == SWITCH_RF) || (buffer_cnt== buffer_row_nums && next_state == SWITCH_NEXT_BUFF)))begin
        //     base_point_change_col <= base_point_change_col + t_mul_s;
        // end

        else if(((row_cnt ==out_feature_size) && (s2p_size_row_cnt == `S2P_SIZE-1)) && ((buffer_cnt==0)&& (s2p_size_col_cnt != `S2P_SIZE-1)|| ((buffer_cnt== buffer_row_nums) && (s2p_size_col_cnt == `S2P_SIZE-1))))begin
            base_point_change_col <= base_point_change_col + t_mul_s;
        end

        // else if( buffer_cnt==0 && next_state == SWITCH_RF && row_cnt ==out_feature_size)begin
        //     base_point_change_col <= base_point_change_col + t_mul_s;
        // end

        // else if(buffer_cnt== buffer_row_nums && next_state == SWITCH_NEXT_BUFF)begin
        //     if(row_cnt == out_feature_size)begin
        //         base_point_change_col <= base_point_change_col + t_mul_s;
        //     end
        // end


    end
end









always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        base_point <= 0;
        flag_if_SWITCH_ROW <=0;
        flag_if_SWITCH_CHANNEL <= 0;

    end
    else if(enable)begin

        if(done)begin
            base_point <=0;   //next then initial
        end

        else if(buffer_cnt ==0 && next_state ==SWITCH_RF)begin
            if(row_cnt == out_feature_size)begin
                base_point <= base_point_change_col + t_mul_s ;
            end
            else begin
                base_point <= base_point + stride;
            end
        end




        else if( buffer_cnt != 0 && next_state== SWITCH_RF)begin
            if(flag_if_SWITCH_CHANNEL)begin
                base_point <=buffer_rightside[`S2P_SIZE -2] + switch_channel_add_nums;
            end
            else if(flag_if_SWITCH_ROW)begin 
                base_point <=  buffer_rightside[`S2P_SIZE -2] + switch_row_add_nums;
            end
            else begin
                base_point<= buffer_rightside[`S2P_SIZE -2] +1;
            end
        end


        else if(buffer_cnt== buffer_row_nums && next_state == SWITCH_NEXT_BUFF)begin
            if(row_cnt == out_feature_size)begin
                base_point <= base_point_change_col + t_mul_s ;
            end
            else begin
                base_point <= base_point_left_down_buff0 + stride;//////  
            end
        end


        else if(next_state == SWITCH_NEXT_BUFF )begin
            if(kernel_size_col_cnt_rep==kernel_size-1 && kernel_size_row_cnt_rep==kernel_size-1)begin //
                base_point <=buffer_rightside[`S2P_SIZE -2] + switch_channel_add_nums;
                flag_if_SWITCH_CHANNEL <=1;
                flag_if_SWITCH_ROW <=0;
            end   
            else if(kernel_size_row_cnt_rep== kernel_size-1)begin //need to fix
                base_point <=  buffer_rightside[`S2P_SIZE -2] + switch_row_add_nums;
                flag_if_SWITCH_ROW <=1;
                flag_if_SWITCH_CHANNEL <=0;
            end
            else begin
                base_point<= buffer_rightside[`S2P_SIZE -2] +1;
                flag_if_SWITCH_ROW <= 0;
                flag_if_SWITCH_CHANNEL <=0;
            end    

        end
    end
end









always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        ready_padding_flag <=0;
        flag_s2p_size_col_cnt<=0;
    end
    else if(enable)begin
        if(done)begin
            ready_padding_flag <=0;
            flag_s2p_size_col_cnt<=0;
        end
        else if(buffer_cnt==0)begin
            // if(((out_feature_size)+1) % `S2P_SIZE ==0)begin
            //     ready_padding_flag <=0;
            //     flag_s2p_size_col_cnt<=0;
            // end
            if(ready_padding_flag)begin
                flag_s2p_size_col_cnt <= flag_s2p_size_col_cnt;
            end
            else if(row_cnt == out_feature_size && col_cnt==out_feature_size)begin
                flag_s2p_size_col_cnt<=s2p_size_col_cnt;
                ready_padding_flag <=1;
            end
        end
    end
end



// assign padding_flag=(ready_padding_flag)? 
//                 (s2p_size_col_cnt>flag_s2p_size_col_cnt)?1:0
//                 :0;

assign padding_flag=(ready_padding_flag && ((out_feature_size)+1) % `S2P_SIZE ==0)? 0:
                (ready_padding_flag)?(s2p_size_col_cnt>flag_s2p_size_col_cnt)?1:0
                :0;







assign end_padding_flag = (buffer_cnt==buffer_row_nums)? 
                            (s2p_size_row_cnt>img2col_t_length_rem) ? 1 : 0
                            : 0;











always @(posedge clk or  negedge rstn) begin
    if(!rstn) begin          
        current_state <= IDLE;       
    end       
    else if (enable)begin           
        current_state <= next_state;    
    end   
end





always @(*) begin
    case(current_state)
        IDLE: begin
            next_state = (enable)? SELF_ADD:IDLE;
        end
        SELF_ADD: begin

            if(s2p_size_row_cnt == `S2P_SIZE-1 && s2p_size_col_cnt == `S2P_SIZE-1)begin
                next_state = SWITCH_NEXT_BUFF;
            end
            else if(s2p_size_row_cnt == `S2P_SIZE-1)begin
                next_state = SWITCH_RF;
            end
            else if(kernel_size_col_cnt==kernel_size-1 && kernel_size_row_cnt==kernel_size-1)begin
                next_state = SWITCH_CHANNEL;
            end
            else if(kernel_size_row_cnt== kernel_size-1)begin
                next_state = SWITCH_ROW;
            end
            else begin
                next_state = SELF_ADD;
            end  
        end

        SWITCH_ROW :begin


            if(s2p_size_row_cnt == `S2P_SIZE-1 && s2p_size_col_cnt == `S2P_SIZE-1)begin
                next_state = SWITCH_NEXT_BUFF;
            end
            else if(s2p_size_row_cnt == `S2P_SIZE-1)begin
                next_state = SWITCH_RF;
            end
            else if(kernel_size_col_cnt==kernel_size-1 && kernel_size_row_cnt==kernel_size-1)begin
                next_state = SWITCH_CHANNEL;
            end
            else begin
                next_state = SELF_ADD;
            end

        end

        SWITCH_RF:begin

            if(kernel_size_col_cnt==kernel_size-1 && kernel_size_row_cnt==kernel_size-1)begin
                next_state = SWITCH_CHANNEL;
            end

            else if(kernel_size_row_cnt== kernel_size-1)begin
                next_state = SWITCH_ROW;
            end
            else begin
                next_state = SELF_ADD;
            end
        end

        SWITCH_NEXT_BUFF:begin
            if(kernel_size_col_cnt==kernel_size-1 && kernel_size_row_cnt==kernel_size-1)begin
                next_state = SWITCH_CHANNEL;
            end

            else if(kernel_size_row_cnt== kernel_size-1)begin
                next_state = SWITCH_ROW;
            end
            else begin
                next_state = SELF_ADD;
            end
        end
        SWITCH_CHANNEL:begin
            if(s2p_size_row_cnt == `S2P_SIZE-1 && s2p_size_col_cnt == `S2P_SIZE-1)begin
                next_state = SWITCH_NEXT_BUFF;
            end
            else if(s2p_size_row_cnt == `S2P_SIZE-1)begin
                next_state = SWITCH_RF;
            end
            else if(kernel_size_row_cnt== kernel_size-1)begin
                next_state = SWITCH_ROW;
            end
            else begin
                next_state = SELF_ADD;
            end 
        end
        default: next_state = IDLE;
    endcase
end






always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        tensor_addr <= 0;
    end
    else if(enable)begin
        if(end_padding_flag)begin
            tensor_addr <= 0;
        end
        else if(padding_flag)begin
            tensor_addr <= 0;
        end
        else begin
            case(current_state)
                IDLE:begin
                    tensor_addr<=0;
                end
                SELF_ADD:begin
                    tensor_addr <= tensor_addr +1;
                end
                SWITCH_ROW:begin
                    tensor_addr <= tensor_addr + switch_row_add_nums;
                end
                SWITCH_RF:begin
                    tensor_addr <= base_point;
                end
                SWITCH_NEXT_BUFF:begin
                    tensor_addr <= base_point;
                end
                SWITCH_CHANNEL:begin
                    tensor_addr <= tensor_addr + switch_channel_add_nums;//(kernel_size-1)*(tensor_size+1) + tensor_size*tensor_size is constant
                end
                default:tensor_addr <= tensor_addr;

            endcase
        end

    end
end

assign o_tensor_addr =tensor_addr;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        padding_valid <= 0;
    end
    else if(enable)begin
        padding_valid <= end_padding_flag || padding_flag;
    end
end
//assign padding_valid = end_padding_flag || padding_flag;


// reg done_temp;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        // done_temp <=0;
         done <= 0;
    end
    else if(enable)begin
        if(ready_padding_flag && buffer_cnt==buffer_row_nums && s2p_size_col_cnt==`S2P_SIZE-1 && s2p_size_row_cnt==`S2P_SIZE-2)begin //base_point clear in time,can not change
            // done_temp <=1;
            done <=1;
        end
        else begin
            done <= 0;
        end
    end

    // else begin
    //     done <= done_temp;
    // end
end

assign o_tensor_done = done;


// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         o_result_valid_fix <= 0;
//     end
//     else if(o_tensor_done && padding_flag)begin
//         o_result_valid_fix <= 1;
//     end
// end



endmodule