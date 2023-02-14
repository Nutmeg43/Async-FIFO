`include "uvm.sv"
`include "fifo_test.sv"
`include "fifo_intf.sv"
import uvm_pkg::*;
import fifo_pkg::*;

//UVM testbench
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
        .w_enable(fifo_intf_instance.w_enable),
        .r_enable(fifo_intf_instance.r_enable),
        .reset(fifo_intf_instance.reset),
        .wdata(fifo_intf_instance.wdata),
        .rdata(fifo_intf_instance.rdata),
        .full(fifo_intf_instance.full),
        .empty(fifo_intf_instance.empty)
    );
    
    always #5 w_clk = ~w_clk;
    always #7 r_clk = ~r_clk;
    
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0,fifo_tb); //Need tb to declare what to dump
        w_clk = 0;
        r_clk = 0;
        uvm_config_db#(virtual fifo_intf)::set(null,"*","fifo_intf",fifo_intf_instance);
        //run_test("fifo_full_empty_test");
        //run_test("fifo_rand_test");
        run_test("fifo_complete_test");
        $stop();
    end
    
endmodule
