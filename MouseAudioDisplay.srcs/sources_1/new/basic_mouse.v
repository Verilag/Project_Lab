`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 19:43:52
// Design Name: 
// Module Name: basic_mouse
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


module basic_mouse(
    input enable, mouse_m,
    input [6:0] mouse_x, mouse_y,
    input [12:0] pixel_index,
    output reg [15:0] color_chooser
);

    parameter screen_height = 64;
    parameter screen_width = 96;
   
    parameter [15:0] black_color = 16'b00000_000000_00000;
    parameter [15:0] red_color = 16'b11111_000000_00000;
   
    wire [6:0] row, col;
    assign row = pixel_index / screen_width;
    assign col = pixel_index % screen_width;
   
    reg enlarge = 0;
    always @ (enlarge, pixel_index) begin
        if (enable) begin
            if (enlarge) begin
                if ((col+1 >=  mouse_x && col-1 <= mouse_x) && (row+1 >= mouse_y && row-1 <= mouse_y))
                    color_chooser <= black_color;
                else color_chooser <= red_color;
            end else begin
                if (mouse_x == col && mouse_y == row)
                    color_chooser <= red_color;
                else color_chooser <= black_color;
            end
        end
    end
    
    always @ (posedge mouse_m) begin
        if (enable) enlarge = ~enlarge;
    end

endmodule