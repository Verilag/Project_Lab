`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:37:45
// Design Name: 
// Module Name: team_integration
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


module team_integration(
    input clk_100Mhz, mouse_l, mouse_r, sw15,
    input [11:0] mouse_x, mouse_y, audio_in,
    input [12:0] pixel_index,
    output [15:0] led, colour_chooser,
    output [15:0] seg_nums, output [3:0] dp,
    output [11:0] audio_out
);
        
    // Detect mouse click and update segment status
    wire [12:0] shown_segments;
    click_detector click(.mouse_x(mouse_x), .mouse_y(mouse_y), .left_click(mouse_l), .right_click(mouse_r), 
        .segments(shown_segments), .led15(led[15]));
    
    // Show filled segments, outline and mouse cursor 
    team_integration_oled display(.mouse_x(mouse_x), .mouse_y(mouse_y), .shown_segments(shown_segments), 
        .pixel_index(pixel_index), .color_chooser(colour_chooser));

    wire [3:0] number;
    number_decoder decode(.shown_segments(shown_segments), .number(number));
    assign led[15] = sw15 ? number != 10 : 0;
    
    wire [3:0] volume;
    audio_input_task mic(.clk_100Mhz(clk_100Mhz), .audio_in(audio_in), .volume_state(volume));
    assign led[8:0] = (2**volume) - 1;
    
    team_integration_segment(.number(number), .volume(volume), .seg_nums(seg_nums));
    assign dp = (number != 10) ? 4'b0111 : 4'b1111; // Show decimal point if valid number selected
    
    play_audio sound(.clk_100Mhz(clk_100Mhz), .number(number), .audio_out(audio_out));
    assign led[14] = audio_out > 0; 
     
endmodule


// coordinates to segment converter
module coord_to_segment(
    input [6:0] x, y,
    output [12:0] within
);

    assign within[0] = (x >= 18 && y >= 6 && x < 22 && y < 10);
    assign within[1] = (x >= 22 && x < 39 && y >= 6 && y < 10);
    assign within[2] = (x >= 39 && y >= 6 && x < 43 && y < 10);
    assign within[3] = (x >= 18 && x < 22 && y >= 10 && y < 27);
    assign within[4] = (x >= 39 && x < 43 && y >= 10 && y < 27);
    assign within[5] = (x >= 18 && y >= 27 && x < 22 && y < 31);
    assign within[6] = (x >= 22 && x < 39 && y >= 27 && y < 31);
    assign within[7] = (x >= 39 && y >= 27 && x < 43 && y < 31);
    assign within[8] = (x >= 18 && x < 22 && y >= 31 && y < 48);
    assign within[9] = (x >= 39 && x < 43 && y >= 31 && y < 48);
    assign within[10] = (x >= 18 && y >= 48 && x < 22 && y < 52);
    assign within[11] = (x >= 22 && x < 39 && y >= 48 && y < 52);
    assign within[12] = (x >= 39 && y >= 48 && x < 43 && y < 52);

endmodule


module number_decoder(
    input [12:0] shown_segments,
    output reg [3:0] number
);
    
    parameter [12:0] zero = 13'b1_1111_1011_1111;
    parameter [12:0] one = 13'b1_0010_1001_0100;
    parameter [12:0] two = 13'b1_1101_1111_0111;
    parameter [12:0] three = 13'b1_1110_1111_0111;
    parameter [12:0] four = 13'b1_0010_1111_1101;
    parameter [12:0] five = 13'b1_1110_1110_1111;
    parameter [12:0] six = 13'b1_1111_1110_1111;
    parameter [12:0] seven = 13'b1_0010_1001_0111;
    parameter [12:0] eight = 13'b1_1111_1111_1111;
    parameter [12:0] nine = 13'b1_1110_1111_1111;
    
    always @ (shown_segments) begin
        case (shown_segments)
            zero: number <= 0;
            one: number <= 1;
            two: number <= 2;
            three: number <= 3;
            four: number <= 4;
            five: number <= 5;
            six: number <= 6;
            seven: number <= 7;
            eight: number <= 8;
            nine: number <= 9;
            default: number <= 10; // Invalid number
        endcase
    end

endmodule
