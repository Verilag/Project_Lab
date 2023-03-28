`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 12:28:07
// Design Name: 
// Module Name: team_integration_display
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

module team_integration_segment(
    input [3:0] number, // Recognised number
    input [3:0] volume, // Audio input task
    output [27:0] seg
);  

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

    wire [6:0] nums [9:0]; // 10 numbers of 7 bits
    assign nums[0] = ZERO; assign nums[1] = ONE; assign nums[2] = TWO;
    assign nums[3] = THREE; assign nums[4] = FOUR; assign nums[5] = FIVE;
    assign nums[6] = SIX; assign nums[7] = SEVEN; assign nums[8] = EIGHT;
    assign nums[9] = NINE;

    reg [1:0] index = 2'b0;
    reg [6:0] first, second, third, fourth;
    assign seg = { first, second, third, fourth }; 
    
    always @ (number, volume) begin
        fourth = nums[volume];
        third = NONE;
        
        if (number == 10) begin
            first <= NONE;
            second <= NONE;
            
        end else if (number == 9) begin
            first <= ONE;
            second <= ZERO;
            
        end else begin
            first <= ZERO;
            second <= nums[number+1];
        end
    end

endmodule


module click_detector(
    input [6:0] mouse_x, mouse_y,
    input left_click, right_click, led15, 
    output reg [12:0] segments = 13'b0_0000_0000_0000
);
    // Get segment that cursor is currently in
    wire [12:0] within;
    coord_to_segment convert(.x(mouse_x), .y(mouse_y), .within(within));
    
    // Update segment filled status only on left/right mouse click
    always @ (posedge left_click, posedge right_click, negedge led15) begin     
        if (left_click) segments <= segments | within; // Set segment
        else if (right_click) segments <= segments & ~within; // Clear segment 
        else segments <= 13'b0_0000_0000_0000; // Reset segments
    end

endmodule


module team_integration_oled(
    input [6:0] mouse_x, mouse_y,
    input [12:0] shown_segments, pixel_index,
    output reg [15:0] color_chooser
);
    
    parameter green_color = 16'b00000_111111_00000;
    parameter outline_color = 16'b11111_111111_11111;
    parameter white_color = 16'b11111_111111_11111;
    parameter background_color = 16'b00000_000000_00000;
    
    wire [6:0] row, col;
    assign col = pixel_index % 96;
    assign row = pixel_index / 96;
    
    wire green_border, outline;
    assign green_border = (col == 57 && row < 58) || (row == 57 && col < 58);
    assign outline = ((row > 5 && row <= 52) && (col == 17 || col == 22 || col == 38 || col == 43 )) || 
        ((col >= 17 && col <= 43) && (row == 5 || row == 10 || row == 26 || row == 31 || row == 47 || row == 52));
    
    // Get the segment that the current pixel index is in
    wire [12:0] index_within; // Get one hot encoding of pixel index in which segment
    coord_to_segment get_seg(.x(col), .y(row), .within(index_within));
    
    wire within_cursor; wire [15:0] cursor_color;
    check_draw_cursor check_cursor(
        .mouse_x(mouse_x), .mouse_y(mouse_y),
        .pixel_index(pixel_index),
        .within_cursor(within_cursor),
        .color_chooser(cursor_color)
    );
    
    always @ (pixel_index) begin
        if (within_cursor) color_chooser <= cursor_color;
        else if (green_border) color_chooser <= green_color;
        else if (outline) color_chooser <= outline_color;
        else if (shown_segments & index_within) color_chooser <= white_color;
        else color_chooser <= background_color;
    end

endmodule

module check_draw_cursor(
    input [6:0] mouse_x, mouse_y,
    input [12:0] pixel_index,
    output within_cursor,
    output [15:0] color_chooser
);
    
    wire [6:0] pixel_x, pixel_y;
    assign pixel_x = pixel_index % 96;
    assign pixel_y = pixel_index / 96;
    
    wire [6:0] max_x, max_y;
    assign max_x = (95 - mouse_x < 16) ? 95 : mouse_x + 16;
    assign max_y = (63 - mouse_y < 15) ? 63 : mouse_y + 15;
    
    wire [15:0] cursor [239:0];
    wire [7:0] cursor_pixel_index;
    assign cursor_pixel_index = (pixel_x - mouse_x) + 16 * (pixel_y - mouse_y);
    assign color_chooser = (cursor_pixel_index < 240) ? cursor[cursor_pixel_index] : 0;
    
    assign within_cursor = pixel_x >= mouse_x && pixel_x < max_x 
        && pixel_y >= mouse_y && pixel_y < max_y
        && color_chooser > 0; 

    assign cursor[0] = 16'b00000_000000_00000;
    assign cursor[1] = 16'b00010_000100_00010;
    assign cursor[2] = 16'b00010_000100_00010;
    assign cursor[3] = 16'b00000_000000_00000;
    assign cursor[4] = 16'b00000_000000_00000;
    assign cursor[5] = 16'b00000_000000_00000;
    assign cursor[6] = 16'b00000_000000_00000;
    assign cursor[7] = 16'b00000_000000_00000;
    assign cursor[8] = 16'b00010_000100_00010;
    assign cursor[9] = 16'b00010_000100_00010;
    assign cursor[10] = 16'b00010_000100_00010;
    assign cursor[11] = 16'b00000_000000_00000;
    assign cursor[12] = 16'b00000_000000_00000;
    assign cursor[13] = 16'b00000_000000_00000;
    assign cursor[14] = 16'b00000_000000_00000;
    assign cursor[15] = 16'b00000_000000_00000;
    
    assign cursor[16] = 16'b00010_000100_00010;
    assign cursor[17] = 16'b11010_110100_11010;
    assign cursor[18] = 16'b11100_111000_11100;
    assign cursor[19] = 16'b00101_001001_00101;
    assign cursor[20] = 16'b00000_000000_00000;
    assign cursor[21] = 16'b00000_000000_00000;
    assign cursor[22] = 16'b00010_000100_00010;
    assign cursor[23] = 16'b00011_000110_00011;
    assign cursor[24] = 16'b10011_100110_10011;
    assign cursor[25] = 16'b11100_111000_11100;
    assign cursor[26] = 16'b11011_110110_11011;
    assign cursor[27] = 16'b00100_001000_00100;
    assign cursor[28] = 16'b00000_000000_00000;
    assign cursor[29] = 16'b00000_000000_00000;
    assign cursor[30] = 16'b00000_000000_00000;
    assign cursor[31] = 16'b00000_000000_00000;
    
    assign cursor[32] = 16'b00010_000100_00010;
    assign cursor[33] = 16'b11110_111011_11110;
    assign cursor[34] = 16'b11111_111111_11111;
    assign cursor[35] = 16'b11100_111000_11100;
    assign cursor[36] = 16'b00101_001001_00101;
    assign cursor[37] = 16'b00010_000100_00010;
    assign cursor[38] = 16'b10100_101000_10100;
    assign cursor[39] = 16'b11011_110110_11011;
    assign cursor[40] = 16'b01000_001111_01000;
    assign cursor[41] = 16'b11000_110000_11000;
    assign cursor[42] = 16'b11111_111111_11111;
    assign cursor[43] = 16'b11100_111000_11100;
    assign cursor[44] = 16'b00011_000101_00011;
    assign cursor[45] = 16'b00000_000000_00000;
    assign cursor[46] = 16'b00000_000000_00000;
    assign cursor[47] = 16'b00000_000000_00000;
    
    assign cursor[48] = 16'b00010_000011_00010;
    assign cursor[49] = 16'b10101_101010_10101;
    assign cursor[50] = 16'b11111_111111_11111;
    assign cursor[51] = 16'b11111_111111_11111;
    assign cursor[52] = 16'b11110_111011_11110;
    assign cursor[53] = 16'b11100_110111_11100;
    assign cursor[54] = 16'b01000_010000_01000;
    assign cursor[55] = 16'b11000_101111_11000;
    assign cursor[56] = 16'b11110_111011_11110;
    assign cursor[57] = 16'b11111_111101_11111;
    assign cursor[58] = 16'b11111_111110_11111;
    assign cursor[59] = 16'b11111_111110_11111;
    assign cursor[60] = 16'b00101_001001_00101;
    assign cursor[61] = 16'b00000_000000_00000;
    assign cursor[62] = 16'b00000_000000_00000;
    assign cursor[63] = 16'b00000_000000_00000;
    
    assign cursor[64] = 16'b00000_000000_00000;
    assign cursor[65] = 16'b00011_000110_00011;
    assign cursor[66] = 16'b10110_101100_10110;
    assign cursor[67] = 16'b11111_111111_11111;
    assign cursor[68] = 16'b11111_111111_11111;
    assign cursor[69] = 16'b11111_111111_11111;
    assign cursor[70] = 16'b11101_111010_11101;
    assign cursor[71] = 16'b11111_111101_11111;
    assign cursor[72] = 16'b11111_111111_11111;
    assign cursor[73] = 16'b11111_111110_11111;
    assign cursor[74] = 16'b10000_100000_10000;
    assign cursor[75] = 16'b11110_111011_11110;
    assign cursor[76] = 16'b11100_111000_11100;
    assign cursor[77] = 16'b00011_000101_00011;
    assign cursor[78] = 16'b00000_000000_00000;
    assign cursor[79] = 16'b00000_000000_00000;
    
    assign cursor[80] = 16'b00000_000000_00000;
    assign cursor[81] = 16'b00000_000000_00000;
    assign cursor[82] = 16'b00011_000110_00011;
    assign cursor[83] = 16'b10110_101011_10110;
    assign cursor[84] = 16'b11111_111111_11111;
    assign cursor[85] = 16'b11111_111111_11111;
    assign cursor[86] = 16'b11111_111111_11111;
    assign cursor[87] = 16'b11111_111110_11111;
    assign cursor[88] = 16'b10000_100000_10000;
    assign cursor[89] = 16'b11101_111010_11101;
    assign cursor[90] = 16'b11101_111010_11101;
    assign cursor[91] = 16'b10001_100001_10001;
    assign cursor[92] = 16'b11101_111010_11101;
    assign cursor[93] = 16'b00100_000111_00100;
    assign cursor[94] = 16'b00000_000000_00000;
    assign cursor[95] = 16'b00000_000000_00000;
    
    assign cursor[96] = 16'b00000_000000_00000;
    assign cursor[97] = 16'b00000_000000_00000;
    assign cursor[98] = 16'b00001_000001_00001;
    assign cursor[99] = 16'b00100_000111_00100;
    assign cursor[100] = 16'b10111_101101_10111;
    assign cursor[101] = 16'b11111_111111_11111;
    assign cursor[102] = 16'b11111_111111_11111;
    assign cursor[103] = 16'b11111_111111_11111;
    assign cursor[104] = 16'b11101_111010_11101;
    assign cursor[105] = 16'b10000_100000_10000;
    assign cursor[106] = 16'b11111_111101_11111;
    assign cursor[107] = 16'b11111_111101_11111;
    assign cursor[108] = 16'b11110_111100_11110;
    assign cursor[109] = 16'b00011_000101_00011;
    assign cursor[110] = 16'b00000_000000_00000;
    assign cursor[111] = 16'b00000_000000_00000;
    
    assign cursor[112] = 16'b00000_000000_00000;
    assign cursor[113] = 16'b00000_000000_00000;
    assign cursor[114] = 16'b00001_000010_00001;
    assign cursor[115] = 16'b01101_011010_01101;
    assign cursor[116] = 16'b10001_100010_10001;
    assign cursor[117] = 16'b11000_110000_11000;
    assign cursor[118] = 16'b11111_111111_11111;
    assign cursor[119] = 16'b11111_111111_11111;
    assign cursor[120] = 16'b11111_111111_11111;
    assign cursor[121] = 16'b11110_111100_11110;
    assign cursor[122] = 16'b11111_111111_11111;
    assign cursor[123] = 16'b11111_111111_11111;
    assign cursor[124] = 16'b11101_111001_11101;
    assign cursor[125] = 16'b00100_001000_00100;
    assign cursor[126] = 16'b00010_000100_00010;
    assign cursor[127] = 16'b00000_000000_00000;
    
    assign cursor[128] = 16'b00000_000000_00000;
    assign cursor[129] = 16'b00000_000000_00000;
    assign cursor[130] = 16'b00001_000010_00001;
    assign cursor[131] = 16'b01111_011101_01111;
    assign cursor[132] = 16'b10111_101110_10111;
    assign cursor[133] = 16'b11000_110000_11000;
    assign cursor[134] = 16'b11111_111111_11111;
    assign cursor[135] = 16'b11111_111111_11111;
    assign cursor[136] = 16'b11111_111111_11111;
    assign cursor[137] = 16'b11111_111111_11111;
    assign cursor[138] = 16'b11111_111111_11111;
    assign cursor[139] = 16'b11110_111100_11110;
    assign cursor[140] = 16'b01000_010000_01000;
    assign cursor[141] = 16'b11100_111000_11100;
    assign cursor[142] = 16'b11100_111000_11100;
    assign cursor[143] = 16'b00011_000101_00011;
    
    assign cursor[144] = 16'b00000_000000_00000;
    assign cursor[145] = 16'b00000_000000_00000;
    assign cursor[146] = 16'b00000_000000_00000;
    assign cursor[147] = 16'b00011_000101_00011;
    assign cursor[148] = 16'b10101_101010_10101;
    assign cursor[149] = 16'b11001_110010_11001;
    assign cursor[150] = 16'b11111_111111_11111;
    assign cursor[151] = 16'b11111_111111_11111;
    assign cursor[152] = 16'b11111_111111_11111;
    assign cursor[153] = 16'b11111_111111_11111;
    assign cursor[154] = 16'b11110_111100_11110;
    assign cursor[155] = 16'b11111_111111_11111;
    assign cursor[156] = 16'b11110_111011_11110;
    assign cursor[157] = 16'b11111_111111_11111;
    assign cursor[158] = 16'b11101_111001_11101;
    assign cursor[159] = 16'b00011_000101_00011;
    
    assign cursor[160] = 16'b00000_000000_00000;
    assign cursor[161] = 16'b00000_000000_00000;
    assign cursor[162] = 16'b00000_000000_00000;
    assign cursor[163] = 16'b00000_000000_00000;
    assign cursor[164] = 16'b00100_000111_00100;
    assign cursor[165] = 16'b10101_101001_10101;
    assign cursor[166] = 16'b11000_101111_11000;
    assign cursor[167] = 16'b10111_101110_10111;
    assign cursor[168] = 16'b11000_101111_11000;
    assign cursor[169] = 16'b10101_101010_10101;
    assign cursor[170] = 16'b01000_001111_01000;
    assign cursor[171] = 16'b11110_111011_11110;
    assign cursor[172] = 16'b11111_111111_11111;
    assign cursor[173] = 16'b10110_101100_10110;
    assign cursor[174] = 16'b00100_001000_00100;
    assign cursor[175] = 16'b00000_000000_00000;
    
    assign cursor[176] = 16'b00000_000000_00000;
    assign cursor[177] = 16'b00000_000000_00000;
    assign cursor[178] = 16'b00000_000000_00000;
    assign cursor[179] = 16'b00000_000000_00000;
    assign cursor[180] = 16'b00000_000000_00000;
    assign cursor[181] = 16'b00010_000100_00010;
    assign cursor[182] = 16'b00010_000100_00010;
    assign cursor[183] = 16'b00010_000100_00010;
    assign cursor[184] = 16'b00010_000100_00010;
    assign cursor[185] = 16'b00100_000111_00100;
    assign cursor[186] = 16'b10101_101010_10101;
    assign cursor[187] = 16'b11111_111111_11111;
    assign cursor[188] = 16'b10110_101100_10110;
    assign cursor[189] = 16'b00100_000111_00100;
    assign cursor[190] = 16'b00000_000000_00000;
    assign cursor[191] = 16'b00000_000000_00000;
    
    assign cursor[192] = 16'b00000_000000_00000;
    assign cursor[193] = 16'b00000_000000_00000;
    assign cursor[194] = 16'b00000_000000_00000;
    assign cursor[195] = 16'b00000_000000_00000;
    assign cursor[196] = 16'b00000_000000_00000;
    assign cursor[197] = 16'b00000_000000_00000;
    assign cursor[198] = 16'b00000_000000_00000;
    assign cursor[199] = 16'b00000_000000_00000;
    assign cursor[200] = 16'b00001_000001_00001;
    assign cursor[201] = 16'b01110_011011_01110;
    assign cursor[202] = 16'b11000_110000_11000;
    assign cursor[203] = 16'b10110_101100_10110;
    assign cursor[204] = 16'b00100_000111_00100;
    assign cursor[205] = 16'b00000_000000_00000;
    assign cursor[206] = 16'b00000_000000_00000;
    assign cursor[207] = 16'b00000_000000_00000;
    
    assign cursor[208] = 16'b00000_000000_00000;
    assign cursor[209] = 16'b00000_000000_00000;
    assign cursor[210] = 16'b00000_000000_00000;
    assign cursor[211] = 16'b00000_000000_00000;
    assign cursor[212] = 16'b00000_000000_00000;
    assign cursor[213] = 16'b00000_000000_00000;
    assign cursor[214] = 16'b00000_000000_00000;
    assign cursor[215] = 16'b00000_000000_00000;
    assign cursor[216] = 16'b00010_000011_00010;
    assign cursor[217] = 16'b01110_011011_01110;
    assign cursor[218] = 16'b01111_011101_01111;
    assign cursor[219] = 16'b00011_000110_00011;
    assign cursor[220] = 16'b00000_000000_00000;
    assign cursor[221] = 16'b00000_000000_00000;
    assign cursor[222] = 16'b00000_000000_00000;
    assign cursor[223] = 16'b00000_000000_00000;
    
    assign cursor[224] = 16'b00000_000000_00000;
    assign cursor[225] = 16'b00000_000000_00000;
    assign cursor[226] = 16'b00000_000000_00000;
    assign cursor[227] = 16'b00000_000000_00000;
    assign cursor[228] = 16'b00000_000000_00000;
    assign cursor[229] = 16'b00000_000000_00000;
    assign cursor[230] = 16'b00000_000000_00000;
    assign cursor[231] = 16'b00000_000000_00000;
    assign cursor[232] = 16'b00000_000000_00000;
    assign cursor[233] = 16'b00010_000011_00010;
    assign cursor[234] = 16'b00001_000010_00001;
    assign cursor[235] = 16'b00000_000000_00000;
    assign cursor[236] = 16'b00000_000000_00000;
    assign cursor[237] = 16'b00000_000000_00000;
    assign cursor[238] = 16'b00000_000000_00000;
    assign cursor[239] = 16'b00000_000000_00000;
    
endmodule 
