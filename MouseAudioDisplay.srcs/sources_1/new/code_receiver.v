`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 22:44:13
// Design Name: 
// Module Name: code_receiver
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


module code_receiver(
    input enable,
    input sampling_clock, // 20khz signal
    input transmission_clock, // 100ms clock
    input [31:0] transmission_time, // transmission_time * decimation = sampling frequency
    //input [11:0] sample_data,
    // input [11:0] threshold,
    input [11:0] input_freq,
    input [11:0] freq_high_detect,
    input [11:0] freq_start_detect,
    //input [11:0] min_freq,
    //input [11:0] max_freq,
    output reg [3:0] message,
    output reg message_ready_flag,
    output reg [3:0] led_message_state // debugging code
    );
    wire [3:0] message_wire;
    reg [3:0] message_state = 0;
    reg msg_ready_flag = 1;
    reg [6:0] code = 7'b0;
    reg [6:0] good_code = 7'b0;
    reg [31:0] count;
    
    always @(posedge transmission_clock) begin
        message <= message_wire;
        message_ready_flag <= msg_ready_flag;
        led_message_state <= message_state; // debug code
        
    end // transmission clock
     
    
    hamming_decode decode(.inputMessage(good_code),.decodedMessage(message_wire));
    
    always @(posedge sampling_clock) begin
        
        if (enable) begin
            if (message_state == 0) begin
                if (input_freq >= freq_start_detect) begin
                    message_state <= 1;
                    msg_ready_flag <= 0;
                    count <= 0;
                end // sample_avg >= threshold
            end // message_state = 0, searching for start bit
            else if (count < transmission_time)  begin
               count <= count + 1;
            end // count < transmission time
            else if (message_state < 8) begin // 0< message_state and count == transmission_time
                count <= 0;
                code <= (input_freq >= freq_high_detect)? (code >> 1) + 7'b1_000_000 :(code >> 1);
                message_state = message_state + 1;
            end  // update of code, 0< message_state < 8 and count == transmission_time
            else begin //message_state = 8
                good_code <= code;
                message_state <= 0;
                msg_ready_flag <= 1;
            end // message_state = 8
        end // enable
    end // base_clock 
    
    
    
endmodule