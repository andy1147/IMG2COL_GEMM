


`include "../rtl/define.v"
`timescale  1ns / 1ps


module tb_one_conv;

// IMG2COL_GEMM Parameters
parameter PERIOD  = 10;


// IMG2COL_GEMM Inputs


    reg   clk                                  = 0 ;
    reg   rstn                                 = 0 ;
    reg   start                               = 0 ;
    reg   [`TENSOR_SIZE-1:0]  tensor_size      = 0 ;
    reg   [`KERNEL_SIZE-1:0]  kernel_size      = 0;
    reg   [`CHANNELS_SIZE-1:0]  channels       = 0 ;
    reg   [`STRIDE_SIZE-1:0]  stride           = 0 ;
    reg   [`KERNEL_NUMS_SIZE-1 :0]  kernel_nums = 0 ;

wire [`RESULT_SIZE-1:0] dout;
wire w_done;



initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
    #(18) start=1;
end

initial
begin            
    $dumpfile("one_conv.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_one_conv);    //tb模块名称
end
    


TOP  u_TOP (
    .clk                     ( clk                                   ),
    .rstn                    ( rstn                                  ),
    .start                  ( start                                ),
    .tensor_size             ( tensor_size  [`TENSOR_SIZE-1:0]       ),
    .kernel_size             ( kernel_size  [`KERNEL_SIZE-1:0]       ),
    .channels                ( channels     [`CHANNELS_SIZE-1:0]     ),
    .stride                  ( stride       [`STRIDE_SIZE-1:0]       ),
    .kernel_nums             ( kernel_nums  [`KERNEL_NUMS_SIZE-1 :0] ),

    .dout                    ( dout         [`RESULT_SIZE-1:0]       ),
    .w_done                  ( w_done                                )
);



`ifdef SIM_DETAIL
    reg [39:0] para=0;
    integer fid;
    initial begin
            fid=$fopen($sformatf({`DATA_PATH,"%0dpara.txt"},`DETAIL_NUM),"r");
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
            #(PERIOD*1000000)
            $finish;
        end



    integer errors;
    integer fid_result;
    reg w_done_d1;
    reg [`RESULT_SIZE -1 :0] soft_data;

    always @(posedge clk or negedge rstn ) begin
        if(!rstn)begin
            w_done_d1 <=0;
        end
        else begin
            w_done_d1 <=w_done;
        end
    end
    always @(posedge w_done_d1) begin
            fid_result=$fopen($sformatf({`DATA_PATH,"%0dresult_dec.txt"},`DETAIL_NUM),"r");
            errors<=0;
    end
    always @(posedge clk) begin
        if(w_done_d1)begin
            //#(PERIOD*900) $finish;
             #(PERIOD*(((tensor_size-kernel_size)/stride+1)**2)*kernel_nums) $finish;
        end
    end

    always @(posedge clk) begin
        if(w_done_d1)begin
            $fscanf(fid_result,"%d",soft_data);
            if($signed(soft_data)==$signed(dout))begin
                $display("SOFT:  %0d,  HARD:   %0d      correct!",$signed(soft_data),$signed(dout));
               // $display("ADDR: %0d",tb_TOP.TOP.ram_save.ram_save_addr[31 :0]);
            end
            else begin
                errors<=errors+1;
                $display("%d       %d     the result is error!",$signed(soft_data),$signed(dout));
                $display("The tensor_size is %0d",para[39:32]);
                $display("The kernel_size is %0d",para[31:24]);
                $display("The kernel_nums is %0d",para[23:16]);
                $display("The channels is %0d",para[15:8]);
                $display("The stride is %0d",para[7:0]);
               // $display("ADDR: %0d",tb_TOP.TOP.ram_save.ram_save_addr[31 :0]);
                $stop;
            end
            
        end
    end

`endif 


`ifdef SIM_ALL
    reg [63:0] time_read =0;

    parameter SIM_NUMS =50 ;
    reg [39:0] para=0;
    integer fid;
    reg [`SIM_GROUP_NUMS_SIZE-1:0] count=0;


    integer errors;
    integer fid_result;
    reg w_done_d1;
    reg [`RESULT_SIZE -1 :0] soft_data;


    always @(posedge rstn) begin
            fid=$fopen($sformatf({`DATA_PATH,"%0dpara.txt"},count),"r");
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



    always @(posedge clk or negedge rstn ) begin
        if(!rstn)begin
            w_done_d1 <=0;
        end
        else begin
            w_done_d1 <=w_done;
        end
    end


    always @(posedge w_done_d1) begin
            fid_result=$fopen($sformatf({`DATA_PATH,"%0dresult_dec.txt"},count-1),"r");
            errors<=0;
    end


    always @(posedge clk) begin
        if(w_done_d1)begin
            
            #(PERIOD*((((tensor_size-kernel_size)/stride+1)**2)*kernel_nums));
            time_read <= time_read+ (PERIOD*((((tensor_size-kernel_size)/stride+1)**2)*kernel_nums));

            if(count==SIM_NUMS)begin
                #(PERIOD);
                $display("**************************************************");
                $display("**********TEST PASSED FOR ALL GROUPS!************");
                $display("**********SIM FINISH TIME is ",$realtime," ns************"); 
                $display("**********RAM READ TIME is %0d ns************",time_read); 
                $display("**********ALL COMPUTE TIME is %0d ns************",$time-time_read);    
                $display("**************************************************");
                $finish;
            end

            if(errors==0)begin
                $fclose(fid_result);
                $display("TEST PASS FOR %0d GROUP SUCCESSFULLY!",count-1);
            end
            else begin
                $fclose(fid_result);
                $display("**************************************************");
                $display("*****ERROR!!!,THE TOTAL ERROES NUMS IS %d*********",errors);
                $display("**************************************************");
                $stop;
            end


            //#(PERIOD);
            rstn  <=  0;
            start<=0;
            #(PERIOD*2) rstn  <=  1;
            #(18) start<=1;
        end
    end


    always @(posedge clk) begin
        if(w_done_d1)begin
            $fscanf(fid_result,"%d",soft_data);
            if($signed(soft_data)==$signed(dout))begin
                $display("SOFT:  %0d,  HARD:   %0d      correct!",$signed(soft_data),$signed(dout));
               // $display("ADDR: %0d",tb_TOP.TOP.ram_save.ram_save_addr[31 :0]);
            end
            else begin
                errors<=errors+1;
                $display("%d       %d     the result is error!",$signed(soft_data),$signed(dout));
                $display("The tensor_size is %0d",para[39:32]);
                $display("The kernel_size is %0d",para[31:24]);
                $display("The kernel_nums is %0d",para[23:16]);
                $display("The channels is %0d",para[15:8]);
                $display("The stride is %0d",para[7:0]);
               // $display("ADDR: %0d",tb_TOP.TOP.ram_save.ram_save_addr[31 :0]);
                //$stop;
            end  
        end

    end




`endif 







// `ifdef SIM_ALL


//     wire o_valid_1;
//     reg o_valid_2 =0 ;
//     reg o_compute_done =0;


//     assign o_valid_1 = o_result != 0;

//     always @(posedge clk or negedge rstn) begin
//         if(!rstn)begin
//         // o_valid_1 <= 0;

//         end
//         else if(start)begin
//         if(o_result != 0) begin
//             // o_valid_1 <= 1;
//                 o_valid_2 <= o_valid_1;
                
//                 //o_compute_done <= 1;
//         end
//         //    else begin
//         //     //o_valid_1 <= o_valid_1;
//         //     o_valid_2 <= o_valid_2;
//         //     o_compute_done <= o_compute_done;
//         //    end
//         end
//     end

//     wire o_valid;
//     always @(posedge clk) begin
//         if(start)begin
//             if(o_valid)begin
//                 #(PERIOD * 10);
//                 o_compute_done <= 1;
//             end
//         end
//     end

//     assign o_valid =o_valid_1 && ~o_valid_2;




//     parameter SIM_NUMS =100 ;

//     reg [`SIM_GROUP_NUMS_SIZE-1:0] count=0;
//     always @(posedge clk) begin
//         if(o_compute_done && count==SIM_NUMS)begin
//             #(PERIOD);
//             $display("**************************************************");
//             $display("**********TEST PASSED FOR ALL GROUPS!*************");    
//             $display("**************************************************");
//             $finish;
//         end
//         if(o_compute_done)begin
//             o_valid_2 <=0;
//             o_compute_done <= 0;
//         // #(PERIOD*5);
//             rstn  <=  0;
//             start<=0;
//             #(PERIOD*2) rstn  <=  1;
//             #(18) start<=1;
//         end
//     end



//     integer fid;

//     reg [39:0] para=0;


//     initial begin
//         $display("**************************************************");
//         $display("*******************SIM START**********************");
//         $display("**************************************************");
//     end


//     always @(posedge rstn) begin
//             // str=$sformatf("%0dpara.txt",count);
//             // fid=$fopen(`PATH(str),"r");
//             fid=$fopen($sformatf({`DATA_PATH,"%0dpara.txt"},count),"r");
//             //fid=$fopen($sformatf("C:/Users/Qdream/OneDrive/Projects/IMG2COL/python/img2col/data/%0dpara.txt",count),"r");
//             $fscanf(fid,"%b",para);
//             $fclose(fid);
//             tensor_size<=para[39:32];
//             kernel_size<=para[31:24];
//             kernel_nums<=para[23:16];
//             channels<=para[15:8];
//             stride<=para[7:0];
//             count<=count+1;

//             $display("*********THE %0d GROUP TEST START ****************",count);
//             $display("PARAMETER FOR %0d GROUP TEST",count);
//             $display("The tensor_size is %0d",para[39:32]);
//             $display("The kernel_size is %0d",para[31:24]);
//             $display("The kernel_nums is %0d",para[23:16]);
//             $display("The channels is %0d",para[15:8]);
//             $display("The stride is %0d",para[7:0]);
//             $display("                                                         ");
//     //      $display("**********WAITING FOR TEST %0d......**************",count);
//             $display("   .....      .....        ....  ......");
//         // $display("***correct result****compute result***************");
            
//         end








//     reg [`RESULT_SIZE-1:0] dout;
//     integer errors;
//     integer fid_result;


//     always @(posedge rstn) begin
//             fid_result=$fopen($sformatf({`DATA_PATH,"%0dresult_dec.txt"},count),"r");
//             errors<=0;
//     end



//     always @(posedge clk) begin
//         if(start)begin
//             if(!o_compute_done && o_valid)begin
//                 $fscanf(fid_result,"%d",dout);
//                 if($signed(dout)==$signed(o_result))begin
//                     $display("%d       %d      correct!",$signed(dout),$signed(o_result));
//                 end
//                 else begin
//                     errors<=errors+1;
//                     $display("%d       %d     the result is error!",$signed(dout),$signed(o_result));
//                     $display("THERE IS A ERROR IN %d GROPE TEST",count-1);
//                     $display("PARAMETER FOR CURRENT GROUP TEST: %0d",count-1);
//                     $display("The tensor_size is %0d",para[39:32]);
//                     $display("The kernel_size is %0d",para[31:24]);
//                     $display("The kernel_nums is %0d",para[23:16]);
//                     $display("The channels is %0d",para[15:8]);
//                     $display("The stride is %0d",para[7:0]);
//                 $stop;
//                 end
//             end
//             else if(o_compute_done)begin
//             $fclose(fid_result);
//             if(errors==0)begin
//                 // $display("**************************************************");
//                 // $display("********TEST PASS FOR %0d GROUP TEST!*************",count-1);
//                 // $display("**************************************************");
//                 $display("   .....      .....        ....  ......");
//                 $display("TEST PASS FOR %0d GROUP SUCCESSFULLY!",count-1);
//             // $stop;
//             end
//             else begin
//                 $display("**************************************************");
//                 $display("*****ERROR!!!,THE TOTAL ERROES NUMS IS %d*********",errors);
//                 $display("**************************************************");
//             $stop;
//             end
//             end
//         end
//     end
// `endif 
















endmodule