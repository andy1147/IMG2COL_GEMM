
`timescale  1ns / 1ps
`include "../src/local_define.v"

module tb_CONV_ACC_v1_0;

// CONV_ACC_v1_0 Parameters
parameter PERIOD                  = 10;
parameter C_S_AXI_DATA_WIDTH      = 32;
parameter C_S_AXI_ADDR_WIDTH      = 4 ;
parameter C_M_T_AXIS_TDATA_WIDTH  = 32;
parameter C_S_AXIS_TDATA_WIDTH    = 32;

// CONV_ACC_v1_0 Inputs
reg   conv_en                              = 0 ;



reg   s_axi_aclk                           = 0 ;
reg   s_axi_aresetn                        = 0 ;
reg   [C_S_AXI_ADDR_WIDTH-1 : 0]  s_axi_awaddr = 0 ;
reg   [2 : 0]  s_axi_awprot                = 0 ;
reg   s_axi_awvalid                        = 0 ;
reg   [C_S_AXI_DATA_WIDTH-1 : 0]  s_axi_wdata = 0 ;
reg   [(C_S_AXI_DATA_WIDTH/8)-1 : 0]  s_axi_wstrb = 4'b1111 ;
reg   s_axi_wvalid                         = 0 ;
reg   s_axi_bready                         = 0 ;
reg   [C_S_AXI_ADDR_WIDTH-1 : 0]  s_axi_araddr = 0 ;
reg   [2 : 0]  s_axi_arprot                = 0 ;
reg   s_axi_arvalid                        = 0 ;
reg   s_axi_rready                         = 0 ;
reg   m_t_axis_aclk                        = 0 ;
reg   m_t_axis_aresetn                     = 0 ;
reg   m_t_axis_tready                      = 0 ;
reg   s_axis_aclk                          = 0 ;
reg   s_axis_aresetn                       = 0 ;
reg   [C_S_AXIS_TDATA_WIDTH-1 : 0]  s_axis_tdata = 0 ;
reg   [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0]  s_axis_tstrb = 4'b1111 ;
reg   s_axis_tlast                         = 0 ;
reg   s_axis_tvalid                        = 0 ;

// CONV_ACC_v1_0 Outputs
wire  s_axi_awready                        ;
wire  s_axi_wready                         ;
wire  [1 : 0]  s_axi_bresp                 ;
wire  s_axi_bvalid                         ;
wire  s_axi_arready                        ;
wire  [C_S_AXI_DATA_WIDTH-1 : 0]  s_axi_rdata ;
wire  [1 : 0]  s_axi_rresp                 ;
wire  s_axi_rvalid                         ;
wire  m_t_axis_tvalid                      ;
wire  [C_M_T_AXIS_TDATA_WIDTH-1 : 0]  m_t_axis_tdata ;
wire  [(C_M_T_AXIS_TDATA_WIDTH/8)-1 : 0]  m_t_axis_tstrb ;
wire  m_t_axis_tlast                       ;
wire  s_axis_tready                        ;


initial
begin
    forever #(PERIOD/2)  s_axi_aclk=~s_axi_aclk;
end

initial
begin
    #(PERIOD*2) s_axi_aresetn  =  1;
end

