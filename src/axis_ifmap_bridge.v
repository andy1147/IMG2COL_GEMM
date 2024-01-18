



//write data from dma,  dma --> ram
        input [`ADDR_SIZE-1:0] w_addr,

        input [`DATA_WIDTH-1 :0] s_axis_tdata,
        input s_axis_tvalid,
        input s_axis_tlast,
        input s_axis_tstrb,
        output s_axis_tready,


//read data from ram, ram --> dma
        input [`ADDR_SIZE-1:0]  rd_o_addr,

        input m_axis_tready,
        output [`DATA_WIDTH-1 :0] m_axis_tdata,
        output m_axis_tlast,
        output m_axis_tstrb,
        output m_axis_tvalid,