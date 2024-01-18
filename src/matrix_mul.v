


`include "../src/config.v"

module matrix_mul 


(
    input clk,
    input rstn,
    (* max_fanout = "50" *) input flag_buffer,  //pluse
    input [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] tensor_data,
    input [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] weight_data,

    output  [`S2P_SIZE* `RESULT_SIZE -1 : 0] matrix_product,
    output  [1:0] matrix_mul_done
);





integer i;

reg [`S2P_SIZE**2 * `DATA_WIDTH -1 : 0] tensor_data_sync;
reg [`S2P_SIZE* `DATA_WIDTH -1 : 0] weight_data_sync [0 : `S2P_SIZE-1];

always @(posedge clk or negedge rstn) begin
  if(!rstn)begin
        tensor_data_sync <= 0;
        for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
            weight_data_sync[i]<= 0;
        end
  end
  else if(flag_buffer)begin
    //tensor_data_sync <= tensor_data;
    tensor_data_sync <= weight_data;  ///two output mode for matrix result output

    for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
        //weight_data_sync[i]<= weight_data[(`S2P_SIZE**2 * `DATA_WIDTH -1)- i*(`S2P_SIZE*`DATA_WIDTH) -: `S2P_SIZE*`DATA_WIDTH];
        weight_data_sync[i]<= tensor_data[(`S2P_SIZE**2 * `DATA_WIDTH -1)- i*(`S2P_SIZE*`DATA_WIDTH) -: `S2P_SIZE*`DATA_WIDTH];
    end

  end
  else begin
        tensor_data_sync <= {tensor_data_sync[(`S2P_SIZE**2-1)* `DATA_WIDTH -1 :0] , `DATA_WIDTH'b0};

        for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
            weight_data_sync[i]<= {weight_data_sync[i][`S2P_SIZE* `DATA_WIDTH -1 - `DATA_WIDTH : 0] , weight_data_sync[i][`S2P_SIZE* `DATA_WIDTH -1 -: `DATA_WIDTH]};
        end
  end  

end


reg compute_start;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        compute_start <= 0;
    end
    else if(flag_buffer)begin
        compute_start <= 1;/// keep siginal
    end
end


// wire [`RESULT_SIZE-1 :0] pati_result [0 : `S2P_SIZE-1] ;
wire [`S2P_SIZE-1 :0] finish;

genvar k;
generate
    
    for(k=0;k<=`S2P_SIZE-1 ; k=k+1)begin
        mul_add u_mul_add(
            .clk(clk),
            .rstn(rstn),
            .start(compute_start),
            .op1( tensor_data_sync[`S2P_SIZE**2 * `DATA_WIDTH -1 -: `DATA_WIDTH]  ),
            .op2( weight_data_sync[k][`S2P_SIZE* `DATA_WIDTH -1 -: `DATA_WIDTH] ),
            .result( matrix_product[`S2P_SIZE* `RESULT_SIZE -1 - k*`RESULT_SIZE -: `RESULT_SIZE] ),
            .finish( finish[k])
        );
    end
endgenerate

reg [$clog2(`S2P_SIZE)-1 :0] finish_cnt;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        finish_cnt <= 0;
    end
    else if(&finish)begin
        finish_cnt <= (finish_cnt == `S2P_SIZE-1)?0:finish_cnt+1;
    end
end
assign matrix_mul_done[1] = (&finish) && finish_cnt==`S2P_SIZE-1;
assign matrix_mul_done[0]=&finish;



// reg [(`S2P_SIZE * `RESULT_SIZE -1 ) :0] buffer_result [0 : `S2P_SIZE-1];
// reg [$clog2(`S2P_SIZE) : 0] buffer_result_row_cnt;

// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         buffer_result_row_cnt <= 0;
//         for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
//             buffer_result[i] <= 0;
//         end
//     end
//     else if(&finish)begin
//         buffer_result_row_cnt <= (buffer_result_row_cnt==`S2P_SIZE)? 1 : buffer_result_row_cnt+1;
//         for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
//             buffer_result[0][ (`S2P_SIZE * `RESULT_SIZE -1 ) - i*(`RESULT_SIZE) -: `RESULT_SIZE ] <= pati_result[i];
//         end
//         for(i=1;i<=`S2P_SIZE-1;i=i+1)begin
//             buffer_result[i] <= buffer_result[i-1];
//         end
        
//     end
// end



// reg matrix_mul_done_temp;

// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         matrix_product <= 0;
//         matrix_mul_done_temp <= 0;
//     end
//     else if(buffer_result_row_cnt==`S2P_SIZE)begin
//         for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
//             matrix_product[`S2P_SIZE**2 * `RESULT_SIZE -1 - i* (`S2P_SIZE * `RESULT_SIZE) -: `S2P_SIZE * `RESULT_SIZE] <= buffer_result[`S2P_SIZE-1-i];
//         end
//         matrix_mul_done_temp <= 1;
//     end
//     else begin
//         matrix_mul_done_temp <= 0;
//         matrix_product <= matrix_product;
//     end
// end


// reg matrix_mul_done_temp_sync;
// always @(posedge clk or negedge rstn) begin
//     if(!rstn)begin
//         matrix_mul_done_temp_sync <= 0;
//     end
//     else begin
//         matrix_mul_done_temp_sync <= matrix_mul_done_temp;
//     end
// end

// assign matrix_mul_done = matrix_mul_done_temp && ~matrix_mul_done_temp_sync;
    
endmodule