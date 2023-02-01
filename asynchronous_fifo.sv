module asynchronous_fifo#(
    BITSIZE = 8,        //Length of data in memory
    MEMSIZE = 32,       //Number of locations in memory
    POINTERLENGTH = 6   //Number of bits needeed to address memory (logbase2(MEMSIZE) + 1)
)(
    input w_clk,                                  //Clock for writing data
    input r_clk,                                  //Clock for reading data                           
    input w_enable,                               //Enable signal for writing data
    input r_enable,                               //Enable signal for reading data
    input reset,                                  //Sigal to reset read/write pointers (can not write/read during reset)
    input [BITSIZE-1:0] wdata,                    //Wrte data
    output logic [BITSIZE-1:0] rdata,             //Read data
    output logic full,                            //Signal stating if FIFO is full
    output logic empty                            //Signal stating if FIFO is empty
);
    logic [POINTERLENGTH-1:0] rptr;               //Internal logic for read pointer
    logic [POINTERLENGTH-1:0] gray_rptr;          //Wire of resulting b2g conversion of read pointer
    logic [POINTERLENGTH-1:0] gray_rptr_sync;     //Wire after ff synchronizer for read pointer
    logic [POINTERLENGTH-1:0] rptr_sync;          //Synchronized rptr in write clock domain
    logic [POINTERLENGTH-1:0] wptr;               //Internal logic for write pointer
    logic [POINTERLENGTH-1:0] gray_wptr;          //Wire of resulting b2g conversion of write pointer
    logic [POINTERLENGTH-1:0] gray_wptr_sync;     //Wire after ff synchronizer for write pointer
    logic [POINTERLENGTH-1:0] wptr_sync;          //Synchronized wptr in read clock domain
    
    logic write;    //Signal stating if we are writing (en,!full,!reset)
    logic read;     //Signal stating if we are reading (en,!full,!reset)
    
    //Convers to read pointer to gray (from binary)
    binary_to_gray #(.BITSIZE(POINTERLENGTH)) binary_to_gray_instance_read_to_write(
        .binary(rptr),
        .gray(gray_rptr)
    );
    
    //Converts the write pointer to gray (from binary)
    binary_to_gray #(.BITSIZE(POINTERLENGTH)) binary_to_gray_instance_write_to_read(
        .binary(wptr),
        .gray(gray_wptr)
    );
    
    //Converts the read pointer to binray (from gray)
    gray_to_binary #(.BITSIZE(POINTERLENGTH)) gray_to_binary_instance_read_to_write(
        .gray(gray_rptr_sync),
        .binary(rptr_sync)
    );
    
    //Converts the write pointer to binray (from gray)
    gray_to_binary #(.BITSIZE(POINTERLENGTH)) gray_to_binary_instance_write_to_read(
        .gray(gray_wptr_sync),
        .binary(wptr_sync)
    );
    
    //Flip flop synchronizer for read to write domain
    ff_synchronizer #(.BITSIZE(POINTERLENGTH)) ff_synchronizer_instance_read_to_write(
        .reset(reset),
        .clk(r_clk),
        .data_in(gray_rptr),
        .data_out(gray_rptr_sync)
    );
    
    //Flip flop synchronizer for write to read domain
    ff_synchronizer #(.BITSIZE(POINTERLENGTH)) ff_synchronizer_instance_write_to_read(
        .reset(reset),
        .clk(w_clk),
        .data_in(gray_wptr),
        .data_out(gray_wptr_sync)
    );
    
    //Memory to write and read from
    dual_port_memory #(.BITSIZE(BITSIZE),.MEMSIZE(MEMSIZE),.ADDRESS_SIZE(POINTERLENGTH - 1)) dual_port_memory_instance(
        .wclk(w_clk),
        .rclk(r_clk),
        .read(read),
        .write(write),
        .wadrs(wptr[POINTERLENGTH-2:0]),
        .radrs(rptr[POINTERLENGTH-2:0]),
        .wdata(wdata),
        .rdata(rdata)
    );
    
    
    //Assignments for write and read
    assign write = (~reset & ~full & w_enable);
    assign read = (~reset & ~empty & r_enable);
    
    //Block for writing data, and checking if full
    always @(posedge w_clk) begin
        if(reset) begin     //Reset case, set write data location zero, not allowed to write any data
            wptr <= 0;
            full <= 0;
        end 
        else if(write) begin //Case for reading data
            if(wptr[POINTERLENGTH-2] == MEMSIZE-1) begin //If pointer is at memsize address limit
                wptr[POINTERLENGTH-2:0] <= 0;  //Set lower bits to zero
                wptr[POINTERLENGTH-1] <= ~wptr[POINTERLENGTH-1]; //Flip MSB
            end
            else if(wptr[POINTERLENGTH-1] != rptr[POINTERLENGTH-1] && wptr[POINTERLENGTH-2:0] == rptr[POINTERLENGTH-2:0]) begin //Check full case
                full <= 1;
            end
            else begin
                wptr <= wptr + 1;
                full <= 0;
            end
        end
    end
    
    
    //Block for reading data, and checking if empty
    always @(posedge r_clk) begin
        if(reset) begin //Reset case, set read pointer to location zero, not allowed to read any data
            rptr <= 0;
            empty <= 1;
        end 
        else if(read) begin //Case for reading data
            if(rptr[POINTERLENGTH-2] == MEMSIZE-1) begin //If pointer is at memsize address limi
                rptr[POINTERLENGTH-2:0] <= 0;  //Set lower bits to zero
                rptr[POINTERLENGTH-1] <= ~rptr[POINTERLENGTH-1]; //Flip MSB
            end
            else if(rptr == wptr_sync) begin //Check empty case
                empty <= 1; 
            end
            else begin
                rptr <= rptr + 1;   
                empty <= 0;  
            end
        end
    end

endmodule