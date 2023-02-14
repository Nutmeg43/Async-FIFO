/*
 * Author: Jacob Salmon
 * 
 * Description: Interface between test components and DUT
 * 
 * Notable Info: Dual clocking blocks for driving/moitioring both domains
 */
 
interface fifo_intf#(
    BITSIZE = 8
)(
    input w_clk,
    input r_clk
);                        
    logic w_enable;                               //Enable signal for writing data
    logic r_enable;                               //Enable signal for reading data
    logic reset;                                  //Sigal to reset read/write pointers (can not write/read during reset)
    logic [BITSIZE-1:0] wdata;                    //Wrte data
    logic [BITSIZE-1:0] rdata;                    //Read data
    logic full;                                   //Signal stating if FIFO is full
    logic empty;                                  //Signal stating if FIFO is empty

    clocking w_cb @(posedge w_clk);
        output w_enable;
        output wdata;
        output reset;
        input  full;        
    endclocking


    clocking r_cb @(posedge r_clk);
        output r_enable;
        output reset;
        input  rdata;
        input  empty;
    endclocking
    
endinterface