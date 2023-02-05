class fifo_driver extends uvm_driver #(fifo_seq);
    `uvm_component_utils(fifo_driver)
 
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual fifo_intf intf;
    
    //Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual fifo_intf)::get(this,"","fifo_intf",intf)) begin
            `uvm_fatal("DRV","Could not get vif from db");
        end
    endfunction
    
    //Run phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            seq_item_port.get_next_item(req);
            
            //Fork for case where w_enable == 1 && r_enable == 1
            fork
               if(req.w_enable) begin
                    @(posedge intf.w_clk) begin
                        
                    end                    
                end  
                if(req.r_enable) begin
                     @(posedge intf.r_clk) begin
                       `uvm_info("TEST","Read cb",UVM_LOW);
                       
                    end                      
                end 
            join
            seq_item_port.item_done();
        end
    endtask
        
endclass
 