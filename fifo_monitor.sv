class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)
 
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual fifo_intf intf;
    uvm_analysis_port #(fifo_seq) collect_port;
    
    //Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        collect_port = new("collect_port",this);
        if(!uvm_config_db#(virtual fifo_intf)::get(this,"","fifo_intf",intf)) begin
            `uvm_fatal("MON","Could not get vif from db");
        end
    endfunction
    
    //Run phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        //Fork to monitor both clocking blocks at the same times
        fork
            forever begin
                @(posedge intf.w_clk) begin
                    fifo_seq item = fifo_seq::type_id::create("item");
                    item.w_enable = intf.w_enable;
                    item.wdata = intf.wdata;
                    item.reset = intf.reset;
                    item.r_enable = intf.r_enable;
                    item.full = intf.full;
                    item.empty = intf.empty;
                    item.rdata = intf.rdata;
                    collect_port.write_write_port(item);
                end
            end
            forever begin
                @(posedge intf.r_clk) begin
                    fifo_seq item = fifo_seq::type_id::create("item");
                    item.w_enable = intf.w_enable;
                    item.wdata = intf.wdata;
                    item.reset = intf.reset;
                    item.r_enable = intf.r_enable;
                    item.full = intf.full;
                    item.empty = intf.empty;
                    item.rdata = intf.rdata;
                    collect_port.write_read_port(item);
                end
            end
        join
    endtask        
    
endclass
 