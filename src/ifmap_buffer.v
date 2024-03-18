



`include "../src/config.v"


module ifmap_buffer (
//SYS CLK AND RESTEN
        input clk,  //sys
        input rstn,  //sys


// AXI_LITE
        input enable,// enable
        input conv_en,  //conv start , a pulse siginal


//write data from dma,  dma --> ram
        input [`DATA_WIDTH-1 :0] w_data,
        input w_valid,
        input w_last,
        output reg w_ready,


//read data from ram, ram --> dma
        
        input r_ready,
        output reg [`DATA_WIDTH-1 :0] r_data,
        output r_valid,
        output reg r_last,



// internal interface

        input w_done,
        input [`TENSOR_SIZE + `TENSOR_SIZE + `KERNEL_NUMS_SIZE -1 : 0]  n_ifmap_num,


// internal read tensor data
        input [`ADDR_SIZE-1:0]  tensor_addr,
        input t_addr_vld,
        output reg [`DATA_WIDTH-1 :0] tensor_data,





//internal write result data
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


reg [`ADDR_SIZE-1:0] w_addr;
reg [`ADDR_SIZE-1:0]  r_addr;
reg r_vld_delay1;
reg r_vld;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        w_addr <= 0;
    end
    else if(w_last || !w_valid)begin
        w_addr <= 0;
    end
    else if(w_valid && w_ready)begin
        w_addr <= w_addr +1;
    end

end

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        r_addr <= 0;
    end
    else if(r_last || conv_en)begin
        r_addr <= 0;
    end
    else if(r_vld && r_ready)begin
        r_addr <= (r_addr == n_ifmap_num-1)?0:r_addr +1;
    end

end



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

wire [`DATA_WIDTH -1 :0] dout1;
wire [`DATA_WIDTH -1 :0] dout2;


always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
       r_vld <= 0;
    end
    else if(conv_en || r_last)begin
       r_vld <= 0;
    end
    else if(w_done)begin
       r_vld <= 1;
    end
end


always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
       r_vld_delay1 <= 0;
    end
    else begin
       r_vld_delay1 <=r_vld;
    end
end

assign r_valid =r_vld && r_vld_delay1;



always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        w_ready <= 1;
    end
    else if(w_last)begin
        w_ready <= 0;
    end
end


always @(posedge clk) begin
    if(r_last==0 && r_ready &&r_vld && r_addr == n_ifmap_num-1)begin
        r_last <= 1;
    end
    else begin
        r_last <= 0;
    end
end

always @(*) begin

    if(w_ready && w_valid)begin
        ena1 = 1'b1;
        wea1 = 1'b1;
        addr1 = w_addr;
        din1 = w_data;


        r_data = `DATA_WIDTH'b0;
        tensor_data = `DATA_WIDTH'b0;
        
        ena2 =result_w_ena;
        wea2 = result_w_vld;
        addr2 = result_addr;
        din2 = result_data; 
    end

    else if(r_vld)begin
        if(current_state == STATE2)begin
           // ena1= 1'b1;  r_vld && r_ready
            ena1= r_vld && r_ready;
            wea1 =1'b0;
            addr1 = r_addr;
            din1 = `DATA_WIDTH'b0;
            r_data = dout1;


            ena2 =t_addr_vld;
            wea2 = 1'b0;
            addr2 = tensor_addr;
            din2 = `DATA_WIDTH'b0; 
            tensor_data = dout2; 

        end
        else begin
    //        ena2= 1'b1;
            ena2= r_vld && r_ready;
            wea2 =1'b0;
            addr2 = r_addr;
            din2 = `DATA_WIDTH'b0;
            r_data = dout2;


            ena1 = t_addr_vld;
            wea1 = 1'b0;
            addr1 = tensor_addr;
            din1 = `DATA_WIDTH'b0;
            tensor_data = dout1; 
        end
    end
    else begin
        case (current_state)
            STATE1: begin
                    ena1 = t_addr_vld;
                    wea1 = 1'b0;
                    addr1 = tensor_addr;
                    din1 = `DATA_WIDTH'b0;
                    tensor_data = dout1; 


                    ena2 =result_w_ena;
                    wea2 = result_w_vld;
                    addr2 = result_addr;
                    din2 = result_data; 

                    r_data = `DATA_WIDTH'b0; 

                
                end
            STATE2: begin


                    ena1 = result_w_ena;
                    wea1 = result_w_vld;
                    addr1 = result_addr;
                    din1 = result_data;


                    ena2 =t_addr_vld;
                    wea2 = 1'b0;
                    addr2 = tensor_addr;
                    din2 = `DATA_WIDTH'b0; 
                    tensor_data = dout2;  


                    r_data = `DATA_WIDTH'b0;               
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


                    r_data = `DATA_WIDTH'b0; 
                end
        endcase
    end

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