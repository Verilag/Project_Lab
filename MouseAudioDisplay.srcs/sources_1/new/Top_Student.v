module clk_divider(
    input clk, prescaler,
    output reg clk_output = 0
    );
    
    reg [31:0] COUNT = 32'd0;
    always @ (posedge clk) begin
        COUNT <= COUNT == prescaler ? 32'd0 : COUNT + 1;
        clk_output <= (COUNT == 0) ? ~clk_output : clk_output;
    end
    
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

`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input clk, reset_display_button,
    input [10:0] sw,
    output led15,
    output cs, sdin, sclk, d_cn, resn, vccen, pmoden,
    output [3:0] an, output [6:0] seg, output dp,
    inout PS2Clk, PS2Data
); 

    wire clk6p25m; parameter prescaler_6p25m = 32'd7;
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    wire [15:0] colour_chooser;
    
    clk_divider clk_divider6p25m(.clk(clk), .prescaler(prescaler_6p25m), .clk_output(clk6p25m));
    Oled_Display oled_one(.clk(clk6p25m), .reset(reset_display_button), .frame_begin(frame_begin), .sending_pixels(sending_pixels),
      .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(colour_chooser), .cs(cs), .sdin(sdin), .sclk(sclk), .d_cn(d_cn), .resn(resn), .vccen(vccen),
      .pmoden(pmoden));
    
    wire [11:0] mouse_x, mouse_y;
    wire [3:0] mouse_z;
    wire mouse_l, mouse_m, mouse_r, mouse_new_e;
    
    MouseCtl mouse(.clk(clk), .rst(0), .value(0), .setx(0), .sety(0), .setmax_x(0), .setmax_y(0),
        .xpos(mouse_x), .ypos(mouse_y), .zpos(mouse_z),
        .left(mouse_l), .middle(mouse_m), .right(mouse_r), .new_event(mouse_new_e),
        .ps2_clk(PS2Clk), .ps2_data(PS2Data));
    
    // Limit mouse coordinates to screen dimensions (64 x 96 pixels)
    wire [6:0] limit_x, limit_y;
    limit_mouse_coor limit(.x(mouse_x), .y(mouse_y), .limit_x(limit_x), .limit_y(limit_y));
    
    // Detect mouse click and update segment status
    wire [12:0] shown_segments;
    click_detector click(.mouse_x(limit_x), .mouse_y(limit_y), .left_click(mouse_l), .right_click(mouse_r), 
        .segments(shown_segments));
    
    // Show filled segments, outline and mouse cursor 
    display_pixels display(.mouse_x(limit_x), .mouse_y(limit_y), .shown_segments(shown_segments), 
        .pixel_index(pixel_index), .color_chooser(colour_chooser));

    // wire [3:0] number;
    // number_decoder decode(.shown_segments(shown_segments), .number(number));
    // assign led15 = number != 10;

    // wire clk1m; parameter prescaler_1m = 6'd49;
    // clk_divider clk_divider25m(.clk(clk), .prescaler(prescaler_1m), .clk_output(clk1m));
    // display_segment(.clk(clk1m), .number(number), .volume(0), .an(an), .seg(seg), .dp(dp));
    
endmodule

//module display_segment(
//    input clk,
//    input [3:0] number, // Recognised number
//    input [3:0] volume, // Audio input task
//    output [3:0] an, output [6:0] seg, output dp
//);  

//    parameter NONE = 7'b1111111;
//    parameter ZERO = 7'b1000000;
//    parameter ONE = 7'b1111001;
//    parameter TWO = 7'b0100100;
//    parameter THREE = 7'b0110000;
//    parameter FOUR = 7'b0011001;
//    parameter FIVE = 7'b0010010;
//    parameter SIX = 7'b0000010;
//    parameter SEVEN = 7'b1111000;
//    parameter EIGHT = 7'b1111111;
//    parameter NINE = 7'b0010000;

//    wire [6:0] nums [8:0]; 
//    assign nums = { NINE, EIGHT, SEVEN, SIX, FIVE, FOUR, THREE, TWO, ONE };

//    reg [6:0] display [3:0] = { NONE, NONE, NONE, NONE };
//    reg [1:0] index = 2'b0;

//    assign an = ~(1'b1 << index);
//    assign seg = display[index];
//    assign dp = number != 10 && index == 2;

//    always @ (number, volume) begin
//        if (number == 10) display[3:2] <= { NONE, NONE };
//        else if (number == 9) display[3:2] <= { ONE, ZERO };
//        else display[3:2] <= { ZERO, nums[number] };
//    end

//    always @ (posedge clk) begin
//        index <= index + 1;
//    end

//endmodule

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
    parameter [12:0] nine = 13'b1_0010_1111_1111;
    
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

module limit_mouse_coor(
    input [6:0] x, y,
    output [6:0] limit_x, limit_y
);
    
    parameter screen_height = 64;
    parameter screen_width = 96;
    
    assign limit_x = (x >= screen_width-2) ? screen_width-2 : (x <= 0) ? 0 : x;
    assign limit_y = (y >= screen_height-2) ? screen_height-2 : (y <= 0) ? 0 : y;
    
endmodule

module display_pixels(
    input [6:0] mouse_x, mouse_y,
    input [12:0] shown_segments, pixel_index,
    output reg [15:0] color_chooser
);
    
    parameter cursor_color = 16'b11111_000000_00000;
    parameter green_color = 16'b00000_111111_00000;
    parameter outline_color = 16'b11111_111111_11111;
    parameter white_color = 16'b11111_111111_11111;
    parameter background_color = 16'b00000_000000_00000;
    
    wire [6:0] row, col;
    assign col = pixel_index % 96;
    assign row = pixel_index / 96;
    
    wire green_border, outline;
    assign green_border = (col == 57 && row < 58) || (row == 57 && col < 58);
    assign outline = ((row > 5 && row<=52) && (col == 17 || col == 22 || col == 38 || col == 43 )) || 
        ((col >= 17 && col <= 43) && (row == 5 || row == 10 || row == 26 || row == 31 || row == 47 || row == 52));
    
    // Get the segment that the current pixel index is in
    wire [12:0] index_within; // Get one hot encoding of pixel index in which segment
    coord_to_segment get_seg(.x(col), .y(row), .within(index_within));
    
    always @ (pixel_index) begin
        if (mouse_x == col && mouse_y == row) color_chooser <= cursor_color;
        else if (green_border) color_chooser <= green_color;
        else if (outline) color_chooser <= outline_color;
        else if (shown_segments & index_within) color_chooser <= white_color;
        else color_chooser <= background_color;
    end

endmodule

module click_detector(
    input [6:0] mouse_x, mouse_y,
    input left_click, right_click,
    output reg [12:0] segments = 0
);
    
    // Get segment that cursor is currently in
    wire [12:0] within;
    coord_to_segment convert(.x(mouse_x), .y(mouse_y), .within(within));
    
    // Update segment filled status only on left/right mouse click
    always @ (posedge left_click or posedge right_click) begin
        if (left_click) segments <= segments | within; // Set segment
        else if (right_click) segments <= segments & ~within; // Clear segment
    end

endmodule


//module led_module(
//    input toggle_line_button, x_mouseclick, y_mouseclick, type_mouseclick,
//    input [12:0] pixel_index,
//    output reg [3:0] number
//    );
    
//    wire [7:0] x, y;
//    wire [12:0] segm;
        
//    wire [12:0] segm_clicked;
//    reg [12:0] segm_filled = 0;
//    reg [15:0] colour_chooser;
    
//    parameter [15:0] oled_green = 16'b00000_111111_00000;
//    parameter [15:0] oled_white = 16'b11111_111111_11111;
//    parameter [15:0] oled_black = 16'b0;
          
//    idc idc_one(.index(pixel_index), .x(x), .y(y));
//    coord_to_segment display_to_segm(.x(x), .y(y), .within(segm));
//    coord_to_segment click_to_segm(.x(x_mouseclick), .y(y_mouseclick), .within(segm_clicked));
    
//    always @(*) begin
//        // display module
//        if (toggle_line_button && (x == 57 && y < 58 || y == 57 && x < 58)) begin
//            colour_chooser <= oled_green;
//        end else if (((y>=5 && y<=52) && (x==17 || x==22 || x==38 || x==43 )) || ((x>=17 && x<=43) && (y==5 || y==10 || y==26 || y==31 || y==47 || y==52))) begin
//            // outline
//            colour_chooser <= oled_white;
//        end else if (segm_filled[0] && segm[0] || segm_filled[1] && segm[1] || segm_filled[2] && segm[2] || segm_filled[3] && segm[3] || segm_filled[4] && segm[4] || segm_filled[5] && segm[5] || segm_filled[6] && segm[6] || segm_filled[7] && segm[7] || segm_filled[8] && segm[8] || segm_filled[9] && segm[9] || segm_filled[10] && segm[10] || segm_filled[11] && segm[11] || segm_filled[12] && segm[12]) begin
//            // fill segments based of segm filled
//            colour_chooser <= oled_white;
//        end else begin
//            colour_chooser <= oled_black;
//        end
//        // mouseclick module
//        if (type_mouseclick == 1) begin
//            // left click
//            segm_filled <= segm_filled | segm_clicked;
//        end else if (type_mouseclick == 0) begin
//            //right click
//            segm_filled <= segm_filled & ~segm_clicked;
//        end
//         // number module
//        if (segm_filled == 13'b1111110111111) begin
//            number <= 0;
//        end else if (segm_filled == 13'b1001010010100) begin
//            number <= 1;
//        end else if (segm_filled == 13'b1110111110111) begin
//            number <= 2;
//        end else if (segm_filled == 13'b1111011110111) begin
//            number <= 3;
//        end else if (segm_filled == 13'b1001011111101) begin
//            number <= 4;
//        end else if (segm_filled == 13'b1111011101111) begin
//            number <= 5;
//        end else if (segm_filled == 13'b1111111101111) begin
//            number <= 6;
//        end else if (segm_filled == 13'b1001010010111) begin
//            number <= 7;
//        end else if (segm_filled == 13'b1111111111111) begin
//            number <= 8;
//        end else if (segm_filled == 13'b1001011111111) begin
//            number <= 9;
//        end else begin
//            // invalid number
//            number <= 10;
//        end
//    end
   
//endmodule