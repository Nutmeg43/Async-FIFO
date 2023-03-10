/*
 * Author: Jacob Salmon
 * 
 * Description: UVM Monitor for monitoring the intf between test/DUT
 * 
 * Notable Info: Monitors and both clocks, and sends to sb port according to domain
 */
 
class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)
 
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual fifo_intf intf;
    uvm_analysis_port #(fifo_seq) write_collect_port;
    uvm_analysis_port #(fifo_seq) read_collect_port;
    
    //Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        read_collect_port = new("read_collect_port",this);
        write_collect_port = new("write_collect_port",this);
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
                @(intf.w_cb) begin
                    fifo_seq item = fifo_seq::type_id::create("item");
                    item.w_enable = intf.w_enable;
                    item.wdata = intf.wdata;
                    item.reset = intf.reset;
                    item.r_enable = intf.r_enable;
                    item.full = intf.full;
                    item.empty = intf.empty;
                    item.rdata = intf.rdata;
                    write_collect_port.write(item);
                end
            end
            forever begin
                @(intf.r_cb) begin
                    fifo_seq item = fifo_seq::type_id::create("item");
                    item.w_enable = intf.w_enable;
                    item.wdata = intf.wdata;
                    item.reset = intf.reset;
                    item.r_enable = intf.r_enable;
                    item.full = intf.full;
                    item.empty = intf.empty;
                    item.rdata = intf.rdata;
                    read_collect_port.write(item);
                end
            end
        join
    endtask        
        
endclass
 