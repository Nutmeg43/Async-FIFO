/*
 * Two stage flip flop synchronizer
 * Used when trying to avoid metastability across clock domains
 * Uses synchronous reset
 */
module ff_synchronizer#(parameter BITSIZE = 8)(
    input                      reset,          //Synchronous reset signal for both flops
    input                      clk,            //Clock driving flops
    input        [BITSIZE-1:0] data_in,        //Data being set in to the syncrhonizer
    output logic [BITSIZE-1:0] data_out        //Ouput synchronized data
);

    logic [BITSIZE-1:0] midwires;

    //Always block for flip flops
    always_ff @ (posedge clk) begin
        if(reset) begin //Reset both flip flops to zero
            midwires <= '0;
            data_out <= '0;
        end else begin  //Set output data to what was between flops
            data_out <= midwires;
            midwires <= data_in;    
        end 
    end
        
endmodule
