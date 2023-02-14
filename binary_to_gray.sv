/*
 * Author: Jacob Salmon
 * 
 * Description: Implementation of a binary to grey encoder (encodes binary)
 * 
 * Notable Info: Input binary, ouputs gray
 */

module binary_to_gray#(parameter BITSIZE = 8)(
    input        [BITSIZE-1:0] binary,         //Binary being encoded to gray
    output logic [BITSIZE-1:0] gray     //Gray output
);

    assign gray={binary[BITSIZE-1],binary[BITSIZE-1:1]^binary[BITSIZE-2:0]};
    
endmodule