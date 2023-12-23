


`include "../rtl/define.v"
`timescale  1ns / 1ps


module tb_IMG2COL_GEMM;

// IMG2COL_GEMM Parameters
parameter PERIOD  = 10;
wire [`RESULT_SIZE-1:0] dout;
wire w_done;

// IMG2COL_GEMM Inputs


    reg   clk                                  = 0 ;
    reg   rstn                                 = 0 ;
    reg   enable                               = 0 ;
    reg   [`TENSOR_SIZE-1:0]  tensor_size      = 0 ;
    reg   [`KERNEL_SIZE-1:0]  kernel_size      = 0;
    reg   [`CHANNELS_SIZE-1:0]  channels       = 0 ;
    reg   [`STRIDE_SIZE-1:0]  stride           = 0 ;
    reg   [`KERNEL_NUMS_SIZE-1 :0]  kernel_nums = 0 ;


    

`ifdef SIM_DETAIL
    reg [39:0] para=0;
    integer fid;
    initial begin
            fid=$fopen({`DATA_PATH,"7para.txt"},"r");
            //fid=$fopen($sformatf("C:/Users/Qdream/OneDrive/Projects/IMG2COL/python/img2col/data/%0dpara.txt",count),"r");
            $fscanf(fid,"%b",para);
            $fclose(fid);
            tensor_size<=para[39:32];
            kernel_size<=para[31:24];
            kernel_nums<=para[23:16];
            channels<=para[15:8];
            stride<=para[7:0];
            $display("The tensor_size is %0d",para[39:32]);
            $display("The kernel_size is %0d",para[31:24]);
            $display("The kernel_nums is %0d",para[23:16]);
            $display("The channels is %0d",para[15:8]);
            $display("The stride is %0d",para[7:0]);
    end
    initial
        begin
            #(PERIOD*100000)
            $finish;
        end

`endif 




// IMG2COL_GEMM Outputs

wire  [`RESULT_SIZE -1 :0]  o_result   ;

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
    $dumpfile("IMG2COL_GEMM.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_IMG2COL_GEMM);    //tb模块名称
end



IMG2COL_GEMM  u_IMG2COL_GEMM (
    .clk                     ( clk                                   ),
    .rstn                    ( rstn                                  ),
    .enable                  ( enable                                ),
    .tensor_size             ( tensor_size  [`TENSOR_SIZE-1:0]       ),
    .kernel_size             ( kernel_size  [`KERNEL_SIZE-1:0]       ),
    .channels                ( channels     [`CHANNELS_SIZE-1:0]     ),
    .stride                  ( stride       [`STRIDE_SIZE-1:0]       ),
    .kernel_nums             ( kernel_nums  [`KERNEL_NUMS_SIZE-1 :0] ),
    .o_result                ( o_result                              ),
    .w_done(w_done),
    .dout(dout)
);








`ifdef SIM_ALL


    wire o_valid_1;
    reg o_valid_2 =0 ;
    reg o_compute_done =0;


    assign o_valid_1 = o_result != 0;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
        // o_valid_1 <= 0;

        end
        else if(enable)begin
        if(o_result != 0) begin
            // o_valid_1 <= 1;
                o_valid_2 <= o_valid_1;
                
                //o_compute_done <= 1;
        end
        //    else begin
        //     //o_valid_1 <= o_valid_1;
        //     o_valid_2 <= o_valid_2;
        //     o_compute_done <= o_compute_done;
        //    end
        end
    end

    wire o_valid;
    always @(posedge clk) begin
        if(enable)begin
            if(o_valid)begin
                #(PERIOD * 10);
                o_compute_done <= 1;
            end
        end
    end

    assign o_valid =o_valid_1 && ~o_valid_2;




    parameter SIM_NUMS =100 ;

    reg [`SIM_GROUP_NUMS_SIZE-1:0] count=0;
    always @(posedge clk) begin
        if(o_compute_done && count==SIM_NUMS)begin
            #(PERIOD);
            $display("**************************************************");
            $display("**********TEST PASSED FOR ALL GROUPS!*************");    
            $display("**************************************************");
            $finish;
        end
        if(o_compute_done)begin
            o_valid_2 <=0;
            o_compute_done <= 0;
        // #(PERIOD*5);
            rstn  <=  0;
            enable<=0;
            #(PERIOD*2) rstn  <=  1;
            #(18) enable<=1;
        end
    end



    integer fid;

    reg [39:0] para=0;


    initial begin
        $display("**************************************************");
        $display("*******************SIM START**********************");
        $display("**************************************************");
    end


    always @(posedge rstn) begin
            // str=$sformatf("%0dpara.txt",count);
            // fid=$fopen(`PATH(str),"r");
            fid=$fopen($sformatf({`DATA_PATH,"%0dpara.txt"},count),"r");
            //fid=$fopen($sformatf("C:/Users/Qdream/OneDrive/Projects/IMG2COL/python/img2col/data/%0dpara.txt",count),"r");
            $fscanf(fid,"%b",para);
            $fclose(fid);
            tensor_size<=para[39:32];
            kernel_size<=para[31:24];
            kernel_nums<=para[23:16];
            channels<=para[15:8];
            stride<=para[7:0];
            count<=count+1;

            $display("*********THE %0d GROUP TEST START ****************",count);
            $display("PARAMETER FOR %0d GROUP TEST",count);
            $display("The tensor_size is %0d",para[39:32]);
            $display("The kernel_size is %0d",para[31:24]);
            $display("The kernel_nums is %0d",para[23:16]);
            $display("The channels is %0d",para[15:8]);
            $display("The stride is %0d",para[7:0]);
            $display("                                                         ");
    //      $display("**********WAITING FOR TEST %0d......**************",count);
            $display("   .....      .....        ....  ......");
        // $display("***correct result****compute result***************");
            
        end








    //reg [`RESULT_SIZE-1:0] dout;
    integer errors;
    integer fid_result;


    always @(posedge rstn) begin
            fid_result=$fopen($sformatf({`DATA_PATH,"%0dresult_dec.txt"},count),"r");
            errors<=0;
    end



    always @(posedge clk) begin
        if(enable)begin
            if(!o_compute_done && o_valid)begin
                $fscanf(fid_result,"%d",dout);
                if($signed(dout)==$signed(o_result))begin
                    $display("%d       %d      correct!",$signed(dout),$signed(o_result));
                end
                else begin
                    errors<=errors+1;
                    $display("%d       %d     the result is error!",$signed(dout),$signed(o_result));
                    $display("THERE IS A ERROR IN %d GROPE TEST",count-1);
                    $display("PARAMETER FOR CURRENT GROUP TEST: %0d",count-1);
                    $display("The tensor_size is %0d",para[39:32]);
                    $display("The kernel_size is %0d",para[31:24]);
                    $display("The kernel_nums is %0d",para[23:16]);
                    $display("The channels is %0d",para[15:8]);
                    $display("The stride is %0d",para[7:0]);
                $stop;
                end
            end
            else if(o_compute_done)begin
            $fclose(fid_result);
            if(errors==0)begin
                // $display("**************************************************");
                // $display("********TEST PASS FOR %0d GROUP TEST!*************",count-1);
                // $display("**************************************************");
                $display("   .....      .....        ....  ......");
                $display("TEST PASS FOR %0d GROUP SUCCESSFULLY!",count-1);
            // $stop;
            end
            else begin
                $display("**************************************************");
                $display("*****ERROR!!!,THE TOTAL ERROES NUMS IS %d*********",errors);
                $display("**************************************************");
            $stop;
            end
            end
        end
    end
`endif 
















endmodule