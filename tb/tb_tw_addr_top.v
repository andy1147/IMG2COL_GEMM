
`include "../rtl/define.v"
`timescale  1ns / 1ps

module tb_tw_addr_top;

// tw_addr_top Parameters
parameter PERIOD  = 10;


// tw_addr_top Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   enable                               = 0 ;
reg   [`TENSOR_SIZE-1:0]  tensor_size      = 8 ;
reg   [`KERNEL_SIZE-1:0]  kernel_size      = 3 ;
reg   [`CHANNELS_SIZE-1:0]  channels       = 3 ;
reg   [`STRIDE_SIZE-1:0]  stride           = 2 ;
reg   [`KERNEL_NUMS_SIZE-1 :0]  kernel_nums = 10 ;

// tw_addr_top Outputs
wire  [`ADDR_SIZE-1:0]  o_tensor_addr      ;
wire  [`ADDR_SIZE-1:0]  o_weight_addr      ;



initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
    #(18) enable=1;
end

initial
begin            
    $dumpfile("tw_addr_top.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_tw_addr_top);    //tb模块名称
end




tw_addr_top  u_tw_addr_top (
    .clk                     ( clk                                     ),
    .rstn                    ( rstn                                    ),
    .enable                  ( enable                                  ),
    .tensor_size             ( tensor_size    [`TENSOR_SIZE-1:0]       ),
    .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]       ),
    .channels                ( channels       [`CHANNELS_SIZE-1:0]     ),
    .stride                  ( stride         [`STRIDE_SIZE-1:0]       ),
    .kernel_nums             ( kernel_nums    [`KERNEL_NUMS_SIZE-1 :0] ),

    .o_tensor_addr           ( o_tensor_addr  [`ADDR_SIZE-1:0]         ),
    .o_weight_addr           ( o_weight_addr  [`ADDR_SIZE-1:0]         )
);

reg [`ADDR_SIZE-1:0] tensor_addr_save [0 : `S2P_SIZE-1];
reg [`ADDR_SIZE-1:0] weight_addr_save [0 : `S2P_SIZE-1];
reg [$clog2(`S2P_SIZE) :0] count=0;

reg enable_delay1 =0;
always @(posedge clk) begin
    enable_delay1<=enable;
end

always @(posedge clk) begin
    if(enable_delay1)begin
        count<=(count==`S2P_SIZE)?1:count+1;
    end
end

integer i;
always @(posedge clk or negedge rstn) begin
    if(!rstn)begin
        
        for(i=0;i<=`S2P_SIZE-1;i=i+1)begin
            tensor_addr_save[i]<= 0;
            weight_addr_save[i] <= 0;
        end
    end
    if(enable_delay1)begin
        tensor_addr_save [0] <= o_tensor_addr;
        weight_addr_save [0] <= o_weight_addr;
        for(i=1;i<=`S2P_SIZE-1;i=i+1)begin
            tensor_addr_save[i]<= tensor_addr_save[i-1];
            weight_addr_save[i] <= weight_addr_save[i-1];
        end
    end
end

initial begin
    $display("                                                                                            T");
end
integer count_buffer=0;
always @(posedge clk) begin
    if(enable_delay1)begin
        if(count==`S2P_SIZE)begin
            count_buffer<=(count_buffer==`S2P_SIZE-1)?0:count_buffer+1;

            
            $display("%4d %4d %4d %4d %4d %4d %4d %4d           %4d %4d %4d %4d %4d %4d %4d %4d",
            tensor_addr_save[7],tensor_addr_save[6],tensor_addr_save[5],tensor_addr_save[4],
            tensor_addr_save[3],tensor_addr_save[2],tensor_addr_save[1],tensor_addr_save[0],
            weight_addr_save[7],weight_addr_save[6],weight_addr_save[5],weight_addr_save[4],
            weight_addr_save[3],weight_addr_save[2],weight_addr_save[1],weight_addr_save[0]);

            if(count_buffer==`S2P_SIZE-1)begin
                $display("                                ");
                $display("                                ");
                $display("                                                                                            T");
            end
        end
    end
end



initial
begin
    #(PERIOD * 10000)
    $finish;
end

endmodule