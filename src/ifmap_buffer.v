



`include "../rtl/define.v"
module ifmap_buffer (
        input clk,
        input rstn,
        input enable,


        input conv_en,

        input rd_o_start,
        input rd_o_finish,
        input [`ADDR_SIZE-1:0]  rd_o_addr,
        output reg [`DATA_WIDTH-1 :0] rd_o_data,



        input w_done,


        //read data
        input [`ADDR_SIZE-1:0]  tensor_addr,
        input t_addr_vld,



        output reg [`DATA_WIDTH-1 :0] tensor_data,
        output reg data_ready_done,





        //write data
        input [`ADDR_SIZE -1 :0] result_addr,
        input [`DATA_WIDTH -1 :0] result_data,
        input result_w_vld,
        input result_w_ena

);
    
localparam IDLE = 3'b001 ;
localparam STATE1 = 3'b010;
localparam STATE2 = 3'b100;


reg [2:0] current_state;
reg [2:0] next_state;


always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        current_state <= IDLE;
    end
    else if(enable)begin
        current_state <= next_state;
    end
end


always @(*) begin
    case (current_state)
        IDLE: begin
                if(conv_en)begin
                    next_state = STATE1;
                end
                else begin
                    next_state = IDLE;
                end  
            end
        STATE1:begin
                if(conv_en)begin
                    next_state = STATE2;
                end
                else begin
                    next_state = STATE1;
                end                 
            end
        STATE2:begin
                if(conv_en)begin
                    next_state = STATE1;
                end
                else begin
                    next_state = STATE2;
                end             
            end
        default: next_state = IDLE;
    endcase            
end



reg [`ADDR_SIZE -1 :0] addr1;
reg [`ADDR_SIZE -1 :0] addr2;


reg ena1;
reg ena2;

reg wea1;
reg wea2;

reg [`DATA_WIDTH -1 :0] din1;
reg [`DATA_WIDTH -1 :0] din2;

reg [`DATA_WIDTH -1 :0] dout1;
reg [`DATA_WIDTH -1 :0] dout2;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        data_ready_done <= 0;
    end
    else if(conv_en)begin
        data_ready_done <= 0;
    end
    else if(w_done)begin
        data_ready_done <= 1;
    end
end


reg read_out_vld;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        read_out_vld <= 0;
    end
    else if(rd_o_start)begin
        read_out_vld <= 1;
    end
    else if(rd_o_finish)begin
        read_out_vld <= 0;
    end
end


always @(*) begin
    case (current_state)
        STATE1: begin
                ena1 = t_addr_vld;
                wea1 = 1'b0;
                addr1 = tensor_addr;
                din1 = `DATA_WIDTH'b0;
                tensor_data = dout1; 

                if(data_ready_done && read_out_vld)begin
                    ena2 =1'b1;
                    wea2 = 1'b0;
                    addr2 = rd_o_addr;
                    rd_o_data = dout2;
                end
                else begin
                    ena2 =result_w_ena;
                    wea2 = result_w_vld;
                    addr2 = result_addr;
                    din2 = result_data;  
                end
              
            end
        STATE2: begin
                if(data_ready_done && read_out_vld)begin
                    ena1 =1'b1;
                    wea1 = 1'b0;
                    addr1 = rd_o_addr;
                    rd_o_data = dout1;
                end
                else begin
                    ena1 = result_w_ena;
                    wea1 = result_w_vld;
                    addr1 = result_addr;
                    din1 = result_data;
                end



                ena2 =t_addr_vld;
                wea2 = 1'b0;
                addr2 = tensor_addr;
                din2 = `DATA_WIDTH'b0; 
                tensor_data = dout2;                
            end
        default: begin
                ena1 = t_addr_vld;
                wea1 = 1'b0;
                addr1 = tensor_addr;
                din1 = `DATA_WIDTH'b0;
                tensor_data = dout1; 


                ena2 =result_w_ena;
                wea2 = result_w_vld;
                addr2 = result_addr;
                din2 = result_data; 
            end
    endcase
end



    ram_t0 u_RAM_tensor0(
        .clka(clk),
        .addra(addr1),
        .ena(ena1),
        .wea(wea1),
        .dina(din1),
        .douta(dout1)
    );




    ram_t1 u_RAM_tensor1(
        .clka(clk),
        .addra(addr2),
        .ena(ena2),
        .wea(wea2),
        .dina(din2),
        .douta(dout2)
    );


endmodule