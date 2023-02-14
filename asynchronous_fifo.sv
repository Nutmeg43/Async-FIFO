/*
 * Author: Jacob Salmon
 * 
 * Description: An RTL model of an asynchronous fifo, for transfering data between multiple clock domains.
 * 
 * Notable Info: Singular reset for both domains, two enables (one for each domain)
 */

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
    logic [POINTERLENGTH-1:0] check_next;         //Used for setting full signal exactly when it occurs
    
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
        .r_en(r_enable),
        .w_en(w_enable),
        .empty(empty),
        .full(full),
        .reset(reset),
        .wadrs(wptr[POINTERLENGTH-2:0]),
        .radrs(rptr[POINTERLENGTH-2:0]),
        .wdata(wdata),
        .rdata(rdata)
    );
    
    //Block for writing data, and checking if full
    always @(posedge w_clk) begin
        
        //$display($sformatf("ASYNC: empty - 0x%0x, reset - 0x%0x, w_en = 0x%0x, write = 0x%0x",empty,reset,w_enable));
        
        //Check if resetting
        if(reset) begin     
            wptr <= 0;
            full <= 0;
        end 
        
        //Check if full, if so can't write
        if(wptr[POINTERLENGTH-1] != rptr_sync[POINTERLENGTH-1] && wptr[POINTERLENGTH-2:0] == rptr_sync[POINTERLENGTH-2:0]) begin
            full <= 1;
        end
        else if(~reset & ~full & w_enable) begin
            if(wptr[POINTERLENGTH-2] == MEMSIZE-1) begin //If pointer is at memsize address limit
                wptr[POINTERLENGTH-2:0] <= 0;  //Set lower bits to zero
                wptr[POINTERLENGTH-1] <= ~wptr[POINTERLENGTH-1]; //Flip MSB
            end 
            else begin
                //$display("WRITE");
                wptr <= wptr + 1;
                if(wptr[POINTERLENGTH-1] != rptr_sync[POINTERLENGTH-1] && wptr[POINTERLENGTH-2:0] == rptr_sync[POINTERLENGTH-2:0]) begin //Currently full
                    full <= 1;
                end 
                else if(wptr - 31 == rptr_sync) begin   //Full next cycle
                    full <= 1;
                end    
                else begin  //Not full
                    full <= 0;
                end
            end
        end
        else begin
            full <= 0;
        end
    end
    
    //Block for reading data, and checking if empty
    always @(posedge r_clk) begin
        if(reset) begin //Reset case, set read pointer to location zero, not allowed to read any data
            rptr <= 0;
            empty <= 1;
        end 
        else if(~reset & ~empty & r_enable) begin //Case for reading data
            if(rptr[POINTERLENGTH-2] == MEMSIZE-1) begin //If pointer is at memsize address limi
                rptr[POINTERLENGTH-2:0] <= 0;  //Set lower bits to zero
                rptr[POINTERLENGTH-1] <= ~rptr[POINTERLENGTH-1]; //Flip MSB
            end
            else begin
                rptr <= rptr + 1;  
                if(rptr == wptr_sync) begin //Check empty case
                    empty <= 1; 
                end else begin
                    empty <= 0;
                end
            end
        end
        else begin
            if(rptr == wptr_sync) begin //Check empty currently
                empty <= 1; 
            end 
            else if(wptr_sync - rptr == 1) begin //Check going to be empty
                empty <= 1;
            end
            else begin
                empty <= 0;
            end
        end
    end

endmodule