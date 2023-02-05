class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
 
    `uvm_analysis_imp_decl(_write_port)         //Analysis port for w clk domain
    `uvm_analysis_imp_decl(_read_port)          //Analysis port for r clk domain
    uvm_analysis_imp_write_port#(fifo_seq,fifo_scoreboard) write_port;
    uvm_analysis_imp_read_port#(fifo_seq,fifo_scoreboard) read_port;
 
    logic [31:0] sb_fifo_q[$];      //Queue that will be used for scoring items
    logic [5:0]  sb_wptr,sb_rptr;   //Pointers used for empty and full (on delay due to 2ff)
 
    function new(string name,uvm_component parent);
        super.new(name,parent);
        write_port = new("write_port",this);
        read_port = new("read_port",this);
    endfunction
    
    //Write port, score 
    virtual function void write_write_port(fifo_seq item);
        item.print();
    endfunction
    
    
    //Read port, score 
    virtual function void write_read_port(fifo_seq item);
        item.print();
    endfunction
    
    
endclass
 