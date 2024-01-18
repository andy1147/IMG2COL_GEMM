

`include "../src/config.v"

module para_prepare (

        input clk,
        input rstn,
        input start,

        input [`TENSOR_SIZE-1:0] tensor_size, 
        input [`KERNEL_SIZE-1:0] kernel_size, 
        input [`CHANNELS_SIZE-1:0] channels, 
        input [`STRIDE_SIZE-1:0] stride, 
        input [`KERNEL_NUMS_SIZE-1 :0] kernel_nums,
        output enable,
        output o_rstn,


        //to tensor_addr
        // output [`KERNEL_SIZE-1:0] o_t_addr_ks,
        // output [`STRIDE_SIZE-1:0] o_t_addr_s,
        output [`S2P_SIZE-1 : 0] o_t_addr_itlr,
        output [`TENSOR_SIZE + `STRIDE_SIZE -1 :0] o_t_addr_tms,
        output [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] o_t_addr_brn,
        output reg [`TENSOR_SIZE-1:0] o_t_addr_ofs,
        output [`ADDR_SIZE-1:0] o_t_addr_sran,
        output [`ADDR_SIZE-1:0] o_t_addr_scan,

        //to weight_addr
        output [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] o_w_addr_bcn,
        output [`KERNEL_NUMS_SIZE-1 : 0] o_w_addr_brn,
        output [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 :0] o_w_addr_iww,
        output [`S2P_SIZE-1 : 0] o_w_addr_knr,
        output [`S2P_SIZE-1 : 0] o_w_addr_iwwr,


        //to matrix_add
        output [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] o_mat_add_man,
        // output [`TENSOR_SIZE*2 :0] o_mat_add_itn,
        // output [`KERNEL_NUMS_SIZE-1 :0] o_mat_add_iwn,
        // output [`TENSOR_SIZE*2+`KERNEL_NUMS_SIZE :0] o_mat_add_rbn,
        output [`S2P_SIZE -1 :0] o_mat_add_itmln,
        //output [`S2P_SIZE -1 :0] o_mat_add_iwmln,


        //to result_process
        //output [`TENSOR_SIZE*2 :0] o_res_pro_itn,
        //output [`ADDR_SIZE-1:0] o_res_pro_ofs,
        output [`ADDR_SIZE-1:0] o_res_pro_skga,
        output [`ADDR_SIZE-1:0] o_res_pro_ska

        
);


// assign o_t_addr_ks = (start)? kernel_size :0;
// assign o_t_addr_s = (start)? stride : 0;



(*use_dsp = "yes"*)reg [`TENSOR_SIZE + `STRIDE_SIZE -1 :0] t_addr_tms ;
reg t_addr_tms_done;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        t_addr_tms <= 0;
        t_addr_tms_done <= 0;
    end
    else if(start)begin
        t_addr_tms <= tensor_size * stride ;
        t_addr_tms_done <= 1;
    end
end
assign o_t_addr_tms = t_addr_tms;




reg K_K_done;
reg [`KERNEL_SIZE + `KERNEL_SIZE -1 :0] K_K;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        K_K <= 0;
        K_K_done <= 0;
    end
    else if(start)begin
        K_K <= kernel_size * kernel_size;
        K_K_done <= 1 ;
    end
end


