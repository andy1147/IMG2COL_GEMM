

`include "../src/config.v"
`include "../src/local_define.v"
module ram_w (
    input clka,
    input [`ADDR_SIZE-1 :0] addra,
    input ena,
    input wea,
    input [`DATA_WIDTH-1:0] dina,
    output reg [`DATA_WIDTH-1:0] douta
);

//integer i;
reg [`DATA_WIDTH-1:0] mem [0:`MEM_LENGTH-1];


`ifdef SIM
integer i;
initial begin
  for(i=0;i<= `MEM_LENGTH -1; i= i+1)begin
    mem[i] <= 0;
  end
end
`endif 
//`ifdef SIM_DETAIL
//  initial begin
//      //$readmemb("C:/Users/Qdream/OneDrive/Projects/IMG2COL/python/img2col/data/9weight_bin.txt",mem);
//      $readmemb($sformatf({`DATA_PATH,"%0dweight_bin.txt"},`DETAIL_NUM),mem);
//  end
//`endif 

//`ifdef SIM_ALL
//  reg [`SIM_GROUP_NUMS_SIZE-1:0] count=0;

//  always @(posedge ena) begin
//      $readmemb($sformatf({`DATA_PATH,"%0dweight_bin.txt"},count),mem);
//      count<=count+1;
//  end
//`endif 




always @(posedge clka)  begin
    if(ena)begin
      if(wea==1)begin
        mem[addra]<=dina;
      end
      else if(wea==0)begin
        douta<=mem[addra];
      end
    end
end

    

endmodule