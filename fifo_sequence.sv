class fifo_sequence extends uvm_sequence #(fifo_seq);
    `uvm_object_utils(fifo_sequence)
 
    function new(string name = "fifo_sequence");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction
    
endclass
 
//Class for writes, then reads
class write_read_seq extends fifo_sequence #(fifo_seq);
    `uvm_object_utils(write_read_seq)
    
    function new(string name = "write_read_seq");
        super.new(name);
    endfunction
    
    //Body, constrained to write 10, then read 10
    virtual task body();
        repeat(10) begin
            `uvm_do_with(req, {req.w_enable == 1; req.reset == 0; req.r_enable == 0;});    
        end
        repeat(10) begin
            `uvm_do_with(req, {req.w_enable == 0; req.reset == 0; req.r_enable == 1;});    
        end
    endtask
    
endclass