(*use_dsp = "yes"*)reg [`KERNEL_SIZE + `KERNEL_SIZE +`CHANNELS_SIZE -1 :0] K_K_C;
reg K_K_C_done;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        K_K_C <= 0;
        K_K_C_done <= 0;
    end
    else if(K_K_done)begin
        K_K_C_done <= 1;
        K_K_C <= K_K * channels;
    end
end


reg t_addr_brn_done;
(* DONT_TOUCH="TRUE" *) reg [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] t_addr_brn;
(* DONT_TOUCH="TRUE" *) reg [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] w_addr_bcn;
(* DONT_TOUCH="TRUE" *) reg [`KERNEL_SIZE+`KERNEL_SIZE+`CHANNELS_SIZE-1 : 0] mat_add_man;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        t_addr_brn <= 0;
        w_addr_bcn <= 0;
        mat_add_man <= 0;
        t_addr_brn_done <= 0;
    end
    else if(K_K_C_done)begin
        t_addr_brn <= (K_K_C % `S2P_SIZE ==0)?((K_K_C >>> $clog2(`S2P_SIZE))-1):(K_K_C >>> $clog2(`S2P_SIZE));
        w_addr_bcn <= (K_K_C % `S2P_SIZE ==0)?((K_K_C >>> $clog2(`S2P_SIZE))-1):(K_K_C >>> $clog2(`S2P_SIZE)); 
        mat_add_man <= (K_K_C % `S2P_SIZE ==0)?((K_K_C >>> $clog2(`S2P_SIZE))-1):(K_K_C >>> $clog2(`S2P_SIZE));
        t_addr_brn_done <=1;
    end
end

assign o_t_addr_brn = t_addr_brn;


//********************t_addr_ofs
reg [`TENSOR_SIZE-1:0] t_addr_ofs;
reg t_addr_ofs_done;
reg [`TENSOR_SIZE-1:0] temp;
reg [`TENSOR_SIZE-1:0] count;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        temp<=0;
        count<=0;
        t_addr_ofs_done<=0;
        t_addr_ofs<=0;
    end
    else if (start && !t_addr_ofs_done )begin
        
        temp<=temp+stride;
        count<=count+1;
        if(temp==tensor_size-kernel_size)begin
            t_addr_ofs<=count +1;
            t_addr_ofs_done<=1;
        end
        else if(temp>tensor_size-kernel_size)begin
            t_addr_ofs<=count;
            t_addr_ofs_done<=1;
        end
    end
    else begin
        t_addr_ofs<=t_addr_ofs;
        count<=count;
        t_addr_ofs_done<=t_addr_ofs_done;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        o_t_addr_ofs <= 0;
    end
    else if(t_addr_ofs_done)begin
        o_t_addr_ofs <= t_addr_ofs -1 ;
    end
end
//assign o_t_addr_ofs = t_addr_ofs -1;

//***************_t_addr_sran
reg [`ADDR_SIZE-1:0] t_addr_sran;
reg t_addr_sran_done;

always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        t_addr_sran <= 0;
        t_addr_sran_done <=0;
    end
    else if(start)begin
        t_addr_sran <= tensor_size - kernel_size +1 ;
        t_addr_sran_done <=1;
    end
end
assign o_t_addr_sran = t_addr_sran;

//**************************t_addr_scan
(*use_dsp = "yes"*)reg [`ADDR_SIZE-1:0] t_addr_scan;
reg t_addr_scan_done;
reg [`TENSOR_SIZE-1 :0] T_sub_K;
reg T_sub_K_done;
reg [`TENSOR_SIZE-1 :0] T_add_1;
reg T_add_1_done;

always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        T_sub_K <= 0;
        T_add_1 <= 0;
        T_add_1_done <= 0;
        T_sub_K_done <= 0;
    end
    else if(start)begin
        T_sub_K <= tensor_size-kernel_size;
        T_add_1 <= tensor_size +1;
        T_sub_K_done <= 1;
        T_add_1_done <=1;
    end
end
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        t_addr_scan <= 0;
        t_addr_scan_done <= 0;
    end
    else if(T_add_1_done && T_sub_K_done)begin
        t_addr_scan <= T_sub_K * T_add_1 +1;
        t_addr_scan_done <=1;
    end
end

assign o_t_addr_scan = t_addr_scan;

//********************w_addr_bcn

assign o_w_addr_bcn = w_addr_bcn;


//*******************w_addr_brn
reg [`KERNEL_NUMS_SIZE-1 : 0] w_addr_brn;
//reg [`KERNEL_NUMS_SIZE-1 : 0] mat_add_iwn;
reg w_addr_brn_done;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        w_addr_brn <= 0;
        w_addr_brn_done <= 0;
       // mat_add_iwn <= 0;
    end
    else if(start)begin
        w_addr_brn <= (kernel_nums % `S2P_SIZE ==0)? kernel_nums >>> $clog2(`S2P_SIZE):
                   (kernel_nums >>> $clog2(`S2P_SIZE)) +1;
       // mat_add_iwn <= (kernel_nums % `S2P_SIZE ==0)? kernel_nums >>> $clog2(`S2P_SIZE):
      //             (kernel_nums >>> $clog2(`S2P_SIZE)) +1;
        w_addr_brn_done <= 1;     
    end
end
assign o_w_addr_brn = w_addr_brn;

//*******************o_w_addr_iww
assign o_w_addr_iww = K_K_C;

//***********************w_addr_knr   w_addr_iwwr
reg [`S2P_SIZE-1 : 0] w_addr_knr;
reg w_addr_knr_done;
reg w_addr_iwwr_done;
reg [`S2P_SIZE-1 : 0] w_addr_iwwr;
reg [`S2P_SIZE-1 : 0] t_addr_itlr;

always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        w_addr_knr <= 0;
        w_addr_iwwr <= 0;
        t_addr_itlr <= 0;
        w_addr_knr_done <=0;
        w_addr_iwwr_done <= 0;

    end
    else if(K_K_C_done)begin
        w_addr_knr <= (kernel_nums % `S2P_SIZE)-1;
        w_addr_iwwr <= (K_K_C % `S2P_SIZE) -1;
        t_addr_itlr <= (K_K_C % `S2P_SIZE) -1;
        w_addr_knr_done <=1;
        w_addr_iwwr_done <= 1;
    end
end
assign o_w_addr_knr = w_addr_knr;
assign o_w_addr_iwwr = w_addr_iwwr;

//***********************************mat_add_man

assign o_mat_add_man = mat_add_man;

//**************************************mat_add_itn
reg [`TENSOR_SIZE*2 :0] mat_add_itn;
(*use_dsp = "yes"*)reg [`TENSOR_SIZE*2 :0] T_sub_K_div_S2;
reg T_sub_K_div_S2_done;
reg mat_add_itn_done;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        T_sub_K_div_S2 <= 0;
        T_sub_K_div_S2_done <= 0;
    end
    else if(t_addr_ofs_done)begin
        T_sub_K_div_S2 <= (t_addr_ofs) * (t_addr_ofs);
        T_sub_K_div_S2_done <= 1;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        mat_add_itn_done <= 0;
        mat_add_itn <= 0;
    end
    else if(T_sub_K_div_S2_done)begin
        mat_add_itn <= (T_sub_K_div_S2 % `S2P_SIZE==0)?T_sub_K_div_S2>>>$clog2(`S2P_SIZE):
                           (T_sub_K_div_S2>>>$clog2(`S2P_SIZE))+1;  
        mat_add_itn_done <= 1;       
    end
end

// assign o_mat_add_itn = mat_add_itn;

//assign o_mat_add_iwn = mat_add_iwn;

// reg [`TENSOR_SIZE*2+`KERNEL_NUMS_SIZE :0] mat_add_rbn;
// reg mat_add_rbn_done;

// always @(posedge clk or negedge rstn) begin
//     if(!rstn || !start)begin
//         mat_add_rbn <= 0;
//         mat_add_rbn_done <= 0;
//     end
//     else if(mat_add_itn_done && w_addr_brn_done)begin
//         mat_add_rbn <= mat_add_itn * o_mat_add_iwn;
//         mat_add_rbn_done <= 1;
//     end
// end
// assign o_mat_add_rbn = mat_add_rbn;


reg [`S2P_SIZE -1 :0] mat_add_itmln;
reg  mat_add_itmln_done;
//reg [`S2P_SIZE -1 :0] mat_add_iwmln;
//reg mat_add_iwmln_done;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        mat_add_itmln <= 0;
      //  mat_add_iwmln <= 0;
        mat_add_itmln_done <= 0;
      //  mat_add_iwmln_done <= 0;
    end
    else begin
        // if(w_addr_knr_done)begin
        //     mat_add_iwmln <= w_addr_knr +1;
        //     mat_add_iwmln_done <=1;
        // end
        if(T_sub_K_div_S2_done)begin
            mat_add_itmln <= T_sub_K_div_S2 % `S2P_SIZE ;
            mat_add_itmln_done <= 1;
        end
    end
end
assign o_mat_add_itmln = mat_add_itmln;
//assign o_mat_add_iwmln = mat_add_iwmln ;



//*****************************************************
//assign o_res_pro_itn = mat_add_itn;
//assign o_res_pro_ofs = T_sub_K_div_S2;

reg [`ADDR_SIZE-1:0] res_pro_skga;
reg res_pro_skga_done;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        res_pro_skga <= 0;
        res_pro_skga_done <= 0;
    end
    else if(T_sub_K_div_S2_done && mat_add_itn_done)begin
        res_pro_skga <= (T_sub_K_div_S2 - mat_add_itn +1) <<<$clog2(`S2P_SIZE);
        res_pro_skga_done <=1;
    end
end
assign o_res_pro_skga= res_pro_skga;


reg [`ADDR_SIZE-1:0] res_pro_ska;
reg res_pro_ska_done;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        res_pro_ska <= 0;
        res_pro_ska_done <= 0;
    end
    else if(T_sub_K_div_S2_done)begin
        res_pro_ska <= T_sub_K_div_S2 -`S2P_SIZE +1 ;
        res_pro_ska_done <= 1;
    end
end
assign o_res_pro_ska=res_pro_ska;


reg reg_enable;
always @(posedge clk or negedge rstn) begin
    if(!rstn || !start)begin
        reg_enable <= 0;
    end
    else if(res_pro_skga_done)begin
        reg_enable <= 1;
    end
end

assign enable = reg_enable;

assign o_rstn = enable;

assign o_t_addr_itlr = t_addr_itlr;
    
endmodule