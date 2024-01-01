
`include "../rtl/define.v"

module mul_add (
    input clk,
    input rstn,
    input start,
    input signed [`DATA_WIDTH-1 :0] op1,
    input signed [`DATA_WIDTH-1 :0] op2,
    output  reg signed [`RESULT_SIZE-1 :0] result,
    output reg finish
);



wire sign;
assign sign=op1[`DATA_WIDTH-1] ^ op2[`DATA_WIDTH-1];

reg [1:0] sign_sync;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        sign_sync <= 0;
    end
    else if(start)begin
        sign_sync <= {sign_sync[0],sign};
    end
end


// (* max_fanout = "10" *) reg [`DATA_WIDTH-1:0] op1_abs;
// (* max_fanout = "10" *) reg [`DATA_WIDTH-1:0] op2_abs;
reg [`DATA_WIDTH-1:0] op1_abs;
reg [`DATA_WIDTH-1:0] op2_abs;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        op1_abs <= 0;
        op2_abs <= 0;
    end
    else if(start)begin
        op1_abs<=op1[`DATA_WIDTH-1]?~op1+1:op1;
        op2_abs<=op2[`DATA_WIDTH-1]?~op2+1:op2;
    end
end


// wire [`DATA_WIDTH-1:0] op1_abs;
// assign op1_abs=op1[`DATA_WIDTH-1]?~op1+1:op1;

// wire [`DATA_WIDTH-1:0] op2_abs;
// assign op2_abs=op2[`DATA_WIDTH-1]?~op2+1:op2;


reg [2:0] start_result;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        start_result <= 0;
    end
    else begin
        start_result <={start_result[1],start_result[0],start};
    end
end








(*use_dsp = "yes"*) reg [`DATA_WIDTH+`DATA_WIDTH-1:0] product_pati_us;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin 
        product_pati_us <= 0;
    end
    else if(start_result[0]) begin
        product_pati_us <= op1_abs * op2_abs ;
    end
end



reg signed [`DATA_WIDTH+`DATA_WIDTH-1:0] product_pati;

reg [$clog2(`S2P_SIZE)-1 :0] count;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin 
        product_pati <= 0;
    end
    else if(start_result[1]) begin
        product_pati <= (sign_sync[1])? ~product_pati_us+1 : product_pati_us ;
    end
end



always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        count <= 0;
        result <= 0;
        finish <= 0;
    end
    else if(start_result[2])begin
        count <= (count==`S2P_SIZE-1)?0:count +1;
        finish <= (count==`S2P_SIZE-1) ;
        result<= (finish)? 0+product_pati :result + product_pati ;
    end
end

endmodule