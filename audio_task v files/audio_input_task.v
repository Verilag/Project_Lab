`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2023 09:22:12
// Design Name: 
// Module Name: audio_input_task
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
module find_peak(
    input enable,
    input sampling_clock,
    input [11:0] sample,
    input [31:0] max_sample,
    output reg [11:0] peak
    );
    reg [31:0] count = 0;
    reg [11:0] best = 2048;
    
    always @(posedge sampling_clock) begin
        if (enable) begin
            if (count == max_sample) begin
                peak <= best;
                count <= 0;
                best <= 2048;
            end // count == transmission_period, update average
            else begin
                count = count + 1;
                best <= (best > sample)? best: sample;
            end // count < max_sample, accumulate
            end // enable
    end//one clock cycle
endmodule



module select_volume(
    input  [11:0] data,
    input slow_clock, //enter slow_clock as input
    //input reset_clock,
    //input fast_clock,
    output reg [3:0] volume_state
    );
    always @(posedge slow_clock) begin
    //if (~reset_clock && ~do_not_read) begin
        if (data < 2064) begin
            volume_state <= 4'b0000;
            end
        else if (data < 2090) begin
            volume_state <= 4'b0001;
            end
        else if (data < 2100) begin
            volume_state <= 4'b0010;
            end
        else if (data < 2112) begin
            volume_state <= 4'b0011;
            end
        else if (data < 2150) begin
            volume_state <= 4'b0100;
            end
        else if (data < 2176) begin
            volume_state <= 4'b0101;
            end
        else if (data < 2224) begin
            volume_state <= 4'b0110;
            end
        else if (data < 2304) begin
            volume_state <= 4'b0111;
            end
        else if (data < 2560) begin
            volume_state <= 4'b1000;
            end
        else begin
            volume_state <= 4'b1001;
            end
    
    //end reset clock and do not read
    end //end fast clock

endmodule

module led_select(
    input [3:0] volume_state, // 0000 to 1001
    output reg [8:0] led
    );
    always @(*) begin
        case(volume_state)
            4'b0000: begin
                led = 9'b0_0000_0000;
            end
            4'b0001: begin
                led = 9'b0000_0000_1;
            end
            4'b0010: begin 
                led = 9'b0000_00011;
            end
            4'b0011: begin
                led = 9'b0000_00111;
            end
            4'b0100: begin
                led = 9'b0000_01111;
            end
            4'b0101: begin
                led = 9'b0000_11111;
            end
            4'b0110: begin
                led = 9'b000111111;
            end
            4'b0111: begin
                led = 9'b001111111;
            end
            4'b1000: begin
                led = 9'b011111111;
            end
            4'b1001: begin  
                led = 9'b111111111;
            end 
        endcase
        end
endmodule

module segment_select(
    input [3:0] volume_state, // 0000 to 1001
    input slow_clock,
    output reg [6:0] segment
    );
    always @(slow_clock,volume_state) begin
        case(volume_state)
            4'b0000: begin
                segment <= 7'b1000000;
            end
            4'b0001: begin
                segment <= 7'b1111001;
            end
            4'b0010: begin 
                segment <= 7'b0100100;
            end
            4'b0011: begin
                segment <= 7'b0110000;
            end
            4'b0100: begin
                segment <= 7'b0011001;
            end
            4'b0101: begin
                segment <= 7'b0010010;
            end
            4'b0110: begin
                segment <= 7'b0000010;
            end
            4'b0111: begin
                segment <= 7'b1111000;
            end
            4'b1000: begin
                segment <= 7'b0000000;
            end
            4'b1001: begin  
                segment <= 7'b0010000;
            end 
        endcase
        end
endmodule



module audio_input_task(
    // Delete this comment and include Basys3 inputs and outputs here
    input clock,
    input J_MIC_Pin3,
    output J_MIC_Pin1,
    output J_MIC_Pin4,
    output [8:0] led,
    output [3:0] an,
    output [6:0] seg 
    );
    wire clk1k;
    wire clk10;
    wire clk20k;
    wire clk40;
    wire [11:0] MIC_in;
    wire [11:0] peak;
    wire [3:0] volume_state;
    parameter max_sample = 31'd128;
    wire [8:0] led_wire;
    
    reg enable = 1;
    
    assign an = 4'b1110;
    //assign led[11:9] = 0;
    assign led[8:0] = led_wire;

    clk_divider clk100hz(.clock(clock),.slow_clock(clk1k), .m(49999));
    clk_divider clk20khz(.clock(clock),.slow_clock(clk20k), .m(2499));
    clk_divider clk10hz(.clock(clock), .slow_clock(clk10), .m(4999999));
    //clk_divider clk40hz(.clock(clock),.slow_clock(clk40), .m(1249999));
        
    Audio_Input unit_my_audio(
         .CLK(clock),                  // 100MHz clock
         .cs(clk20k),                   // sampling clock, 20kHz
         .MISO(J_MIC_Pin3),                 // J_MIC3_Pin3, serial mic input
         .clk_samp(J_MIC_Pin1),            // J_MIC3_Pin1
         .sclk(J_MIC_Pin4),            // J_MIC3_Pin4, MIC3 serial clock
         .sample(MIC_in)     // 12-bit audio sample data
        );
    
    //led_select select_led(.volume_state(volume_state),.led(led) );
        
        
    find_peak update(.enable(enable),.sampling_clock(clk1k),
                   .sample(MIC_in),
                   .max_sample(max_sample),
                   .peak(peak)
                   );
    
    select_volume update_volume_state(
        .data(peak),
        //.reset_clock(clk10),
        //.do_not_read(clk20), //enter slow_clock as input
        .volume_state(volume_state),
        .slow_clock(clk10)
        );
            
    segment_select select_seg(
        .slow_clock(clk10),
        .volume_state(volume_state), // 0000 to 1001
        .segment(seg)
        );
    
    led_select(.volume_state(volume_state), .led(led_wire) );
    

endmodule
