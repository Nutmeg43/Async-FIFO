class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)
    
    bit test_result = 1;
    
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    fifo_env env;
    fifo_sequence seq;
    
    //Build environemnt and sequence
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_object_wrapper)::set(this,"env.agent.sequencer.run_phase", 
            "default_sequence",write_read_seq::type_id::get()
        );
        env = fifo_env::type_id::create("env",this);
        seq = fifo_sequence::type_id::create("seq");
    endfunction
    
    //Print the topology of design
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction
    
    //Run phase
    virtual task run_phase(uvm_phase phase);
        phase.phase_done.set_drain_time(this, 50); //50 time units after all transactions complete
    endtask
    
    //Report the final restults
    virtual function void report_phase(uvm_phase phase);
        if(test_result) begin
            `uvm_info(get_type_name(), "** UVM TEST PASSED **", UVM_NONE)
        end
        else begin
            `uvm_error(get_type_name(), "** UVM TEST FAIL **")
        end
    endfunction

endclass