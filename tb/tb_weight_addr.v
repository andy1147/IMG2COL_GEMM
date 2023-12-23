`timescale  1ns / 1ps
`include "../rtl/define.v"
module tb_weight_addr;

// weight_addr Parameters
parameter PERIOD  = 10;


// weight_addr Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   enable                               = 0 ;
reg   [`KERNEL_SIZE-1:0]  kernel_size      = 2 ;
reg   [`CHANNELS_SIZE-1:0]  channels       = 3 ;
reg   [`KERNEL_NUMS_SIZE-1 :0]  kernel_nums = 10 ;

// weight_addr Outputs
wire  [`ADDR_SIZE-1:0]  o_weight_addr      ;
wire  done                                 ;


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
    $dumpfile("weight_addr.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_weight_addr);    //tb模块名称
end

weight_addr  u_weight_addr (
    .clk                     ( clk                                     ),
    .rstn                    ( rstn                                    ),
    .enable                  ( enable                                  ),
    .kernel_size             ( kernel_size    [`KERNEL_SIZE-1:0]       ),
    .channels                ( channels       [`CHANNELS_SIZE-1:0]     ),
    .kernel_nums             ( kernel_nums    [`KERNEL_NUMS_SIZE-1 :0] ),

    .o_weight_addr           ( o_weight_addr  [`ADDR_SIZE-1:0]         ),
    .done                    ( done                                    )
);

initial
begin
    #(PERIOD * 10000);

    $finish;
end

endmodule