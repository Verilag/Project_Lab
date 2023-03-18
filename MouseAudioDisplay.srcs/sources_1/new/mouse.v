`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 00:35:10
// Design Name: 
// Module Name: mouse
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

module limit_mouse_coor(
    input [6:0] x, y,
    output [6:0] limit_x, limit_y
);
    
    parameter screen_height = 64;
    parameter screen_width = 96;
    
    assign limit_x = (x >= screen_width-2) ? screen_width-2 : (x <= 0) ? 0 : x;
    assign limit_y = (y >= screen_height-2) ? screen_height-2 : (y <= 0) ? 0 : y;
    
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
