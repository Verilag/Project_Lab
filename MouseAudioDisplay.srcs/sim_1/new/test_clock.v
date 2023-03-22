`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2023 16:50:19
// Design Name: 
// Module Name: test_clock
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


module test_clock();

    reg clock = 0;
    wire out100ms, out100hz; 

    clock_gen_ms test1(clock, 100, out100ms);
    clock_gen_hz test2(clock, 100, out100hz);
    
    wire out1khz, out1ms;
    clock_gen_ms test3(clock, 1, out1ms);
    clock_gen_hz test4(clock, 1000, out1khz);
    
    always begin
        #5; clock = ~clock;
    end

endmodule
