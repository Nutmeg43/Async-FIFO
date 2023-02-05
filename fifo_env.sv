class fifo_env extends uvm_env;
    `uvm_component_utils(fifo_env)
 
    function new(string name,uvm_component parent);
        super.new(name,parent);
    endfunction
    
    fifo_agent agent;
    fifo_scoreboard scoreboard;
    
    //Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        agent = fifo_agent::type_id::create("agent",this);
        scoreboard = fifo_scoreboard::type_id::create("scoreboard",this);
        
    endfunction
        
    //Connect phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.collect_port.connect(scoreboard.write_port);
        agent.monitor.collect_port.connect(scoreboard.read_port);
    endfunction
    
    
endclass