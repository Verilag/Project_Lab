`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2023 09:46:49
// Design Name: 
// Module Name: index_to_coord
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


module idc(
    input [12:0] index,
    output [7:0] x,
    output [6:0] y
    );
    
    assign x = index % 96;
    assign y = index / 96;
    
endmodule
