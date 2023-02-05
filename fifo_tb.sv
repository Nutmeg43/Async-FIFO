`include "uvm.sv"
`include "fifo_test.sv"
`include "fifo_intf.sv"
import uvm_pkg::*;


//A simple testbench, to be evolved in to a more complex UVM testbench
module fifo_tb();
    
    localparam BITSIZE = 8;        //Length of data in memory
    localparam MEMSIZE = 32;       //Number of locations in memory
    localparam POINTERLENGTH = 6;   //Number of bits needeed to address memory (logbase2(MEMSIZE) + 1)
    
    logic w_clk;                                //Clock for writing data
    logic r_clk;                                //Clock for reading data                           
    logic w_enable;                             //Enable signal for writing data
    logic r_enable;                             //Enable signal for reading data
    logic reset;                                //Sigal to reset read/write pointers (can not write/read during reset)
    logic [BITSIZE-1:0] wdata;                  //Wrte data
    logic [BITSIZE-1:0] rdata;                  //Read data
    logic full;                                 //Signal stating if FIFO is full
    logic empty;                                //Signal stating if FIFO is empty
    
    fifo_intf  #(
        .BITSIZE(BITSIZE)
    ) fifo_intf_instance(
        .w_clk(w_clk),
        .r_clk(r_clk)
    );
    
    asynchronous_fifo #(
        .BITSIZE(BITSIZE),
        .MEMSIZE(MEMSIZE),
        .POINTERLENGTH(POINTERLENGTH)
    ) asynchronous_fifo_instance(
        .w_clk(w_clk),
        .r_clk(r_clk),
        .w_enable(w_enable),
        .r_enable(r_enable),
        .reset(reset),
        .wdata(wdata),
        .rdata(rdata),
        .full(full),
        .empty(empty)
    );
    
    always #5 w_clk = ~w_clk;
    always #7 r_clk = ~r_clk;
    
    
    initial begin
        w_clk = 0;
        r_clk = 0;
        uvm_config_db#(uvm_object_wrapper)::set(null,"*","BITSIZE",BITSIZE);
        uvm_config_db#(uvm_object_wrapper)::set(null,"*","MEMSIZE",MEMSIZE);
        uvm_config_db#(uvm_object_wrapper)::set(null,"*","POINTERLENGTH",POINTERLENGTH);
        uvm_config_db#(virtual fifo_intf)::set(null,"*","fifo_intf",fifo_intf_instance);
        run_test("fifo_test");
        #100
        $stop();
    end
    
    
//    initial begin
//        w_clk = 0;
//        r_clk = 0;
//        reset = 0;
//        r_enable = 0;
//        w_enable = 0;
//        wdata = '0;
//        reset = 1;
//        #20
//        w_enable = 1;
//        reset = 0;
//        wdata = 8'hf8;
//        #350
//        w_enable = 0;
//        r_enable = 1;
//        #500
//        wdata = 8'h45;
//        w_enable = 1;
//        #500
//        $stop();
//    end
    
endmodule
