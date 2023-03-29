`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 01:39:30
// Design Name: 
// Module Name: hamming_decode
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


module hamming_decode(
    input [6:0] inputMessage,
    output reg [3:0] decodedMessage
    );
   
    reg [3:0]wrongbit;
    //0 - 1 001
    //1 - 2 010
    //2 - 3 011
    //3 - 4 100
    //4 - 5 101
    //5 - 6 110
    //6 - 7 111
    
    always @ (inputMessage) begin
    
    wrongbit[0] <= inputMessage[0] ^ inputMessage[2] ^ inputMessage[4] ^ inputMessage[6];
    wrongbit[1] <= inputMessage[1] ^ inputMessage[2] ^ inputMessage[5] ^ inputMessage[6];
    wrongbit[2] <= inputMessage[3] ^ inputMessage[4] ^ inputMessage[5] ^ inputMessage[6];
    
    case(wrongbit)
        3: begin
            decodedMessage[0] <= ~inputMessage[2];
            decodedMessage[1] <= inputMessage[4];
            decodedMessage[2] <= inputMessage[5];
            decodedMessage[3] <= inputMessage[6];
           end
        5: begin
            decodedMessage[0] <= inputMessage[2];
            decodedMessage[1] <= ~inputMessage[4];
            decodedMessage[2] <= inputMessage[5];
            decodedMessage[3] <= inputMessage[6];
           end
        6: begin
            decodedMessage[0] <= inputMessage[2];
            decodedMessage[1] <= inputMessage[4];
            decodedMessage[2] <= ~inputMessage[5];
            decodedMessage[3] <= inputMessage[6];
           end
        7: begin
            decodedMessage[0] <= inputMessage[2];
            decodedMessage[1] <= inputMessage[4];
            decodedMessage[2] <= inputMessage[5];
            decodedMessage[3] <= ~inputMessage[6];
           end
        default: begin
            decodedMessage[0] <= inputMessage[2];
            decodedMessage[1] <= inputMessage[4];
            decodedMessage[2] <= inputMessage[5];
            decodedMessage[3] <= inputMessage[6];
           end
    endcase
    end
    
endmodule
