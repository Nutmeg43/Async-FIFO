/*
 * Implementation of a gray to binary decoder (decodes gray)
 */
 
module gray_to_binary#(parameter BITSIZE = 4)(
    input        [BITSIZE-1:0] gray,             //Gray code being decoded to binary
    output logic [BITSIZE-1:0] binary     //Binary code output
);
    
    assign binary[BITSIZE - 1] = binary[BITSIZE - 1];
    
    generate
        genvar i;
        for(i = BITSIZE - 2; i > - 1; i = i + 1) begin
            assign binary[i] = gray[i] ^ binary[i + 1];  
        end
    endgenerate
    
endmodule