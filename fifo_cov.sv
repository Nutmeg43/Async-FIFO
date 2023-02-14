/*
 * Author: Jacob Salmon
 * 
 * Description: Coverage class
 * 
 * Notable Info: Coverage is sampled in scoreboard
 */
 
class fifo_cov;
                              
    logic w_enable;                               //Enable signal for writing data
    logic r_enable;                               //Enable signal for reading data
    logic reset;                                  //Sigal to reset read/write pointers (can not write/read during reset)
    logic full;                                   //Signal stating if FIFO is full
    logic empty;                                  //Signal stating if FIFO is empty
    
    covergroup fifo_group;
        
        cp_empty : coverpoint empty{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_full : coverpoint full{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_w_enable : coverpoint w_enable{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_r_enable : coverpoint r_enable{
            bins one = {1};
            bins zero = {0};
        }
        
        cp_reset : coverpoint reset{
            bins one = {1};
            bins zero = {0};
        }
        
        w_r : cross w_enable, r_enable;
        
    endgroup
    
    function new();
        fifo_group = new();
    endfunction
    
endclass
