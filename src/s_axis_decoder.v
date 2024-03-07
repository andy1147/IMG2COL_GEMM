

`include "../src/config.v"

module s_axis_decoder #(
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32
)(

		input wire  s_axis_aclk,
		input wire  s_axis_aresetn,
		output wire  s_axis_tready,
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb,
		input wire  s_axis_tlast,
		input wire  s_axis_tvalid,


        output [`DATA_WIDTH-1 :0] ifmap_w_data,
        output ifmap_w_valid,
        output ifmap_w_last,
        input  ifmap_w_ready,



        input  weight_w_ready,
        output [`DATA_WIDTH-1:0] weight_w_data,
        output weight_w_valid,
        output weight_w_last
);

assign s_axis_tready = weight_w_ready || ifmap_w_ready;

assign ifmap_w_data = s_axis_tdata[15:8];
assign ifmap_w_valid = s_axis_tvalid && s_axis_tdata[17];
assign ifmap_w_last = s_axis_tlast;

assign weight_w_data = s_axis_tdata[7:0];
assign weight_w_valid = s_axis_tvalid && s_axis_tdata[16];
assign weight_w_last = s_axis_tlast;




endmodule