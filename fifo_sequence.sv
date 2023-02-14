/*
 * Author: Jacob Salmon
 * 
 * Description: Multiple UVM Sequence class for different types of tests
 * 
 * Notable Info: fifo_sequence is a reset sequence, and since all otheres extends and call super()
     * They will all have reset sequences at the start of their sequences
 */
 
class fifo_sequence extends uvm_sequence #(fifo_seq);
    `uvm_object_utils(fifo_sequence)
 
    function new(string name = "fifo_sequence");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction
    
    //Parent body ensure that first transaction sent is a reset to set up the design
    virtual task body();
        repeat(3) begin
            `uvm_do_with(req,{req.reset == 1; req.w_enable == 0; req.r_enable == 0;});
        end
        //`uvm_do_with(req,{req.reset == 0; req.w_enable == 0; req.r_enable == 0;});
    endtask
    
endclass

class write_read_seq extends fifo_sequence #(fifo_seq);
    `uvm_object_utils(write_read_seq)
    
    function new(string name = "write_read_seq");
        super.new(name);
    endfunction
    
    //Body, constrained to write 10, then read 10
    virtual task body();
        super.body();
        `uvm_do_with(req, {req.w_enable == 1; req.reset == 0; req.r_enable == 0;});    
        `uvm_do_with(req, {req.w_enable == 0; req.reset == 0; req.r_enable == 1;});    
    endtask
    
endclass   

//Class for full test, to write enough to fill fifo, and then enough to empty
class write_full_empty_seq extends fifo_sequence #(fifo_seq);
    `uvm_object_utils(write_full_empty_seq)
    
    function new(string name = "write_full_empty_seq");
        super.new(name);
    endfunction
    
    //Body, constrained to write 10, then read 10
    virtual task body();
        super.body();
        repeat(33) begin
            `uvm_do_with(req, {req.w_enable == 1; req.reset == 0; req.r_enable == 0;});    
        end
        repeat(33) begin
            `uvm_do_with(req, {req.w_enable == 0; req.reset == 0; req.r_enable == 1;});    
        end
    endtask
    
endclass

//Class for full test, to write enough to fill fifo, and then enough to empty
class rand_seq extends fifo_sequence #(fifo_seq);
    `uvm_object_utils(rand_seq)
    
    function new(string name = "rand_seq");
        super.new(name);
    endfunction
    
    //Body, constrained to write 10, then read 10
    virtual task body();
        super.body();
        repeat(33) begin
            `uvm_do_with(req, {req.reset == 0;});    
        end
        repeat(33) begin
            `uvm_do_with(req, {req.reset == 0;});    
        end
    endtask
    
endclass

//Class for full test, to write enough to fill fifo, and then enough to empty
class all_seq extends fifo_sequence #(fifo_seq);
    `uvm_object_utils(all_seq)
    
    function new(string name = "all_seq");
        super.new(name);
    endfunction
    
    //Body, constrained to write 10, then read 10
    virtual task body();
        super.body();
        
        //Random portion
        repeat(33) begin
            `uvm_do_with(req, {req.reset == 0;});    
        end
        repeat(33) begin
            `uvm_do_with(req, {req.reset == 0;});    
        end
        
        //Full portion
        repeat(33) begin
            `uvm_do_with(req, {req.w_enable == 1; req.reset == 0; req.r_enable == 0;});    
        end
        repeat(33) begin
            `uvm_do_with(req, {req.w_enable == 0; req.reset == 0; req.r_enable == 1;});    
        end
        
    endtask
    
endclass