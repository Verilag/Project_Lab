`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.03.2023 23:13:07
// Design Name: 
// Module Name: output_multiplexer
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
parameter MENU = 0;
parameter BASIC_AUDIO_IN = 1;
parameter BASIC_AUDIO_OUT = 2;
parameter BASIC_MOUSE = 3;
parameter BASIC_DISPLAY = 4;
parameter DYLAN = 6;
parameter JINGYANG = 7;
parameter PAINT = 8;
parameter ZHENGHONG = 9;
parameter TEAM_BASIC = 11;
parameter TEAM_COMPLETE = 12;

module menu_fsm(
    input clk1Mhz, back, left_click,
    input [3:0] hover_entry,
    output reg [3:0] state = MENU
);
    wire invalid_entry;
    assign invalid_entry = hover_entry == 0 || hover_entry == 5 || hover_entry == 10 || hover_entry == 15;
    
    reg prev_left = 0, prev_back = 0;
    always @ (posedge clk1Mhz) begin
        case (state)
            MENU: if (left_click > prev_left && !invalid_entry) state = hover_entry;
            default: if (back > prev_back) state = MENU;
        endcase
        
        prev_left = left_click;
        prev_back = back;
    end

endmodule

module display_multiplexer(
    input [3:0] state,
    input [15:0] menu_color, basic_mouse_color, team_basic_color, basic_display_color, paint_color,
    output reg [15:0] color_chooser
);

    always @ (state) begin
        case (state)
            MENU: color_chooser = menu_color;
            BASIC_MOUSE: color_chooser = basic_mouse_color;
            TEAM_BASIC: color_chooser = team_basic_color;
            BASIC_DISPLAY: color_chooser = basic_display_color;
            PAINT: color_chooser = paint_color;
            default: color_chooser = 0;
        endcase
    end
    
endmodule


module audio_out_multiplexer(
    input [3:0] state,
    input [11:0] team_basic_out, paint_out,
    output reg [11:0] audio_out
);

    always @ (state) begin
        case (state)
            TEAM_BASIC: audio_out = team_basic_out;
            PAINT: audio_out = paint_out;
            default: audio_out = 0;
        endcase
    end
    
endmodule


module led_multiplexer(
    input [3:0] state,
    input [15:0] team_basic_led, paint_led,
    output reg [15:0] led
);

    always @ (state) begin
        case (state)
            TEAM_BASIC: led = team_basic_led;
            PAINT: led = paint_led;
            default: led = 0;
        endcase
    end

endmodule

module seg_multiplexer(
    input clk1khz,
    input [3:0] state,
    input [15:0] team_basic_nums,
    input [3:0] team_basic_decimal,
    output [3:0] an, output reg [6:0] seg = 7'b1111111, output reg dp = 0
);
    
    reg [1:0] index = 0;
    assign an = ~(1'b1 << index);
    always @ (posedge clk1khz) begin
        index <= index + 1;
    end
    
    wire [27:0] team_basic_seg;
    number_to_segment num_seg_1(team_basic_nums, team_basic_seg);
    
    always @ (index) begin
        case (state)
            TEAM_BASIC: begin
                dp = team_basic_decimal[index];
                if (index == 0) seg = team_basic_seg[6:0];
                else if (index == 1) seg = team_basic_seg[13:7];
                else if (index == 2) seg = team_basic_seg[20:14];
                else if (index == 3) seg = team_basic_seg[27:21];
            end 
            default: begin 
                dp = 1;
                seg = 7'b1111111;
            end
        endcase
    end
    
endmodule

module number_to_segment(
    input [15:0] numbers,
    output [27:0] segments
);
    
    wire [3:0] first, second, third, fourth;
    assign first = numbers[15:12];
    assign second = numbers[11:8];
    assign third = numbers[7:4];
    assign fourth = numbers[3:0];

    parameter NONE = 7'b1111111;
    parameter ZERO = 7'b1000000;
    parameter ONE = 7'b1111001;
    parameter TWO = 7'b0100100;
    parameter THREE = 7'b0110000;
    parameter FOUR = 7'b0011001;
    parameter FIVE = 7'b0010010;
    parameter SIX = 7'b0000010;
    parameter SEVEN = 7'b1111000;
    parameter EIGHT = 7'b0000000;
    parameter NINE = 7'b0010000;
    
    wire [6:0] nums [15:0]; // 10 numbers of 7 bits
    assign nums[0] = ZERO; assign nums[1] = ONE; assign nums[2] = TWO;
    assign nums[3] = THREE; assign nums[4] = FOUR; assign nums[5] = FIVE;
    assign nums[6] = SIX; assign nums[7] = SEVEN; assign nums[8] = EIGHT;
    assign nums[9] = NINE;
    assign nums[15] = NONE;
    
    assign segments = { nums[first], nums[second], nums[third], nums[fourth] }; 
        
endmodule
