class fifo_driver extends uvm_driver #(fifo_seq);
    `uvm_component_utils(fifo_driver)
 
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual fifo_intf intf;
    fifo_seq item;
    
    //Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual fifo_intf)::get(this,"","fifo_intf",intf)) begin
            `uvm_fatal("DRV","Could not get vif from db");
        end
        item = fifo_seq::type_id::create("item");
    endfunction
    
    //Run phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            seq_item_port.get_next_item(item);
            item.print();
            
            //Fork for case where w_enable == 1 && r_enable == 1
            fork
                @(posedge intf.w_clk) begin
                    `uvm_info("DRV","waiting for w_clk",UVM_LOW);
                    intf.w_enable = item.w_enable;
                    intf.wdata = item.wdata;
                    intf.reset = item.reset;
                end                    
                 @(posedge intf.r_clk) begin
                    `uvm_info("DRV","waiting for r_clk",UVM_LOW);
                    intf.reset = item.reset;
                    intf.r_enable = item.r_enable;                       
                end       
            join
            
            `uvm_info("DRV","Joined",UVM_LOW);
            
            seq_item_port.item_done();
        end
    endtask
        
endclass