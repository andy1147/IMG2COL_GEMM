



`include "../rtl/define.v"
module ram_save (
    input clka,
    input [`ADDR_SIZE-1 :0] addra,
    input ena,
    input wea,
    input [`RESULT_SIZE-1:0] dina,
    output reg [`RESULT_SIZE-1:0] douta
);


reg [`RESULT_SIZE-1:0] mem [0:`MEM_LENGTH-1];




//string path;
always @(posedge clka )  begin
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