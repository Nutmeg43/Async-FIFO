/*
 * Implementation of a gray to binary decoder (decodes gray)
 */
 
module gray_to_binary#(parameter BITSIZE = 8)(
    input        [BITSIZE-1:0] gray,             //Gray code being decoded to binary
    output logic [BITSIZE-1:0] binary     //Binary code output
);
    
    assign binary={gray[BITSIZE-1],gray[BITSIZE-1:1]^gray[BITSIZE-2:0]};
    
endmodule