initial
begin            
    $dumpfile("CONV_ACC_v1_0.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_CONV_ACC_v1_0);    //tb模块名称
end



CONV_ACC_v1_0 #(
    .C_S_AXI_DATA_WIDTH     ( C_S_AXI_DATA_WIDTH     ),
    .C_S_AXI_ADDR_WIDTH     ( C_S_AXI_ADDR_WIDTH     ),
    .C_M_T_AXIS_TDATA_WIDTH ( C_M_T_AXIS_TDATA_WIDTH ),
    .C_S_AXIS_TDATA_WIDTH   ( C_S_AXIS_TDATA_WIDTH   ))
 u_CONV_ACC_v1_0 (
    .s_axi_aclk              ( s_axi_aclk                                           ),
    .s_axi_aresetn           ( s_axi_aresetn                                        ),
    .s_axi_awaddr            ( s_axi_awaddr      [C_S_AXI_ADDR_WIDTH-1 : 0]         ),
    .s_axi_awprot            ( s_axi_awprot      [2 : 0]                            ),
    .s_axi_awvalid           ( s_axi_awvalid                                        ),
    .s_axi_wdata             ( s_axi_wdata       [C_S_AXI_DATA_WIDTH-1 : 0]         ),
    .s_axi_wstrb             ( s_axi_wstrb       [(C_S_AXI_DATA_WIDTH/8)-1 : 0]     ),
    .s_axi_wvalid            ( s_axi_wvalid                                         ),
    .s_axi_bready            ( s_axi_bready                                         ),
    .s_axi_araddr            ( s_axi_araddr      [C_S_AXI_ADDR_WIDTH-1 : 0]         ),
    .s_axi_arprot            ( s_axi_arprot      [2 : 0]                            ),
    .s_axi_arvalid           ( s_axi_arvalid                                        ),
    .s_axi_rready            ( s_axi_rready                                         ),
    .m_t_axis_aclk           ( m_t_axis_aclk                                        ),
    .m_t_axis_aresetn        ( m_t_axis_aresetn                                     ),
    .m_t_axis_tready         ( m_t_axis_tready                                      ),
    .s_axis_aclk             ( s_axis_aclk                                          ),
    .s_axis_aresetn          ( s_axis_aresetn                                       ),
    .s_axis_tdata            ( s_axis_tdata      [C_S_AXIS_TDATA_WIDTH-1 : 0]       ),
    .s_axis_tstrb            ( s_axis_tstrb      [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0]   ),
    .s_axis_tlast            ( s_axis_tlast                                         ),
    .s_axis_tvalid           ( s_axis_tvalid                                        ),

    .s_axi_awready           ( s_axi_awready                                        ),
    .s_axi_wready            ( s_axi_wready                                         ),
    .s_axi_bresp             ( s_axi_bresp       [1 : 0]                            ),
    .s_axi_bvalid            ( s_axi_bvalid                                         ),
    .s_axi_arready           ( s_axi_arready                                        ),
    .s_axi_rdata             ( s_axi_rdata       [C_S_AXI_DATA_WIDTH-1 : 0]         ),
    .s_axi_rresp             ( s_axi_rresp       [1 : 0]                            ),
    .s_axi_rvalid            ( s_axi_rvalid                                         ),
    .m_t_axis_tvalid         ( m_t_axis_tvalid                                      ),
    .m_t_axis_tdata          ( m_t_axis_tdata    [C_M_T_AXIS_TDATA_WIDTH-1 : 0]     ),
    .m_t_axis_tstrb          ( m_t_axis_tstrb    [(C_M_T_AXIS_TDATA_WIDTH/8)-1 : 0] ),
    .m_t_axis_tlast          ( m_t_axis_tlast                                       ),
    .s_axis_tready           ( s_axis_tready                                        )
);


integer fid_tensor ;
integer fid_weight ;
integer fid_para;
reg [39:0] para=0;

integer errors = 0;
reg [7:0] soft_data;
integer fid_result ;

