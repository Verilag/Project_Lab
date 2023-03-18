`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:32:42
// Design Name: 
// Module Name: audio
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


module play_audio(
    input clk, // 10kHz clock
    input [3:0] number,
    output reg beep = 0
);
    
    reg [3:0] prev_num = 0;
    reg [31:0] counter = 0;
    
    always @ (posedge clk) begin
        if (number != prev_num) begin
            counter = 0; // Start counting from 0
            beep = number != 10; // Valid new number detected
        end
            
        if (beep) counter = counter + 1; // Increment counter
        
        if (counter >= 1000 * (number+1)) begin 
            // End of beep duration
            counter = 0;
            beep = 0;
        end
        
        prev_num = number;
    end

endmodule
