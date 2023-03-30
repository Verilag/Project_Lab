`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2023 18:13:39
// Design Name: 
// Module Name: numpad
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


parameter NUMPAD_ONE = 1;
parameter NUMPAD_TWO = 2;
parameter NUMPAD_THREE = 3;
parameter NUMPAD_FOUR = 4;
parameter NUMPAD_FIVE = 5;
parameter NUMPAD_SIX = 6;
parameter NUMPAD_SEVEN = 7;
parameter NUMPAD_EIGHT = 8;
parameter NUMPAD_NINE = 9;
parameter NUMPAD_BS = 10;
parameter NUMPAD_ZERO = 11;
parameter NUMPAD_SEND = 12;


module numpad(
    input enable, mouse_l, sw0, clk_100Mhz, clk1Mhz, clk1hz, 
    input [6:0] mouse_x, mouse_y,
    input [12:0] pixel_index,
    output reg [15:0] color_chooser = 0,
    output [3:0] numpad_dp,
    output [15:0] numpad_nums, numpad_led,
    output [11:0] numpad_audio_out
);

    wire [6:0] index_x, index_y;
    assign index_x = pixel_index % 96;
    assign index_y = pixel_index / 96;
    
    wire [3:0] num_pos, mouse_pos;
    within_num check_num_pos(.x(index_x), .y(index_y), .number(num_pos));
    within_num check_mouse_pos(.x(mouse_x), .y(mouse_y), .number(mouse_pos));
    
    wire send_signal;
    numpad_click_detector np_click(
        .enable(enable), .clk1Mhz(clk1Mhz), .clk1hz(clk1hz),
        .left_click(mouse_l), .hover_num(mouse_pos), .send_signal(send_signal),
        .numpad_nums(numpad_nums), .numpad_dp(numpad_dp)
    );
    assign numpad_led[15] = send_signal;

    wire [15:0] test;
    numpad_audio np_audio(
        .enable(enable), .clk_100Mhz(clk_100Mhz), 
        .speed_toggler(sw0), .send(send_signal), 
        .message(numpad_nums), .led(numpad_led[14:0]), //
        .audio_out(numpad_audio_out)
    );
    
    parameter num_height = 16;
    parameter num_width = 32;
    
    wire [8:0] index; // 9 bit index 0-512
    assign index = (index_y - num_height * ((num_pos-1)/3)) * num_width + 
        (index_x - num_width * ((num_pos-1)%3));
    
    wire [15:0] one_color, two_color, three_color, four_color, 
        five_color, six_color, seven_color, eight_color, 
        nine_color, bs_color, zero_color, send_color;
        
    numpad_zero np_zero(.index(index), .color(zero_color));
    numpad_one np_one(.index(index), .color(one_color));
    numpad_two np_two(.index(index), .color(two_color));
    numpad_three np_three(.index(index), .color(three_color));
    numpad_four np_four(.index(index), .color(four_color));
    numpad_five np_five(.index(index), .color(five_color));
    numpad_six np_six(.index(index), .color(six_color));
    numpad_seven np_seven(.index(index), .color(seven_color));
    numpad_eight np_eight(.index(index), .color(eight_color));
    numpad_nine np_nine(.index(index), .color(nine_color));
    numpad_backspace np_bs(.index(index), .color(bs_color));
    numpad_send np_send(.index(index), .color(send_color));
    
    wire within_cursor; wire [15:0] cursor_color;
    check_draw_cursor check_cursor(
        .mouse_x(mouse_x), .mouse_y(mouse_y),
        .pixel_index(pixel_index),
        .within_cursor(within_cursor),
        .color_chooser(cursor_color)
    );
    
    always @ (pixel_index) begin
        if (within_cursor) color_chooser = cursor_color;
        else begin
            if (num_pos == NUMPAD_ONE) color_chooser = one_color;
            else if (num_pos == NUMPAD_TWO) color_chooser = two_color;
            else if (num_pos == NUMPAD_THREE) color_chooser = three_color;
            
            else if (num_pos == NUMPAD_FOUR) color_chooser = four_color;
            else if (num_pos == NUMPAD_FIVE) color_chooser = five_color;
            else if (num_pos == NUMPAD_SIX) color_chooser = six_color;
            
            else if (num_pos == NUMPAD_SEVEN) color_chooser = seven_color;
            else if (num_pos == NUMPAD_EIGHT) color_chooser = eight_color;
            else if (num_pos == NUMPAD_NINE) color_chooser = nine_color;
            
            else if (num_pos == NUMPAD_BS) color_chooser = bs_color;
            else if (num_pos == NUMPAD_ZERO) color_chooser = zero_color;
            else if (num_pos == NUMPAD_SEND) color_chooser = send_color;
            
            // Invert colors of number on mouse hover
            if (mouse_pos == num_pos) begin
                if (color_chooser == 0) color_chooser = 16'b00000_000000_11111; // Black -> Blue
                else if (color_chooser != 1) color_chooser = 16'b0; // White -> Black
            end
        end
    end 

endmodule


module numpad_click_detector(
    input enable, left_click, clk1Mhz, clk1hz,
    input [3:0] hover_num,
    output [15:0] numpad_nums,
    output [3:0] numpad_dp, 
    output send_signal
);
    
    reg [1:0] seg_count = 3;
    reg prev_left = 0, prev_en = 0, first_click = 1, input_full = 0;
    assign numpad_dp = input_full ? 4'b1111 : clk1hz ? ~(1 << seg_count) : 4'b1111;
    
    reg [15:0] temp_nums = 0;
    wire [3:0] first, second, third, fourth;
    assign first = temp_nums[15:12] == 4'b0000 ? 4'b1111 : temp_nums[15:12]-1;
    assign second = temp_nums[11:8] == 4'b0000 ? 4'b1111 : temp_nums[11:8]-1;
    assign third = temp_nums[7:4] == 4'b0000 ? 4'b1111 : temp_nums[7:4]-1;
    assign fourth = temp_nums[3:0] == 4'b0000 ? 4'b1111 : temp_nums[3:0]-1;
    assign numpad_nums = { first, second, third, fourth };
    
    reg start_send = 0; 
    create_send_signal(.start_send(start_send), .clk1Mhz(clk1Mhz), .send_signal(send_signal));
    
    always @ (posedge clk1Mhz) begin
        if (start_send) start_send <= 0; // Create a short pulse

        else if (enable) begin
            // Don't register first click cuz it's merged with click to enter app
            if (!first_click && left_click > prev_left) begin
                if (hover_num == NUMPAD_BS) begin
                    if (input_full) temp_nums = temp_nums & (16'b1111_1111_1111_1111 << 4*(seg_count+1));
                    else temp_nums = temp_nums & (16'b1111_1111_1111_0000 << 4*(seg_count+1));
                    
                    if (seg_count != 3 && !input_full) begin
                        if (!{temp_nums[seg_count*4+3],temp_nums[seg_count*4+2],temp_nums[seg_count*4+1],temp_nums[seg_count*4]})
                            seg_count = seg_count + 1; 
                    end
                    
                    input_full = 0; // Reset input full
                    
                end else if (hover_num == NUMPAD_SEND) begin
                    start_send <= 1;

                end else begin
                    if (!input_full) begin
                        if (hover_num == NUMPAD_ZERO) temp_nums = (4'b0001 << (4*seg_count)) | temp_nums;
                        else temp_nums = (hover_num+1 << (4*seg_count)) | temp_nums;
                        
                        if (seg_count == 0) input_full = 1;
                    end
                    
                    if (seg_count != 0) seg_count = seg_count - 1;
                end
            end
            
            if (first_click && left_click < prev_left) // Disable flag on first falling edge of enable 
                first_click = 0;
        end
        
        if (enable > prev_en) 
            first_click = 1; // Just entered app
        
        prev_left = left_click;
        prev_en = enable;
    end

endmodule


module create_send_signal(
    input start_send, clk1Mhz,
    output reg send_signal = 0
);
    
    reg [31:0] count = 0;
    always @ (posedge clk1Mhz, posedge start_send) begin
        if (start_send) begin
            count <= 0;
            send_signal <= 1;
        end else if (send_signal) begin
            if (count >= 800_000) begin
                send_signal <= 0;
                count <= 0;
            end else count <= count + 1;
        end
    end

endmodule


module within_num(
    input [6:0] x, y,
    output reg [3:0] number = 0
);  

    parameter num_height = 16;
    parameter num_width = 32;

    always @ (x,y) begin
        if (x >= 0*num_width && x < 1*num_width && y >= 0*num_height && y < 1*num_height) number = NUMPAD_ONE;
        else if (x >= 1*num_width && x < 2*num_width && y >= 0*num_height && y < 1*num_height) number = NUMPAD_TWO;
        else if (x >= 2*num_width && x < 3*num_width && y >= 0*num_height && y < 1*num_height) number = NUMPAD_THREE;
        
        else if (x >= 0*num_width && x < 1*num_width && y >= 1*num_height && y < 2*num_height) number = NUMPAD_FOUR;
        else if (x >= 1*num_width && x < 2*num_width && y >= 1*num_height && y < 2*num_height) number = NUMPAD_FIVE;
        else if (x >= 2*num_width && x < 3*num_width && y >= 1*num_height && y < 2*num_height) number = NUMPAD_SIX;
        
        else if (x >= 0*num_width && x < 1*num_width && y >= 2*num_height && y < 3*num_height) number = NUMPAD_SEVEN;
        else if (x >= 1*num_width && x < 2*num_width && y >= 2*num_height && y < 3*num_height) number = NUMPAD_EIGHT;
        else if (x >= 2*num_width && x < 3*num_width && y >= 2*num_height && y < 3*num_height) number = NUMPAD_NINE;
        
        else if (x >= 0*num_width && x < 1*num_width && y >= 3*num_height && y < 4*num_height) number = NUMPAD_BS;
        else if (x >= 1*num_width && x < 2*num_width && y >= 3*num_height && y < 4*num_height) number = NUMPAD_ZERO;
        else if (x >= 2*num_width && x < 3*num_width && y >= 3*num_height && y < 4*num_height) number = NUMPAD_SEND;
        
        else number = NUMPAD_ONE;
    end 

endmodule