initial
begin
    wait(s_axi_aresetn);

    fid_result=$fopen($sformatf({`DATA_PATH,"%0dresult_dec.txt"},2),"r");
    // fid_tensor=$fopen($sformatf({`DATA_PATH,"%0dtensor_bin.txt"},`DETAIL_NUM),"r");
    // fid_weight=$fopen($sformatf({`DATA_PATH,"%0dweight_bin.txt"},`DETAIL_NUM),"r");
    // fid_para=$fopen($sformatf({`DATA_PATH,"%0dpara.txt"},`DETAIL_NUM),"r");
    // $fscanf(fid_para,"%b",para);
    // $fclose(fid_para);
    // fork
    //     send_ifmap(0);
    //     send_weight(0);
    // join
    send_ifmap_weight(0);

    send_slv_reg(0); 

    // conv_en <= 1;
    // @(posedge s_axi_aclk);
    // conv_en <= 0 ;



    wait(tb_CONV_ACC_v1_0.u_CONV_ACC_v1_0.u_CONV_ACC.w_done);
    #(PERIOD * 10);
  //  fid_weight=$fopen($sformatf({`DATA_PATH,"%0dweight_bin.txt"},`DETAIL_NUM),"r");
    send_weight(1);
    send_slv_reg(1);
    // conv_en <= 1;
    // @(posedge s_axi_aclk);
    // conv_en <= 0 ;



    wait(tb_CONV_ACC_v1_0.u_CONV_ACC_v1_0.u_CONV_ACC.w_done);
    #(PERIOD * 10);
 //   fid_weight=$fopen($sformatf({`DATA_PATH,"%0dweight_bin.txt"},`DETAIL_NUM),"r");
    send_weight(2);
    send_slv_reg(2);
    // conv_en <= 1;
    // @(posedge s_axi_aclk);
    // conv_en <= 0 ;


//     wait(w_done);
//  //   fid_weight=$fopen($sformatf({`DATA_PATH,"%0dweight_bin.txt"},`DETAIL_NUM),"r");
//     send_weight(3);
//     send_slv_reg(3);
//     conv_en <= 1;
//     @(posedge s_axi_aclk);
//     conv_en <= 0 ;


    receive_ifmap();
    #(PERIOD * 10);

    $finish;
end


reg self_check_done = 0;
always @(posedge s_axi_aclk) begin
    if(m_t_axis_tvalid && m_t_axis_tready)begin
            if(m_t_axis_tlast)begin
                self_check_done <= 1;
            end
            $fscanf(fid_result,"%d",soft_data);
            if($signed(soft_data)==$signed(m_t_axis_tdata[7:0]))begin
                $display("SOFT:  %0d,  HARD:   %0d      correct!",$signed(soft_data),$signed(m_t_axis_tdata[7:0]));
            end
            else begin
                errors<=errors+1;
                $display("%d       %d     the result is error!",$signed(soft_data),$signed(m_t_axis_tdata[7:0]));
                $display("The tensor_size is %0d",para[39:32]);
                $display("The kernel_size is %0d",para[31:24]);
                $display("The kernel_nums is %0d",para[23:16]);
                $display("The channels is %0d",para[15:8]);
                $display("The stride is %0d",para[7:0]);
            end  
    end

    if(self_check_done)begin
        if(errors==0)begin
            $fclose(fid_result);
            $display("TEST PASS SUCCESSFULLY!");
        end
        else begin
            $fclose(fid_result);
            $display("**************************************************");
            $display("*****ERROR!!!,THE TOTAL ERROES NUMS IS %d*********",errors);
            $display("**************************************************");
            $stop;
        end
    end

end



task send_slv_reg;
    input [31:0] para_num; 
    fid_para=$fopen($sformatf({`DATA_PATH,"%0dpara.txt"},para_num),"r");
    $fscanf(fid_para,"%b",para);
    $fclose(fid_para);
    fork
        s_waddr();
        s_wdata();
        s_bresp();
    join

endtask


task  s_waddr();
    @(posedge s_axi_aclk);
    s_axi_awaddr  <= 4'b0000;     // user define
    s_axi_awvalid <= '1;

   // wait (s_axi_awready);
    @(negedge s_axi_awready);
    s_axi_awaddr  <= 4'b0100;
    s_axi_awvalid <= '1;

    @(negedge s_axi_awready);
    s_axi_awaddr  <= 4'b0000;
    s_axi_awvalid <= '0;
endtask : s_waddr



