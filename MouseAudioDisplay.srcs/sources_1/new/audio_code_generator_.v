`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2023 14:25:07
// Design Name: 
// Module Name: audio_code_generator
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


module audio_code_generator (
    input clk_100M, clk_transmission, enable, [3:0]message, [11:0]freq_high_transmit, [11:0]freq_start_transmit,
    output [11:0] audio_out,
    output reg [7:0] led
    );
       
    reg [11:0] sound_freq = 0;
    reg [3:0] message_stage = 0;

    // Delete this comment and write your codes and instantiations here
    wire clk20k, clk1k, clk50M;
    
    wire [7:0] encodedMessage;
    reg enableHumming = 0;
    reg startBeep = 0;
    wire clk1;

    hamming_encode hamming_encode(
        .inputMessage(message),
        .encodedMessage(encodedMessage)
       );
    
    audio_generator cal_beep_generator(
        .clk_100M(clk_100M), 
        .enable(enableHumming), 
        .sound_freq(sound_freq),
        .audio_out(audio_out)
        ); 
    
    
    always @ (posedge clk_transmission) begin
        if (message_stage) begin
            enableHumming <= encodedMessage[message_stage];
            sound_freq <= freq_high_transmit;
            if (message_stage < 7) begin
                message_stage <= message_stage + 1;
            end 
            else begin
                message_stage <= 0;
            end 
        end else if (enable) begin
            enableHumming <= encodedMessage[message_stage];
            message_stage <= 1;
            sound_freq <= freq_start_transmit;
        end else begin
            enableHumming <= 0;
        end
        led <= encodedMessage;
    end

endmodule