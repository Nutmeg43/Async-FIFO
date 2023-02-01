module dual_port_memory#(BITSIZE = 8, MEMSIZE = 32, ADDRESS_SIZE = 6)(
    input wclk,
    input rclk,
    input read,
    input write,
    input [ADDRESS_SIZE-1:0] wadrs,
    input [ADDRESS_SIZE-1:0] radrs,
    input [BITSIZE-1:0] wdata,
    output logic [BITSIZE-1:0] rdata
);

    logic [BITSIZE-1:0] mem [MEMSIZE-1:0];
    
    always @(posedge wclk) begin
        if(write) begin
            mem[wadrs] <= wdata;
        end
    end
    
    always @(posedge rclk) begin
        if(read) begin
            rdata <= mem[rdata];
        end
    end
    
endmodule