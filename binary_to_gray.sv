/*
 * Implementation of a binary to grey encoder (encodes binary)
 */

module binary_to_gray#(parameter BITSIZE = 4)(
    input        [BITSIZE-1:0] binary,         //Binary being encoded to gray
    output logic [BITSIZE-1:0] gray     //Gray output
);

    assign gray[BITSIZE - 1] = binary[BITSIZE - 1];
    
    generate
        genvar i;
        for(i = BITSIZE - 2; i > -1; i = i - 1) begin
            assign gray[BITSIZE] = binary[BITSIZE + 1] ^ binary[BITSIZE];
        end        
    endgenerate
        
endmodule