
`timescale 1 ns / 1 ps
`include "../src/config.v"

	module CONV_ACC_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 4,

		// Parameters of Axi Master Bus Interface M_T_AXIS
		parameter integer C_M_T_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Slave Bus Interface S_T_AXIS
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32

	)
	(
		// Users to add ports here
		// input conv_en,
		// output w_done,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_AXI
		input wire  s_axi_aclk,
		input wire  s_axi_aresetn,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		input wire [2 : 0] s_axi_awprot,
		input wire  s_axi_awvalid,
		output wire  s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		input wire  s_axi_wvalid,
		output wire  s_axi_wready,
		output wire [1 : 0] s_axi_bresp,
		output wire  s_axi_bvalid,
		input wire  s_axi_bready,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [2 : 0] s_axi_arprot,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rvalid,
		input wire  s_axi_rready,

		// Ports of Axi Master Bus Interface M_T_AXIS
		input wire  m_t_axis_aclk,
		input wire  m_t_axis_aresetn,
		output wire  m_t_axis_tvalid,
		output wire [C_M_T_AXIS_TDATA_WIDTH-1 : 0] m_t_axis_tdata,
		output wire [(C_M_T_AXIS_TDATA_WIDTH/8)-1 : 0] m_t_axis_tstrb,
		output wire  m_t_axis_tlast,
		input wire  m_t_axis_tready,

		// Ports of Axi Slave Bus Interface S_T_AXIS
		input wire  s_axis_aclk,
		input wire  s_axis_aresetn,
		output wire  s_axis_tready,
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb,
		input wire  s_axis_tlast,
		input wire  s_axis_tvalid

	);


	wire [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	wire [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	wire [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	wire [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire conv_en;
	wire w_done;


// Instantiation of Axi Bus Interface S_AXI
	CONV_ACC_v1_0_S_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) CONV_ACC_v1_0_S_AXI_inst (

	//extern slv_reg
		.slv_reg0(slv_reg0),
		.slv_reg1(slv_reg1),
		.slv_reg2(slv_reg2),
		.slv_reg3(slv_reg3),
		.conv_en (conv_en),
		.w_done  (w_done ),
	//

		.S_AXI_ACLK(s_axi_aclk),
		.S_AXI_ARESETN(s_axi_aresetn),
		.S_AXI_AWADDR(s_axi_awaddr),
		.S_AXI_AWPROT(s_axi_awprot),
		.S_AXI_AWVALID(s_axi_awvalid),
		.S_AXI_AWREADY(s_axi_awready),
		.S_AXI_WDATA(s_axi_wdata),
		.S_AXI_WSTRB(s_axi_wstrb),
		.S_AXI_WVALID(s_axi_wvalid),
		.S_AXI_WREADY(s_axi_wready),
		.S_AXI_BRESP(s_axi_bresp),
		.S_AXI_BVALID(s_axi_bvalid),
		.S_AXI_BREADY(s_axi_bready),
		.S_AXI_ARADDR(s_axi_araddr),
		.S_AXI_ARPROT(s_axi_arprot),
		.S_AXI_ARVALID(s_axi_arvalid),
		.S_AXI_ARREADY(s_axi_arready),
		.S_AXI_RDATA(s_axi_rdata),
		.S_AXI_RRESP(s_axi_rresp),
		.S_AXI_RVALID(s_axi_rvalid),
		.S_AXI_RREADY(s_axi_rready)
	);



	assign m_t_axis_tstrb = 4'b0001;

	assign m_t_axis_tdata[C_M_T_AXIS_TDATA_WIDTH-1 : `DATA_WIDTH] = 0;



	// Add user logic here
	wire ifmap_w_ready;
	wire weight_w_ready;

	wire [`DATA_WIDTH-1 :0] ifmap_w_data;
	wire ifmap_w_valid;
	wire ifmap_w_last;

	wire [`DATA_WIDTH-1 :0] weight_w_data;
	wire weight_w_valid;
	wire weight_w_last;



	s_axis_decoder #(
		.C_S_AXIS_TDATA_WIDTH ( C_S_AXIS_TDATA_WIDTH )
	)
	u_s_axis_decoder (
		.s_axis_aclk             ( s_axis_aclk                                      ),
		.s_axis_aresetn          ( s_axis_aresetn                                   ),
		.s_axis_tdata            ( s_axis_tdata    [C_S_AXIS_TDATA_WIDTH-1 : 0]     ),
		.s_axis_tstrb            ( s_axis_tstrb    [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] ),
		.s_axis_tlast            ( s_axis_tlast                                     ),
		.s_axis_tvalid           ( s_axis_tvalid                                    ),

		.ifmap_w_ready           ( ifmap_w_ready                                    ),
		.weight_w_ready          ( weight_w_ready                                   ),

		.s_axis_tready           ( s_axis_tready                                    ),
		.ifmap_w_data            ( ifmap_w_data    [`DATA_WIDTH-1 :0]               ),
		.ifmap_w_valid           ( ifmap_w_valid                                    ),
		.ifmap_w_last            ( ifmap_w_last                                     ),
		.weight_w_data           ( weight_w_data   [`DATA_WIDTH-1:0]                ),
		.weight_w_valid          ( weight_w_valid                                   ),
		.weight_w_last           ( weight_w_last                                    )
	);





	CONV_ACC  u_CONV_ACC (
		.clk                     (   s_axi_aclk  ),
		.rstn                    (   s_axi_aresetn   ),
		.w_done                  (   w_done          ),
	//AXI_LITE
		.enable                  (   slv_reg1[8]      ),
		.conv_en                 (   conv_en     ),
		.axi_tensor_size         (   slv_reg0[31:22]  ),
		.axi_kernel_size         (   slv_reg0[15:8] ),
		.axi_stride              (   slv_reg0[7:0]    ),

		.axi_channels            (   slv_reg1[31:22]  ),
		.axi_kernel_nums         ( 	 slv_reg1[21:12]    ),
		.shift                   (   slv_reg1[7:0]   ),

	//AXI_STREAM_SLAVE
		.ifmap_w_data            (  ifmap_w_data    [`DATA_WIDTH-1 :0] ),
		.ifmap_w_valid           (  ifmap_w_valid  ),
		.ifmap_w_last            (  ifmap_w_last ),
		.ifmap_w_ready           (  ifmap_w_ready),

		.r_ready                 (  m_t_axis_tready ),
		.r_data                  (  m_t_axis_tdata[`DATA_WIDTH-1 : 0] ),
		.r_valid                 (  m_t_axis_tvalid ),
		.r_last                  (  m_t_axis_tlast  ),

		.weight_w_ready          (  weight_w_ready  ),
		.weight_w_data           (  weight_w_data   [`DATA_WIDTH-1:0]  ),
		.weight_w_valid          (  weight_w_valid  ),
		.weight_w_last           (  weight_w_last )

	);
	// User logic ends

	endmodule
