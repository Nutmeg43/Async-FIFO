class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)
    
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    fifo_env env;
    fifo_sequence seq;
    
    //Build environemnt and sequence
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
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

endclass