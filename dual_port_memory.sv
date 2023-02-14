module dual_port_memory#(BITSIZE = 8, MEMSIZE = 32, ADDRESS_SIZE = 6)(
    input wclk,
    input rclk,
    input r_en,
    input w_en,
    input full,
    input empty,
    input reset,
    input [ADDRESS_SIZE-1:0] wadrs,
    input [ADDRESS_SIZE-1:0] radrs,
    input [BITSIZE-1:0] wdata,
    output logic [BITSIZE-1:0] rdata
);

    logic [BITSIZE-1:0] mem [MEMSIZE-1:0];
    
    always @(posedge wclk) begin
        if(~reset & ~full & w_en) begin
            mem[wadrs] <= wdata;
        end
    end
    
    always @(posedge rclk) begin
        if(~reset & ~empty & r_en) begin
            rdata <= mem[radrs];
        end
    end
    
endmodule