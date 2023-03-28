`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 13:00:48
// Design Name: 
// Module Name: main_menu
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


module main_menu(
    input clk_100Mhz, btnC, btnU, btnD,
    input [6:0] mouse_x, mouse_y,
    input [12:0] pixel_index,
    output [3:0] hover_menu_item,
    output [15:0] color_chooser
);

    wire clk100hz_signal; wire [31:0] scroll_offset;
    clock_gen_hz clk50hz(.clk_100Mhz(clk_100Mhz), .freq(100), .clk(clk100hz_signal));
    check_pb_scroll(.clk100hz(clk100hz_signal), .btnC(btnC), .btnU(btnU), .btnD(btnD), .offset(scroll_offset));

    menu_hover detect_hover(.mouse_x(mouse_x), .mouse_y(mouse_y),
        .scroll_offset(scroll_offset), .menu_entry_hover(hover_menu_item));
        
    display_menu menu_show(.mouse_x(mouse_x), .mouse_y(mouse_y), .pixel_index(pixel_index), 
        .color_chooser(color_chooser), .scroll_offset(scroll_offset), .hover(hover_menu_item));
    
endmodule


module menu_hover(
    input [6:0] mouse_x, mouse_y,
    input [31:0] scroll_offset,
    output reg [3:0] menu_entry_hover = 15
);

    reg [31:0] mouse_index = 0;
    always @ (mouse_x, mouse_y) begin
        if (mouse_y > 11) begin
            mouse_index = (scroll_offset + mouse_y - 11) * 96 + mouse_x;
            menu_entry_hover = mouse_index / 1248;
        end else menu_entry_hover = 15; // Set to invalid entry
    end

endmodule


module check_pb_scroll(
    input clk100hz, btnC, btnU, btnD,
    output reg [31:0] offset = 0
);
    parameter max_entries = 13;
    parameter menu_entry_height = 13;
    parameter menu_display_height = 52;
    parameter max_offset = (max_entries * menu_entry_height) - menu_display_height; // Total menu height - screen height
    
    always @ (posedge clk100hz) begin
        if (btnU) begin
            offset <= (offset == 0) ? 0 : offset - 1;
        end else if (btnD) begin
            offset <= (offset == max_offset) ? max_offset : offset + 1;
        end
    end
    
endmodule


module display_menu(
    input [3:0] hover,
    input [6:0] mouse_x, mouse_y,
    input [12:0] pixel_index,
    input [31:0] scroll_offset,
    output reg [15:0] color_chooser = 0
);
    
    wire within_cursor; wire [15:0] cursor_color;
    check_draw_cursor check_cursor(
        .mouse_x(mouse_x), .mouse_y(mouse_y),
        .pixel_index(pixel_index),
        .within_cursor(within_cursor),
        .color_chooser(cursor_color)
    );
    
    wire within_banner;
    wire [15:0] banner_color;
    verilag_banner banner(.index(pixel_index), .within(within_banner), .color(banner_color));
    
    wire [15:0] menu_color;
    menu_list menu(.pixel_index(pixel_index - 1152), .color(menu_color), .scroll_offset(scroll_offset), .hover(hover));
    
    always @ (pixel_index) begin
        if (within_cursor) color_chooser = cursor_color;
        else if (within_banner) color_chooser = banner_color == 0 ? 16'b11111_000000_00000 : banner_color;
        else color_chooser = menu_color;
    end
    
endmodule
