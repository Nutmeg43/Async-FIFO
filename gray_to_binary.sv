/*
 * Author: Jacob Salmon
 * 
 * Description: Implementation of a gray to binary decoder (decodes gray)
 * 
 * Notable Info: Input gray, output binary
 */
 
module gray_to_binary#(parameter BITSIZE = 8)(
    input        [BITSIZE-1:0] gray,             //Gray code being decoded to binary
    output logic [BITSIZE-1:0] binary     //Binary code output
);

    genvar i;
    always_comb begin
        for(int i = 0; i < BITSIZE; i ++) begin
            binary[i] = ^(gray >> i);
        end        
    end
    
endmodule