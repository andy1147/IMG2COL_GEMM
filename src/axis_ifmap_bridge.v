

`include "../src/config.v"
module axis_ifmp_bridge #
	(
		parameter integer C_S_AXIS_TDATA_WIDTH	= 8,
                parameter integer C_M_AXIS_TDATA_WIDTH	= 8
	)(


// RECEIVE DATA FROM DMA -- AXIS S2MM PORTS 
        input wire  S_AXIS_ACLK,
        input wire  S_AXIS_ARESETN,
        output wire  S_AXIS_TREADY,
        input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
        input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
        input wire  S_AXIS_TLAST,
        input wire  S_AXIS_TVALID,



// SEND DATA TO DMA -- AXIS MM2S PORTS 
        input wire  M_AXIS_ACLK,
        input wire  M_AXIS_ARESETN,
        output wire  M_AXIS_TVALID,
        output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
        output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
        output wire  M_AXIS_TLAST,
        input wire  M_AXIS_TREADY

        
);






        
endmodule


        
