class fifo_seq extends uvm_sequence_item;   
    `uvm_object_utils_begin(fifo_seq)
        `uvm_field_int(w_enable,UVM_ALL_ON)
        `uvm_field_int(r_enable,UVM_ALL_ON)
        `uvm_field_int(reset,UVM_ALL_ON)
        `uvm_field_int(wdata,UVM_ALL_ON)
        `uvm_field_int(rdata,UVM_ALL_ON)
        `uvm_field_int(full,UVM_ALL_ON)
        `uvm_field_int(empty,UVM_ALL_ON)
    `uvm_object_utils_end
    
    rand bit w_enable;                               //Enable signal for writing data
    rand bit r_enable;                               //Enable signal for reading data
    rand bit reset;                                  //Sigal to reset read/write pointers (can not write/read during reset)
    rand bit [7:0] wdata;                            //Wrte data
    bit [7:0] rdata;                                 //Read data
    bit full;                                        //Signal stating if FIFO is full
    bit empty;                                       //Signal stating if FIFO is empty
    
        
    function new(string name = "fifo_seq");
        super.new(name);
    endfunction
    
endclass

 