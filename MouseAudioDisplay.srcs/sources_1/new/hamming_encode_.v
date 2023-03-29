`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 01:30:05
// Design Name: 
// Module Name: hamming_encode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hamming_encode(
    input [3:0] inputMessage,
    output [7:0] encodedMessage
    );
    
    // parity bits at index 1, 2, 4. start bit at index 0
    assign encodedMessage[0] = 1;
    assign encodedMessage[1] = inputMessage[0] ^ inputMessage[1] ^ inputMessage[3]; //1
    assign encodedMessage[2] = inputMessage[0] ^ inputMessage[2] ^ inputMessage[3]; //2
    assign encodedMessage[3] = inputMessage[0]; //3 -011
    assign encodedMessage[4] = inputMessage[1] ^ inputMessage[2] ^ inputMessage[3]; //4
    assign encodedMessage[5] = inputMessage[1]; //5 -101
    assign encodedMessage[6] = inputMessage[2]; //6 -110
    assign encodedMessage[7] = inputMessage[3]; //7 -111
    
    
endmodule
