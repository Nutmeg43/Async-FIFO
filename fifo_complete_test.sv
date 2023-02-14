/*
 * Author: Jacob Salmon
 * 
 * Description: Extention of base test (fifo_test.sv)
 * 
 * Notable Info: Due to simulation tool constraints, this test is meant to test all cases for 
 * hitting all unique coverpoints. It uses the all_seq sequencer 
 */
 
 
class fifo_complete_test extends fifo_test;
    `uvm_component_utils(fifo_complete_test)
    
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    fifo_env env;
    fifo_sequence seq;
    
    //Build environemnt and sequence
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_object_wrapper)::set(this,"env.agent.sequencer.run_phase", 
            "default_sequence",all_seq::type_id::get()
        );
    endfunction
    
    //Print the topology of design
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
    endfunction
    
    //Run phase
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

endclass