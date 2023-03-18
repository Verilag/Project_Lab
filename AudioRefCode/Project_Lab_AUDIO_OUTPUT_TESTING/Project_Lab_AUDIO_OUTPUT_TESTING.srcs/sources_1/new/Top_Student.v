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
    input clock_1ns,
    output JXADC1, JXADC2, JXADC3, JXADC4
    

    // Delete this comment and include Basys3 inputs and outputs here
    );
    
    reg [11:0] audio_out = 0;

    // Delete this comment and write your codes and instantiations here
    wire clk20k, clk190, clk50M;
    
   // Instantiate the clock_gen module with named port connections
    clock_gen clk20khz (
        .clock_1ns (clock_1ns),
        .freq (20000),
        .clk (clk20k)
    );
    
    clock_gen clk190hz (
        .clock_1ns (clock_1ns),
        .freq (190),
        .clk (clk190)
    );
    
    clock_gen clk50Mhz (
        .clock_1ns (clock_1ns),  
        .freq (50000000),
        .clk (clk50M)
    );

    Audio_Output audio_out_inst (
        .CLK (clk50M),
        .START (clk20k),
        .DATA1 (audio_out),
        .DATA2 (12'b0),
//        .RST (rst_n),
        .D1 (JXADC2),
        .D2 (JXADC3),
        .CLK_OUT (JXADC4),
        .nSYNC (JXADC1)
//        .DONE (open)
    );
    
    always @ (posedge clk190) begin
         if (audio_out == 0) begin
             audio_out <= 12'b1000_0000_0000;
         end else begin
             audio_out <= 0;
         end 
     end
        
        
    
    
endmodule