task  s_wdata();
    @(posedge s_axi_aclk);
    s_axi_wdata  ={ {2'b0,para[39:32]} ,6'b000000, para[31:24] , para[7:0]};     // user define//slv_reg0
    $display("The tensor_size is %0d",s_axi_wdata[31:22]);
    $display("The kernel_size is %0d",s_axi_wdata[15:8]);
    $display("The stride is %0d",s_axi_wdata[7:0]);
    s_axi_wvalid = '1;

    //wait (s_axi_wready);
    @(negedge s_axi_wready);
    s_axi_wdata  = { {2'b0,para[15:8]} ,{2'b0,para[23:16]}, 2'b00,1'b1, 1'b1, 8'b00001000};     // user define//slv_reg1
    $display("The kernel_nums is %0d",s_axi_wdata[21:12]);
    $display("The channels is %0d",s_axi_wdata[31:22]);
    $display("The shift is %0d",s_axi_wdata[7:0]);
    s_axi_wvalid = '1;

    @(negedge s_axi_wready);
    s_axi_wdata  = 32'b0000;     // user define
    s_axi_wvalid = '0;
endtask : s_wdata



task s_bresp();

   // wait (s_axi_bvalid);
    @(posedge s_axi_bvalid); // reg ,exist delay
    @(posedge s_axi_aclk);
    s_axi_bready <= '1;

    @(posedge s_axi_aclk);
    s_axi_bready <= '0;

   // wait (s_axi_bvalid);
    @(posedge s_axi_bvalid);
    @(posedge s_axi_aclk);
    s_axi_bready <= '1;

    @(posedge s_axi_aclk);
    s_axi_bready <= '0;
endtask : s_bresp


// always @(*) begin
    
// end

// task send_ifmap;
//     input [31:0] tensor_num;
//     fid_tensor=$fopen($sformatf({`DATA_PATH,"%0dtensor_bin.txt"},tensor_num),"r");
//     $display("**************SEND IFMAP START*********************");
//     while (!$feof(fid_tensor)) begin
//         @(posedge s_axi_aclk);
//         $fscanf(fid_tensor, "%b", s_t_axis_tdata);
//        // $display("The ifmap data is %0d",$signed(s_t_axis_tdata));
//         if($feof(fid_tensor) != 0)begin
//             s_t_axis_tlast <= 1;
//         end
//         else begin
//             s_t_axis_tlast <= 0;
//         end
//         s_t_axis_tvalid <=  1;
//     end
//     $display("**************SEND IFMAP END*********************");
//     @(posedge s_axi_aclk);
//     $fclose(fid_tensor);
//     s_t_axis_tdata <= 0;
//     s_t_axis_tvalid <= 0;
//     s_t_axis_tlast <= 0;
// endtask


reg [7:0] t_data = 0;
reg [7:0] w_data =0;
reg flag = 0;
task send_ifmap_weight;
    input [31:0] num;
    fid_tensor=$fopen($sformatf({`DATA_PATH,"%0dtensor_bin.txt"},num),"r");
    fid_weight=$fopen($sformatf({`DATA_PATH,"%0dweight_bin.txt"},num),"r");

    $display("**************SEND IFMAP AND WEIGHT START*********************");

    while (!$feof(fid_tensor) || !$feof(fid_weight) ) begin
        @(posedge s_axi_aclk);
        $fscanf(fid_tensor, "%b", t_data);
        $fscanf(fid_weight, "%b", w_data);
        if($feof(fid_weight) != 0)begin
            flag <= 1;
        end
        s_axis_tdata = flag ? {14'b0,2'b10,t_data,w_data} : {14'b0,2'b11,t_data,w_data};
       // $display("The ifmap data is %0d",$signed(s_t_axis_tdata));
        if($feof(fid_tensor) != 0 && $feof(fid_weight) != 0)begin
            s_axis_tlast <= 1;
        end
        else begin
            s_axis_tlast <= 0;
        end
        s_axis_tvalid <=  1;
    end
    $display("**************SEND IFMAP END*********************");
    @(posedge s_axi_aclk);
    $fclose(fid_tensor);
    $fclose(fid_weight);
    s_axis_tdata <= 0;
    s_axis_tvalid <= 0;
    s_axis_tlast <= 0;
endtask


task send_weight;
    input [31:0] weight_num;
    fid_weight=$fopen($sformatf({`DATA_PATH,"%0dweight_bin.txt"},weight_num),"r");
    $display("**************SEND WEIGHT START*********************");
    while (!$feof(fid_weight)) begin
        @(posedge s_axi_aclk);
        $fscanf(fid_weight, "%b", s_axis_tdata[7:0]);
        s_axis_tdata[16] = 1;
        //$display("The weight data is %0d",$signed(s_w_axis_tdata));
        if($feof(fid_weight) != 0)begin
            s_axis_tlast <= 1;
        end
        else begin
            s_axis_tlast <= 0;
        end
        s_axis_tvalid <= 1;
    end
    $display("**************SEND WEIGHT END*********************");
    @(posedge s_axi_aclk);
    $fclose(fid_weight);
    s_axis_tdata <= 0;
    s_axis_tvalid <= 0;
    s_axis_tlast <= 0;
endtask

task receive_ifmap();
    wait(tb_CONV_ACC_v1_0.u_CONV_ACC_v1_0.u_CONV_ACC.w_done);
    @(posedge s_axi_aclk);
    m_t_axis_tready <= 1 ;
    wait(m_t_axis_tlast);
    @(posedge s_axi_aclk);
    m_t_axis_tready <= 0 ;
endtask

endmodule