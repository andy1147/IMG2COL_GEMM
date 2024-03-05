


`include "../src/config.v"
module weight_buffer (
    input clk,
    input rstn,


//AXI_BUS
    input enable,
    input conv_en,

//internal interface
    input w_done,


//dma write port.. dma--> ram
    output reg w_ready,
    
    input [`DATA_WIDTH-1:0] w_data,
    input w_valid,
    input w_last,


//intenal interface
    input [`ADDR_SIZE-1:0]  weight_addr,
    input w_addr_vld,
    output reg [`DATA_WIDTH-1:0] weight_data



);
    


reg [`ADDR_SIZE -1 :0] addr;
reg ena;
reg wea;
reg [`DATA_WIDTH -1 :0] din;
wire [`DATA_WIDTH -1 :0] dout;



reg[`ADDR_SIZE-1:0] w_addr ;

always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        w_addr <= 0;
    end
    else if(w_last)begin
        w_addr <= 0;
    end
    else if(w_valid && w_ready)begin
        w_addr <= w_addr +1;
    end

end


always @(*) begin
    if(w_ready && w_valid)begin
        ena = 1'b1;
        wea = 1'b1;
        addr = w_addr;
        din = w_data;     

        weight_data = `DATA_WIDTH'b0;    
    end
    else begin
        ena = w_addr_vld;
        wea = 1'b0;
        addr = weight_addr;
        din = `DATA_WIDTH'b0;
        weight_data = dout; 
    end
end




always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        w_ready <= 1;
    end
    else if(w_last)begin
        w_ready <= 0;
    end
    else if(conv_en)begin
        w_ready <= 0;
    end
    else if(w_done)begin
        w_ready <=1;
    end
end




    ram_w u_RAM_weight(
        .clka(clk),
        .addra(addr),
        .ena(ena),
        .wea(wea),
        .dina(din),
        .douta(dout)
    );


endmodule