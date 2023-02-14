package fifo_pkg;
    `include "uvm.sv"
    import uvm_pkg::*;
    `include "fifo_seq.sv"
    `include "fifo_sequence.sv"
    `include "fifo_scoreboard.sv"
    `include "fifo_driver.sv"
    `include "fifo_monitor.sv"
    `include "fifo_agent.sv"
    `include "fifo_env.sv"
    `include "fifo_test.sv"   
    `include "fifo_full_empty_test.sv"
    `include "fifo_rand_test.sv"
    `include "fifo_complete_test.sv"
endpackage
