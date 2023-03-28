`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 20:18:13
// Design Name: 
// Module Name: basic_display
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


module basic_display(
    input enable, clk, reset_display_button, 
    input [10:0] sw,
    input [12:0] pixel_index,
    output reg [15:0] colour_chooser
    );
    
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [7:0]x;
    wire [6:0]y;
    wire [12:0]segm;
    
    parameter [15:0] oled_green = 16'b00000_111111_00000;
    parameter [15:0] oled_white = 16'b11111_111111_11111;
    parameter [15:0] oled_black = 16'b0;
    
    idc idc_one(.index(pixel_index), .x(x), .y(y));
    coord_to_segment cts_one(.x(x), .y(y), .within(segm));
    
     always @(posedge clk) begin
        if (enable) begin
            if (sw[10] && (x == 57 && y < 58 || y == 57 && x < 58)) begin
                colour_chooser <= oled_green;
            end else if (sw[4]) begin
                if (segm[0] || segm[2] || segm[3] || segm[4] || segm[5] || segm[6] || segm[7] || segm[9]) begin
                    colour_chooser <= oled_white;
                end else begin
                    colour_chooser <= oled_black;
                end
            end else if (sw[5]) begin
                if (segm[0] || segm[1] || segm[2] || segm[3] || segm[5] || segm[6] || segm[7] || segm[9] || segm[10] || segm[11] || segm[12]) begin
                    colour_chooser <= oled_white;
                end else begin
                    colour_chooser <= oled_black;
                end
            end else if (sw[6]) begin
                if (segm[0] || segm[1] || segm[2] || segm[3] || segm[5] || segm[6] || segm[7] || segm[8] || segm[9] || segm[10] || segm[11] || segm[12]) begin
                    colour_chooser <= oled_white;
                end else begin
                    colour_chooser <= oled_black;
                end
            end else begin
                colour_chooser <= oled_black;
            end
        end
    end
    
endmodule
