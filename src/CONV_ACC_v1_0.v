
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
		parameter integer C_M_T_AXIS_START_COUNT	= 32,

		// Parameters of Axi Slave Bus Interface S_T_AXIS
		parameter integer C_S_T_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Slave Bus Interface S_W_AXIS
		parameter integer C_S_W_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here

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
		input wire  s_t_axis_aclk,
		input wire  s_t_axis_aresetn,
		output wire  s_t_axis_tready,
		input wire [C_S_T_AXIS_TDATA_WIDTH-1 : 0] s_t_axis_tdata,
		input wire [(C_S_T_AXIS_TDATA_WIDTH/8)-1 : 0] s_t_axis_tstrb,
		input wire  s_t_axis_tlast,
		input wire  s_t_axis_tvalid,

		// Ports of Axi Slave Bus Interface S_W_AXIS
		input wire  s_w_axis_aclk,
		input wire  s_w_axis_aresetn,
		output wire  s_w_axis_tready,
		input wire [C_S_W_AXIS_TDATA_WIDTH-1 : 0] s_w_axis_tdata,
		input wire [(C_S_W_AXIS_TDATA_WIDTH/8)-1 : 0] s_w_axis_tstrb,
		input wire  s_w_axis_tlast,
		input wire  s_w_axis_tvalid
	);


	wire [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	wire [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	wire [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	wire [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;


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





	// Add user logic here
	CONV_ACC  u_CONV_ACC (
		.clk                     (   s_axi_aclk  ),
		.rstn                    (   s_axi_aresetn   ),

	//AXI_LITE
		.enable                  (   slv_reg0[31]      ),
		.conv_en                 (   slv_reg0[30]   ),
		.axi_tensor_size         (   slv_reg0[29:20]  ),
		.axi_kernel_size         (   slv_reg1[6:0] ),
		.axi_channels            (   slv_reg0[19:10]  ),
		.axi_stride              (   slv_reg1[13:7]    ),
		.axi_kernel_nums         ( 	 slv_reg0[9:0]    ),
		.shift                   (   slv_reg1[21:14]   ),

	//AXI_STREAM_SLAVE
		.ifmap_w_data            (  s_t_axis_tdata[`DATA_WIDTH-1 : 0] ),
		.ifmap_w_valid           (  s_t_axis_tvalid  ),
		.ifmap_w_last            (  s_t_axis_tlast ),
		.ifmap_w_ready           (  s_t_axis_tready),

		.r_ready                 (  m_t_axis_tready ),
		.r_data                  (  m_t_axis_tdata[`DATA_WIDTH-1 : 0] ),
		.r_valid                 (  m_t_axis_tvalid ),
		.r_last                  (  m_t_axis_tlast  ),

		.weight_w_ready          (  s_w_axis_tready  ),
		.weight_w_data           (  s_w_axis_tdata[`DATA_WIDTH-1 : 0] ),
		.weight_w_valid          (  s_w_axis_tvalid  ),
		.weight_w_last           (  s_w_axis_tlast )

	);
	// User logic ends

	endmodule
