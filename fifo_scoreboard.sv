class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
 
    `uvm_analysis_imp_decl(_write_port)         //Analysis port for w clk domain
    `uvm_analysis_imp_decl(_read_port)          //Analysis port for r clk domain
    uvm_analysis_imp_write_port#(fifo_seq,fifo_scoreboard) analysis_write_port;
    uvm_analysis_imp_read_port#(fifo_seq,fifo_scoreboard) analysis_read_port;
 
 
    logic [7:0]  sb_fifo_q[$];      //Queue that will be used for scoring items
    logic [7:0]  temp_fifo_item;    //Item that should be read
    logic [5:0]  sb_wptr;           //Pointer used for empty and full 
    logic [5:0]  sb_rptr ;          //Pointer used for empty and full 
    logic [5:0]  w_delay_q[$:2];    //Queue that will act as two stage flip flop
    logic [5:0]  r_delay_q[$:2];    //Queue that will act as two stage flip flop
    logic        full;              //When set it is expected that the fifo is full
    logic        empty;             //When set it is expected that the fifo is empty
    logic        empty_flop;        //Flops empty (due to empty being comb logic)
    logic        full_flop;          //Flops full  (due to full being comb logic)
    
 
    function new(string name,uvm_component parent);
        super.new(name,parent);
        analysis_write_port = new("write_port",this);
        analysis_read_port = new("read_port",this);
    endfunction
    
    virtual function void write_wdomain(fifo_seq item);
        
    endfunction
    
    
    //Write port, score 
    virtual function void write_write_port(fifo_seq item);
    
        //Check reset
        if(item.reset) begin
            if(item.full) begin
                `uvm_error("ERROR","Reset signal is on, but queue is listed as full");
            end
            sb_wptr = 0;
            w_delay_q.delete();
            for(int i = 0; i < 3; i++) begin
                w_delay_q[i] = 0;
            end
        end
        
        //Check if we should be full
        if((r_delay_q[0][4:0] == sb_wptr[4:0]) && (r_delay_q[0][5] != sb_wptr[5]) && full_flop == 1) begin
            if(item.full == 0) begin
                `uvm_error("ERROR",$sformatf("Queue should be full but is not: r_delay_q = %b, sb_wptr = %b",r_delay_q[0],sb_wptr));
            end
        end
        
        //Check case where actively writing
        if(item.w_enable & ~item.full & ~item.reset) begin
            sb_fifo_q.push_back(item.wdata);
            `uvm_info("SB_INFO",$sformatf("Last value of w_delay_q = 0x%0x, sb_wptr = 0x%0x, wdata=0x%0x",
                w_delay_q[0], sb_wptr, item.wdata
            ),UVM_HIGH);
            sb_wptr = sb_wptr + 1;  
        end
        
        w_delay_q.pop_front();
        w_delay_q.push_back(sb_wptr);   
        full_flop = item.full;
    endfunction
    
    //Read port, score 
    virtual function void write_read_port(fifo_seq item);     
                        
        //Check reset
        if(item.reset) begin
            sb_rptr = 0;
            r_delay_q.delete();
            for(int i = 0; i < 3; i++) begin
                r_delay_q[i] = 0;
            end
        end
        
        //Check if we should be empty
        if((w_delay_q[0] == sb_rptr)) begin
            if(empty && item.empty == 0) begin
                `uvm_error("ERROR",$sformatf("Queue should be empty but is not: w_delay_q = %b, sb_wptr = %b",w_delay_q[0],sb_rptr));
            end
        end
        else begin
            empty = 0;
        end
            
        //Check case where actively reading
        if(item.r_enable & ~empty_flop & ~item.reset) begin
            temp_fifo_item = sb_fifo_q.pop_front();
            if(temp_fifo_item != item.rdata) begin
                `uvm_error("ERROR",$sformatf("Read data = 0x%0x, expected read data = 0x%0x",item.rdata,temp_fifo_item));
            end
            `uvm_info("SB_INFO",$sformatf("Last value of r_delay_q = 0x%0x, sb_rptr = 0x%0x",r_delay_q[0], sb_rptr),UVM_HIGH);
            sb_rptr = sb_rptr + 1;
        end
        
        r_delay_q.pop_front();
        r_delay_q.push_back(sb_rptr);
        empty_flop = item.empty;
    endfunction
    
    
endclass
 