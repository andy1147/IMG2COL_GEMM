`timescale  1ns / 1ps
`include "../rtl/define.v"

module tb_tensor_addr;

// tensor_addr Parameters
parameter PERIOD  = 10;


// tensor_addr Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   enable                               = 0 ;
reg   [`TENSOR_SIZE-1:0]  tensor_size      = 8 ;
reg   [`KERNEL_SIZE-1:0]  kernel_size      = 2 ;
reg   [`CHANNELS_SIZE-1:0]  channels       = 4 ;
reg   [`STRIDE_SIZE-1:0]  stride           = 2 ;

// tensor_addr Outputs
wire  [`ADDR_SIZE-1:0]  o_tensor_addr      ;
wire done;


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
    $dumpfile("tenosr_addr.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_tensor_addr);    //tb模块名称
end

tensor_addr  u_tensor_addr (
    .clk                     ( clk                                 ),
    .rstn                    ( rstn                                ),
    .enable                  ( enable                              ),
    .tensor_size             ( tensor_size    [`TENSOR_SIZE-1:0]   ),
    .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]   ),
    .channels                ( channels       [`CHANNELS_SIZE-1:0] ),
    .stride                  ( stride         [`STRIDE_SIZE-1:0]   ),

    .o_tensor_addr           ( o_tensor_addr  [`ADDR_SIZE-1:0]     ),
    .done                    (done                                 )
);

reg enable_sync;
always @(posedge clk) begin
    enable_sync <= enable;
end
always @(posedge clk) begin
    if(enable_sync)begin
        if(!done)begin
            $display("%d",o_tensor_addr);
        end
    end
end

initial
begin
    #(PERIOD*10000);
    $finish;
end

endmodule