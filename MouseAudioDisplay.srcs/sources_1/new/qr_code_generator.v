`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2023 18:27:12
// Design Name: 
// Module Name: qr_code
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


module numeric_encoding(
    input [15:0] number,
    output reg [127:0] encoded
    );
    always @(*) begin
        if (number[15:12]) begin // 3 digits
            encoded[127:118] <= number[7:4]  + number[11:8] * 10 + number[15:12] * 100;
            encoded[118:115] <= number[3:0];
            encoded[114:0] <= 0;
            end //3 digits
        else if (number[11:8]) begin // 2 digits
            encoded[127:121] <= number[7:4] + number[11:8] * 10;
            encoded[120:117] <= number[3:0];
            encoded[116:0] <= 0;
            end // 2 digits
        else begin // 1 digit
            encoded[127:125] <= number[7:4];
            encoded[124:121] <= number[3:0];
            encoded[120:0] <= 0; 
            end
    end // enable
    
endmodule

module get_error_codeword(
    input clock,
    //input enable
    input send,
    input [31:0] timing_delay,
    input [127:0] data_codeword, // 16 word of 8 bits
    output reg [79:0] error_codeword // 10 word of 8 bits
    );
    reg [7:0] data_polynomial [25:0];
    reg [7:0] log_polynomial [25:0]; // deg 10 polynomial in log_gen scale
    parameter [4:0] error_bits = 10;
    
    reg [3:0] deg = 15;
    reg [7:0] compute_state = 0;
    reg [12:0] count = 0;
    
    integer i,j;
    
    // exp table for GF(8)
    wire [7:0] exp_table_gf8 [255:0];
    // log table for GF(8)
    wire [7:0] log_table_gf8 [255:0];
    
    always @(posedge clock) begin
    //if (enable) begin
        case(compute_state)
        0: begin //idle
            compute_state <= (send)? 1: compute_state;
            deg <= 25;
        end // idle
        1: begin //initialise deg 25 polynomial and deg 10 log generator polynomial
             for (i = 0; i <=  (deg-error_bits); i = i + 1) begin
                for (j = 0; j < 8; j = j + 1) begin
                    data_polynomial[i+ error_bits][j] = data_codeword[8 * i + j];
                end
           end // initialise data_polynomial 
           log_polynomial[10] <= 1;
           log_polynomial[9] <= 251;
           log_polynomial[8] <= 67;
           log_polynomial[7] <= 46;
           log_polynomial[6] <= 61;
           log_polynomial[5] <= 118;
           log_polynomial[4] <= 70;
           log_polynomial[3] <= 64;
           log_polynomial[2] <= 94;
           log_polynomial[1] <= 32;
           log_polynomial[0] <= 45;
           for (i = 0; i < error_bits; i = i + 1) begin
               data_polynomial[i] = 0;
           end // initialise data_polynomial
           compute_state <= 2;
           
        end// initialise log polynomial
        2: begin // update log polynomial
            for (i = error_bits; i == 0; i = i - 1) begin // update log polynomial
                log_polynomial[i + deg - error_bits] <= log_polynomial[i] + log_table_gf8[data_polynomial[deg]];
            end // scaling of log polynomial 
            compute_state <= 3;
        end // update log polynomial
        
        3: begin //update data polynomial
            for (i = 0; i <= deg ;i = i + 1) begin
                data_polynomial[i] <= data_polynomial[i] ^ exp_table_gf8[log_polynomial[i]];
            end
            compute_state <= 4;
        end // update data polynomial
        4: begin // update degree
            if (deg < 10) begin // terminate
                compute_state <= 5;
            end // terminate
            else if ((data_polynomial[deg] == 0) && (deg > 0)) begin // drop degree
                deg <= deg - 1;
            end // drop degree
            else begin // return to updating log polynomial
                compute_state <= 2;
            end // return to updating log polynomial
        end 
        5: begin //update error code word
            error_codeword[7:0] <= data_polynomial[0];
            error_codeword[15:8] <= data_polynomial[1];
            error_codeword[23:16] <= data_polynomial[2];
            error_codeword[31:24] <= data_polynomial[3];
            error_codeword[39:32] <= data_polynomial[4];
            error_codeword[47:40] <= data_polynomial[5];
            error_codeword[55:48] <= data_polynomial[6];
            error_codeword[63:56] <= data_polynomial[7];
            error_codeword[71:64] <= data_polynomial[8];
            error_codeword[79:72] <= data_polynomial[9];
            compute_state <= 6;
            count <= 0;
        end
        6: begin
            if (count >= timing_delay) begin // return to idle
                count <= 0;
                compute_state <= 0;
                end // return to idle
            else begin
                count <= count + 1;
            end //delay
        end // delay state
        endcase // algorithm ends
        //end // end enable
    end// clock edge
    


    assign exp_table_gf8[0] = 1;
    assign exp_table_gf8[1] = 2;
    assign exp_table_gf8[2] = 4;
    assign exp_table_gf8[3] = 8;
    assign exp_table_gf8[4] = 16;
    assign exp_table_gf8[5] = 32;
    assign exp_table_gf8[6] = 64;
    assign exp_table_gf8[7] = 128;
    assign exp_table_gf8[8] = 29;
    assign exp_table_gf8[9] = 58;
    assign exp_table_gf8[10] = 116;
    assign exp_table_gf8[11] = 232;
    assign exp_table_gf8[12] = 205;
    assign exp_table_gf8[13] = 135;
    assign exp_table_gf8[14] = 19;
    assign exp_table_gf8[15] = 38;
    assign exp_table_gf8[16] = 76;
    assign exp_table_gf8[17] = 152;
    assign exp_table_gf8[18] = 45;
    assign exp_table_gf8[19] = 90;
    assign exp_table_gf8[20] = 180;
    assign exp_table_gf8[21] = 117;
    assign exp_table_gf8[22] = 234;
    assign exp_table_gf8[23] = 201;
    assign exp_table_gf8[24] = 143;
    assign exp_table_gf8[25] = 3;
    assign exp_table_gf8[26] = 6;
    assign exp_table_gf8[27] = 12;
    assign exp_table_gf8[28] = 24;
    assign exp_table_gf8[29] = 48;
    assign exp_table_gf8[30] = 96;
    assign exp_table_gf8[31] = 192;
    assign exp_table_gf8[32] = 157;
    assign exp_table_gf8[33] = 39;
    assign exp_table_gf8[34] = 78;
    assign exp_table_gf8[35] = 156;
    assign exp_table_gf8[36] = 37;
    assign exp_table_gf8[37] = 74;
    assign exp_table_gf8[38] = 148;
    assign exp_table_gf8[39] = 53;
    assign exp_table_gf8[40] = 106;
    assign exp_table_gf8[41] = 212;
    assign exp_table_gf8[42] = 181;
    assign exp_table_gf8[43] = 119;
    assign exp_table_gf8[44] = 238;
    assign exp_table_gf8[45] = 193;
    assign exp_table_gf8[46] = 159;
    assign exp_table_gf8[47] = 35;
    assign exp_table_gf8[48] = 70;
    assign exp_table_gf8[49] = 140;
    assign exp_table_gf8[50] = 5;
    assign exp_table_gf8[51] = 10;
    assign exp_table_gf8[52] = 20;
    assign exp_table_gf8[53] = 40;
    assign exp_table_gf8[54] = 80;
    assign exp_table_gf8[55] = 160;
    assign exp_table_gf8[56] = 93;
    assign exp_table_gf8[57] = 186;
    assign exp_table_gf8[58] = 105;
    assign exp_table_gf8[59] = 210;
    assign exp_table_gf8[60] = 185;
    assign exp_table_gf8[61] = 111;
    assign exp_table_gf8[62] = 222;
    assign exp_table_gf8[63] = 161;
    assign exp_table_gf8[64] = 95;
    assign exp_table_gf8[65] = 190;
    assign exp_table_gf8[66] = 97;
    assign exp_table_gf8[67] = 194;
    assign exp_table_gf8[68] = 153;
    assign exp_table_gf8[69] = 47;
    assign exp_table_gf8[70] = 94;
    assign exp_table_gf8[71] = 188;
    assign exp_table_gf8[72] = 101;
    assign exp_table_gf8[73] = 202;
    assign exp_table_gf8[74] = 137;
    assign exp_table_gf8[75] = 15;
    assign exp_table_gf8[76] = 30;
    assign exp_table_gf8[77] = 60;
    assign exp_table_gf8[78] = 120;
    assign exp_table_gf8[79] = 240;
    assign exp_table_gf8[80] = 253;
    assign exp_table_gf8[81] = 231;
    assign exp_table_gf8[82] = 211;
    assign exp_table_gf8[83] = 187;
    assign exp_table_gf8[84] = 107;
    assign exp_table_gf8[85] = 214;
    assign exp_table_gf8[86] = 177;
    assign exp_table_gf8[87] = 254;
    assign exp_table_gf8[88] = 225;
    assign exp_table_gf8[89] = 223;
    assign exp_table_gf8[90] = 163;
    assign exp_table_gf8[91] = 91;
    assign exp_table_gf8[92] = 182;
    assign exp_table_gf8[93] = 113;
    assign exp_table_gf8[94] = 226;
    assign exp_table_gf8[95] = 217;
    assign exp_table_gf8[96] = 175;
    assign exp_table_gf8[97] = 67;
    assign exp_table_gf8[98] = 134;
    assign exp_table_gf8[99] = 17;
    assign exp_table_gf8[101] = 34;
    assign exp_table_gf8[102] = 68;
    assign exp_table_gf8[103] = 136;
    assign exp_table_gf8[104] = 13;
    assign exp_table_gf8[105] = 26;
    assign exp_table_gf8[106] = 52;
    assign exp_table_gf8[107] = 104;
    assign exp_table_gf8[108] = 208;
    assign exp_table_gf8[109] = 189;
    assign exp_table_gf8[110] = 103;
    assign exp_table_gf8[111] = 206;
    assign exp_table_gf8[112] = 129;
    assign exp_table_gf8[113] = 31;
    assign exp_table_gf8[114] = 62;
    assign exp_table_gf8[115] = 124;
    assign exp_table_gf8[116] = 248;
    assign exp_table_gf8[117] = 237;
    assign exp_table_gf8[118] = 199;
    assign exp_table_gf8[119] = 147;
    assign exp_table_gf8[120] = 59;
    assign exp_table_gf8[121] = 118;
    assign exp_table_gf8[122] = 236;
    assign exp_table_gf8[123] = 197;
    assign exp_table_gf8[124] = 151;
    assign exp_table_gf8[125] = 51;
    assign exp_table_gf8[126] = 102;
    assign exp_table_gf8[127] = 204;
    assign exp_table_gf8[128] = 133;
    assign exp_table_gf8[129] = 23;
    assign exp_table_gf8[130] = 46;
    assign exp_table_gf8[131] = 92;
    assign exp_table_gf8[132] = 184;
    assign exp_table_gf8[133] = 109;
    assign exp_table_gf8[134] = 218;
    assign exp_table_gf8[135] = 169;
    assign exp_table_gf8[136] = 79;
    assign exp_table_gf8[137] = 158;
    assign exp_table_gf8[138] = 33;
    assign exp_table_gf8[139] = 66;
    assign exp_table_gf8[140] = 132;
    assign exp_table_gf8[141] = 21;
    assign exp_table_gf8[142] = 42;
    assign exp_table_gf8[143] = 84;
    assign exp_table_gf8[144] = 168;
    assign exp_table_gf8[145] = 77;
    assign exp_table_gf8[146] = 154;
    assign exp_table_gf8[147] = 41;
    assign exp_table_gf8[148] = 82;
    assign exp_table_gf8[149] = 164;
    assign exp_table_gf8[150] = 85;
    assign exp_table_gf8[151] = 170;
    assign exp_table_gf8[152] = 73;
    assign exp_table_gf8[153] = 146;
    assign exp_table_gf8[154] = 57;
    assign exp_table_gf8[155] = 114;
    assign exp_table_gf8[156] = 228;
    assign exp_table_gf8[157] = 213;
    assign exp_table_gf8[158] = 183;
    assign exp_table_gf8[159] = 115;
    assign exp_table_gf8[160] = 230;
    assign exp_table_gf8[161] = 209;
    assign exp_table_gf8[162] = 191;
    assign exp_table_gf8[163] = 99;
    assign exp_table_gf8[164] = 198;
    assign exp_table_gf8[165] = 145;
    assign exp_table_gf8[166] = 63;
    assign exp_table_gf8[167] = 126;
    assign exp_table_gf8[168] = 252;
    assign exp_table_gf8[169] = 229;
    assign exp_table_gf8[170] = 215;
    assign exp_table_gf8[171] = 179;
    assign exp_table_gf8[172] = 123;
    assign exp_table_gf8[173] = 246;
    assign exp_table_gf8[174] = 241;
    assign exp_table_gf8[175] = 255;
    assign exp_table_gf8[176] = 227;
    assign exp_table_gf8[177] = 219;
    assign exp_table_gf8[178] = 171;
    assign exp_table_gf8[179] = 75;
    assign exp_table_gf8[180] = 150;
    assign exp_table_gf8[181] = 49;
    assign exp_table_gf8[182] = 98;
    assign exp_table_gf8[183] = 196;
    assign exp_table_gf8[184] = 149;
    assign exp_table_gf8[185] = 55;
    assign exp_table_gf8[186] = 110;
    assign exp_table_gf8[187] = 220;
    assign exp_table_gf8[188] = 165;
    assign exp_table_gf8[189] = 87;
    assign exp_table_gf8[190] = 174;
    assign exp_table_gf8[191] = 65;
    assign exp_table_gf8[192] = 130;
    assign exp_table_gf8[193] = 25;
    assign exp_table_gf8[194] = 50;
    assign exp_table_gf8[195] = 100;
    assign exp_table_gf8[196] = 200;
    assign exp_table_gf8[197] = 141;
    assign exp_table_gf8[198] = 7;
    assign exp_table_gf8[199] = 14;
    assign exp_table_gf8[200] = 28;
    assign exp_table_gf8[201] = 56;
    assign exp_table_gf8[202] = 112;
    assign exp_table_gf8[203] = 224;
    assign exp_table_gf8[204] = 221;
    assign exp_table_gf8[205] = 167;
    assign exp_table_gf8[206] = 83;
    assign exp_table_gf8[207] = 166;
    assign exp_table_gf8[208] = 81;
    assign exp_table_gf8[209] = 162;
    assign exp_table_gf8[210] = 89;
    assign exp_table_gf8[211] = 178;
    assign exp_table_gf8[212] = 121;
    assign exp_table_gf8[213] = 242;
    assign exp_table_gf8[214] = 249;
    assign exp_table_gf8[215] = 239;
    assign exp_table_gf8[216] = 195;
    assign exp_table_gf8[217] = 155;
    assign exp_table_gf8[218] = 43;
    assign exp_table_gf8[219] = 86;
    assign exp_table_gf8[220] = 172;
    assign exp_table_gf8[221] = 69;
    assign exp_table_gf8[222] = 138;
    assign exp_table_gf8[223] = 9;
    assign exp_table_gf8[224] = 18;
    assign exp_table_gf8[225] = 36;
    assign exp_table_gf8[226] = 72;
    assign exp_table_gf8[227] = 144;
    assign exp_table_gf8[228] = 61;
    assign exp_table_gf8[229] = 122;
    assign exp_table_gf8[230] = 244;
    assign exp_table_gf8[231] = 245;
    assign exp_table_gf8[232] = 247;
    assign exp_table_gf8[233] = 243;
    assign exp_table_gf8[234] = 251;
    assign exp_table_gf8[235] = 235;
    assign exp_table_gf8[236] = 203;
    assign exp_table_gf8[237] = 139;
    assign exp_table_gf8[238] = 11;
    assign exp_table_gf8[239] = 22;
    assign exp_table_gf8[240] = 44;
    assign exp_table_gf8[241] = 88;
    assign exp_table_gf8[242] = 176;
    assign exp_table_gf8[243] = 125;
    assign exp_table_gf8[244] = 250;
    assign exp_table_gf8[245] = 233;
    assign exp_table_gf8[246] = 207;
    assign exp_table_gf8[247] = 131;
    assign exp_table_gf8[248] = 27;
    assign exp_table_gf8[249] = 54;
    assign exp_table_gf8[250] = 108;
    assign exp_table_gf8[251] = 216;
    assign exp_table_gf8[252] = 173;
    assign exp_table_gf8[253] = 71;
    assign exp_table_gf8[254] = 142;
    assign exp_table_gf8[255] = 1;
    
    assign log_table_gf8[1] = 0;
    assign log_table_gf8[2] = 1;
    assign log_table_gf8[3] = 25;
    assign log_table_gf8[4] = 2;
    assign log_table_gf8[5] = 50;
    assign log_table_gf8[6] = 26;
    assign log_table_gf8[7] = 198;
    assign log_table_gf8[8] = 3;
    assign log_table_gf8[9] = 223;
    assign log_table_gf8[10] = 51;
    assign log_table_gf8[11] = 238;
    assign log_table_gf8[12] = 27;
    assign log_table_gf8[13] = 104;
    assign log_table_gf8[14] = 199;
    assign log_table_gf8[15] = 75;
    assign log_table_gf8[16] = 4;
    assign log_table_gf8[17] = 100;
    assign log_table_gf8[18] = 224;
    assign log_table_gf8[19] = 14;
    assign log_table_gf8[20] = 52;
    assign log_table_gf8[21] = 141;
    assign log_table_gf8[22] = 239;
    assign log_table_gf8[23] = 129;
    assign log_table_gf8[24] = 28;
    assign log_table_gf8[25] = 193;
    assign log_table_gf8[26] = 105;
    assign log_table_gf8[27] = 248;
    assign log_table_gf8[28] = 200;
    assign log_table_gf8[29] = 8;
    assign log_table_gf8[30] = 76;
    assign log_table_gf8[31] = 113;
    assign log_table_gf8[32] = 5;
    assign log_table_gf8[33] = 138;
    assign log_table_gf8[34] = 101;
    assign log_table_gf8[35] = 47;
    assign log_table_gf8[36] = 225;
    assign log_table_gf8[37] = 36;
    assign log_table_gf8[38] = 15;
    assign log_table_gf8[39] = 33;
    assign log_table_gf8[40] = 53;
    assign log_table_gf8[41] = 147;
    assign log_table_gf8[42] = 142;
    assign log_table_gf8[43] = 218;
    assign log_table_gf8[44] = 240;
    assign log_table_gf8[45] = 18;
    assign log_table_gf8[46] = 130;
    assign log_table_gf8[47] = 69;
    assign log_table_gf8[48] = 29;
    assign log_table_gf8[49] = 181;
    assign log_table_gf8[50] = 194;
    assign log_table_gf8[51] = 125;
    assign log_table_gf8[52] = 106;
    assign log_table_gf8[53] = 39;
    assign log_table_gf8[54] = 249;
    assign log_table_gf8[55] = 185;
    assign log_table_gf8[56] = 201;
    assign log_table_gf8[57] = 154;
    assign log_table_gf8[58] = 9;
    assign log_table_gf8[59] = 120;
    assign log_table_gf8[60] = 77;
    assign log_table_gf8[61] = 228;
    assign log_table_gf8[62] = 114;
    assign log_table_gf8[63] = 166;
    assign log_table_gf8[64] = 6;
    assign log_table_gf8[65] = 191;
    assign log_table_gf8[66] = 139;
    assign log_table_gf8[67] = 98;
    assign log_table_gf8[68] = 102;
    assign log_table_gf8[69] = 221;
    assign log_table_gf8[70] = 48;
    assign log_table_gf8[71] = 253;
    assign log_table_gf8[72] = 226;
    assign log_table_gf8[73] = 152;
    assign log_table_gf8[74] = 37;
    assign log_table_gf8[75] = 179;
    assign log_table_gf8[76] = 16;
    assign log_table_gf8[77] = 145;
    assign log_table_gf8[78] = 34;
    assign log_table_gf8[79] = 136;
    assign log_table_gf8[80] = 54;
    assign log_table_gf8[81] = 208;
    assign log_table_gf8[82] = 148;
    assign log_table_gf8[83] = 206;
    assign log_table_gf8[84] = 143;
    assign log_table_gf8[85] = 150;
    assign log_table_gf8[86] = 219;
    assign log_table_gf8[87] = 189;
    assign log_table_gf8[88] = 241;
    assign log_table_gf8[89] = 210;
    assign log_table_gf8[90] = 19;
    assign log_table_gf8[91] = 92;
    assign log_table_gf8[92] = 131;
    assign log_table_gf8[93] = 56;
    assign log_table_gf8[94] = 70;
    assign log_table_gf8[95] = 64;
    assign log_table_gf8[96] = 30;
    assign log_table_gf8[97] = 66;
    assign log_table_gf8[98] = 182;
    assign log_table_gf8[99] = 163;
    assign log_table_gf8[101] = 72;
    assign log_table_gf8[102] = 126;
    assign log_table_gf8[103] = 110;
    assign log_table_gf8[104] = 107;
    assign log_table_gf8[105] = 58;
    assign log_table_gf8[106] = 40;
    assign log_table_gf8[107] = 84;
    assign log_table_gf8[108] = 250;
    assign log_table_gf8[109] = 133;
    assign log_table_gf8[110] = 186;
    assign log_table_gf8[111] = 61;
    assign log_table_gf8[112] = 202;
    assign log_table_gf8[113] = 94;
    assign log_table_gf8[114] = 155;
    assign log_table_gf8[115] = 159;
    assign log_table_gf8[116] = 10;
    assign log_table_gf8[117] =  21;
    assign log_table_gf8[118] = 121;
    assign log_table_gf8[119] = 43;
    assign log_table_gf8[120] = 78;
    assign log_table_gf8[121] = 212;
    assign log_table_gf8[122] = 229;
    assign log_table_gf8[123] = 172;
    assign log_table_gf8[124] = 115;
    assign log_table_gf8[125] = 243;
    assign log_table_gf8[126] = 167;
    assign log_table_gf8[127] = 87;
    assign log_table_gf8[128] = 7;
    assign log_table_gf8[129] = 112;
    assign log_table_gf8[130] = 192;
    assign log_table_gf8[131] = 247;
    assign log_table_gf8[132] = 140;
    assign log_table_gf8[133] = 128;
    assign log_table_gf8[134] = 99;
    assign log_table_gf8[135] = 13;
    assign log_table_gf8[136] = 103;
    assign log_table_gf8[137] = 74;
    assign log_table_gf8[138] = 222;
    assign log_table_gf8[139] = 237;
    assign log_table_gf8[140] = 49;
    assign log_table_gf8[141] = 197;
    assign log_table_gf8[142] = 254;
    assign log_table_gf8[143] = 24;
    assign log_table_gf8[144] = 227;
    assign log_table_gf8[145] = 165;
    assign log_table_gf8[146] = 153;
    assign log_table_gf8[147] = 119;
    assign log_table_gf8[148] = 38;
    assign log_table_gf8[149] = 184;
    assign log_table_gf8[150] = 180;
    assign log_table_gf8[151] = 124;
    assign log_table_gf8[152] = 17;
    assign log_table_gf8[153] = 68;
    assign log_table_gf8[154] = 146;
    assign log_table_gf8[155] = 217;
    assign log_table_gf8[156] = 35;
    assign log_table_gf8[157] = 32;
    assign log_table_gf8[158] = 137;
    assign log_table_gf8[159] = 46;
    assign log_table_gf8[160] = 55;
    assign log_table_gf8[161] = 63;
    assign log_table_gf8[162] = 209;
    assign log_table_gf8[163] = 91;
    assign log_table_gf8[164] = 149;
    assign log_table_gf8[165] = 188;
    assign log_table_gf8[166] = 207;
    assign log_table_gf8[167] = 205;
    assign log_table_gf8[168] = 144;
    assign log_table_gf8[169] = 135;
    assign log_table_gf8[170] = 151;
    assign log_table_gf8[171] = 178;
    assign log_table_gf8[172] = 220;
    assign log_table_gf8[173] = 252;
    assign log_table_gf8[174] = 190;
    assign log_table_gf8[175] = 97;
    assign log_table_gf8[176] = 242;
    assign log_table_gf8[177] = 86;
    assign log_table_gf8[178] = 211;
    assign log_table_gf8[179] = 171;
    assign log_table_gf8[180] = 20;
    assign log_table_gf8[181] = 42;
    assign log_table_gf8[182] = 93;
    assign log_table_gf8[183] = 158;
    assign log_table_gf8[184] = 132;
    assign log_table_gf8[185] = 60;
    assign log_table_gf8[186] = 57;
    assign log_table_gf8[187] = 83;
    assign log_table_gf8[188] = 71;
    assign log_table_gf8[189] = 109;
    assign log_table_gf8[190] = 65;
    assign log_table_gf8[191] = 162;
    assign log_table_gf8[192] = 31;
    assign log_table_gf8[193] = 45;
    assign log_table_gf8[194] = 67;
    assign log_table_gf8[195] = 216;
    assign log_table_gf8[196] = 183;
    assign log_table_gf8[197] = 123;
    assign log_table_gf8[198] = 164;
    assign log_table_gf8[199] = 118;
    assign log_table_gf8[200] = 196;
    assign log_table_gf8[201] = 23;
    assign log_table_gf8[202] = 73;
    assign log_table_gf8[203] = 236;
    assign log_table_gf8[204] = 127;
    assign log_table_gf8[205] = 12;
    assign log_table_gf8[206] = 111;
    assign log_table_gf8[207] = 246;
    assign log_table_gf8[208] = 108;
    assign log_table_gf8[209] = 161;
    assign log_table_gf8[210] = 59;
    assign log_table_gf8[211] = 82;
    assign log_table_gf8[212] = 41;
    assign log_table_gf8[213] = 157;
    assign log_table_gf8[214] = 85;
    assign log_table_gf8[215] = 170;
    assign log_table_gf8[216] = 251;
    assign log_table_gf8[217] = 96;
    assign log_table_gf8[218] = 134;
    assign log_table_gf8[219] = 177;
    assign log_table_gf8[220] = 187;
    assign log_table_gf8[221] = 204;
    assign log_table_gf8[222] = 62;
    assign log_table_gf8[223] = 90;
    assign log_table_gf8[224] = 203;
    assign log_table_gf8[225] = 89;
    assign log_table_gf8[226] = 95;
    assign log_table_gf8[227] = 176;
    assign log_table_gf8[228] = 156;
    assign log_table_gf8[229] = 169;
    assign log_table_gf8[230] = 160;
    assign log_table_gf8[231] = 81;
    assign log_table_gf8[232] = 11;
    assign log_table_gf8[233] = 245;
    assign log_table_gf8[234] = 22;
    assign log_table_gf8[235] = 235;
    assign log_table_gf8[236] = 122;
    assign log_table_gf8[237] = 117;
    assign log_table_gf8[238] = 44;
    assign log_table_gf8[239] = 215;
    assign log_table_gf8[240] = 79;
    assign log_table_gf8[241] = 174;
    assign log_table_gf8[242] = 213;
    assign log_table_gf8[243] = 233;
    assign log_table_gf8[244] = 230;
    assign log_table_gf8[245] = 231;
    assign log_table_gf8[246] = 173;
    assign log_table_gf8[247] = 232;
    assign log_table_gf8[248] = 116;
    assign log_table_gf8[249] = 214;
    assign log_table_gf8[250] = 244;
    assign log_table_gf8[251] = 234;
    assign log_table_gf8[252] = 168;
    assign log_table_gf8[253] = 80;
    assign log_table_gf8[254] = 88;
    assign log_table_gf8[255] = 175;
endmodule

module qr_code_generator(
    input send,
    input clock,
    input [15:0] message,
    output [440:0] sent_image
    );
    wire [440:0] image;
    wire [6:0] finder_pattern [6:0];
    wire [14:0] format_info;
    wire [127:0] data_codeword;
    wire [79:0] error_codeword;
    assign sent_image = image;
    
    parameter [31:0] delay = 31'd1000_000;
    
    numeric_encoding encode(
        .number(message),
        .encoded(data_codeword)
        );
    
    get_error_codeword(
        .clock(clock),
            //input enable
         .send(send),
         .timing_delay(delay),
         .data_codeword(data_codeword), // 16 word of 8 bits
         .error_codeword(error_codeword) // 10 word of 8 bits
            );
    
    // hardcoding data bits
    genvar i,k;
    for (i = 0; i < 12; i = i + 1) begin // data blocks x 3
        assign image[i * 21] = data_codeword[127 - 2 * i] ^ (i%2);
        assign image[i * 21 + 1] = data_codeword[127 - 2 * i - 1] ^((i+1)%2);
    end // data block
    
    // coding 4 error block
    for (i = 0; i < 4; i = i + 1) begin //  first block
        assign image[(i + 8)* 21 + 21 -1 ] = error_codeword[2 * i] ^ (i % 2);
        assign image[(i + 8)* 21 + 21  - 2] = error_codeword[2 * i+ 1] ^ ((i + 1) % 2);
        end // first block
    for (i = 0; i < 4; i = i + 1) begin //  third block
        assign image[(i + 8)* 21 + 21  - 5] = error_codeword[2 * i + 16] ^ (i % 2);
        assign image[(i + 8)* 21 + 21  - 1 - 5] = error_codeword[2 * i+ 16+ 1] ^ ((i + 1) % 2);
        end // third block
    for (i = 0; i < 4; i = i + 1) begin // second block
        assign image[(i + 8)* 21 + 21  - 3] = error_codeword[15 - 2 * i - 1] ^ (i % 2);
        assign image[(i + 8)* 21 + 21  - 3 - 1] = error_codeword[15 - 2 * i ] ^ ((i + 1) % 2);
        end // second block
    for (i = 0; i < 4; i = i + 1) begin // fourth block
        assign image[(i + 8)* 21 + 21  - 8] = error_codeword[31 - 2 * i - 1] ^ ((i + 1) % 2);
        assign image[(i + 8)* 21 + 21  - 8 - 1] = error_codeword[31 - 2 * i ] ^ (i % 2);

        end // fourth block
    // Coding for 5 error blocks and bunch of data blocks
    for (i = 0; i < 14; i = i + 1) begin // fifth to seventh block + half of eighth block
        assign image[i * 21 + 20 - 9] = error_codeword[32 + 2 * i] ^ ((i + 1)% 2);
        assign image[i * 21 + 21  - 10- 1] = error_codeword[32 + 2 * i + 1] ^ (i % 2);
        // data blocks
        assign image[i * 21 + 21  - 10- 2] = ((i+ 1) % 2);
        assign image[i * 21 + 21  - 10- 3] = (i % 2);
        end // fifth to seventh block
    for (i = 0; i < 4; i = i + 1) begin // nineth to tenth block
        assign image[440 - 9 - i * 21  ] = error_codeword[71 - 2 * i - 1] ^ ((i + 1)% 2);
        assign image[440 - 9 - i * 21  - 1] = error_codeword[71  - 2 * i ] ^ (i % 2);
        assign image[440 - 9 - i * 21  - 2] = error_codeword[72 + 2 * i ] ^ ((i+1) % 2);
        assign image[440 - 9 - i * 21  - 3] = error_codeword[72 + 2 * i + 1] ^ (i % 2);
        end // fifth to seventh block
    for (i = 0; i < 2; i = i + 1) begin // eight block + opposite data block
        assign image[440 - 9 - (4 * 21) - i * 21  ] = error_codeword[63 - 2 * i - 1] ^ ((i + 1)% 2);
        assign image[440 - 9 - (4 * 21) - i * 21  - 1] = error_codeword[63  - 2 * i ] ^ (i % 2);
        assign image[440 - 9 - (4 * 21) - i * 21  - 2] =  ((i +1) % 2);
        assign image[440 - 9 - (4 * 21) - i * 21  - 3] = (i % 2);
        end
    ///// Empty Data Bits
    for (k = 1; k < 3; k = k + 1) begin // k loop
        for (i = 0; i < 12; i = i + 1) begin // i loop
            assign image[ 2*k + 21 * i ] = ( i) % 2;
            assign image[2*k + 21 * i + 1] = ( i +1 ) %2;
            end // i loops
        end // k loops
    
    
    
    
    
    // first layer
    // assign finder_pattern[6][6:1] = 1;
    // assign finder_pattern[6][0] = 1;
    // assign finder_pattern[0][6:1] = 1;
    // assign finder_pattern[0][0] = 1;
    assign finder_pattern[0] = 7'b1111111;
    assign finder_pattern[6] = 7'b1111111;
    // second layer
    assign finder_pattern[5][6] = 1;
    assign finder_pattern[5][5:1] = 0;
    assign finder_pattern[5][0] = 1;
    
    assign finder_pattern[1][6] = 1;
    assign finder_pattern[1][5:1] = 0;
    assign finder_pattern[1][0] = 1;
    // middle square
    assign finder_pattern[4][6] = 1;
    assign finder_pattern[4][5] = 0;
    assign finder_pattern[4][4:2] = 3'b111;
    assign finder_pattern[4][1] = 0;
    assign finder_pattern[4][0] = 1;
    
    assign finder_pattern[3][6] = 1;
    assign finder_pattern[3][5] = 0;
    assign finder_pattern[3][4:2] = 3'b111;
    assign finder_pattern[3][1] = 0;
    assign finder_pattern[3][0] = 1;
    
    assign finder_pattern[2][6] = 1;
    assign finder_pattern[2][5] = 0;
    assign finder_pattern[2][4:2] = 3'b111;
    assign finder_pattern[2][1] = 0;
    assign finder_pattern[2][0] = 1;
    
    //insert finder patterns
    //pattern 1
    assign image[440:434] = finder_pattern[6];
    assign image[419:413] = finder_pattern[5];
    assign image[398:392] = finder_pattern[4];
    assign image[377:371] = finder_pattern[3];
    assign image[356:350] = finder_pattern[2];
    assign image[335:329] = finder_pattern[1];
    assign image[314:308] = finder_pattern[0];
    //pattern 2
    assign image[426:420] = finder_pattern[6];
    assign image[405:399] = finder_pattern[5];
    assign image[384:378] = finder_pattern[4];
    assign image[363:357] = finder_pattern[3];
    assign image[342:336] = finder_pattern[2];
    assign image[321:315] = finder_pattern[1];
    assign image[300:294] = finder_pattern[0];
    //pattern 3
    assign image[146:140] = finder_pattern[6];
    assign image[125:119] = finder_pattern[5];
    assign image[104:98] = finder_pattern[4];
    assign image[83:77] = finder_pattern[3];
    assign image[62:56] = finder_pattern[2];
    assign image[41:35] = finder_pattern[1];
    assign image[20:14] = finder_pattern[0];
    // separator patterns #1
    assign image[293:286] = 0;
    assign image[433] = 0;
    assign image[412] = 0;
    assign image[391] = 0;
    assign image[370] = 0;
    assign image[349] = 0;
    assign image[328] = 0;
    assign image[307] = 0;
    // separator patterns #2
    assign image[280:273] = 0;
    assign image[427] = 0;
    assign image[406] = 0;
    assign image[385] = 0;
    assign image[364] = 0;
    assign image[343] = 0;
    assign image[322] = 0;
    assign image[301] = 0;
    // separator pattern #3
    assign image[167:160] = 0;
    assign image[139] = 0;
    assign image[118] = 0;
    assign image[97] = 0;
    assign image[76] = 0;
    assign image[55] = 0;
    assign image[34] = 0;
    assign image[13] = 0;
    // horizontal timing pattern
    assign image[306] = 1;
    assign image[305] = 0;
    assign image[304] = 1;
    assign image[303] = 0;
    assign image[302] = 1;
    // vertical timing pattern
    assign image[266] = 1;
    assign image[245] = 0;
    assign image[224] = 1;
    assign image[203] = 0;
    assign image[182] = 1;
    // dark module
    assign image[8 * 21 - 9] = 1;
    // format information: 1-M, bit mask i + j % 2 = 0
    assign format_info[14:0] = 0 ^ 15'b1010_0110_111;
    assign image[272:267] = format_info[14:9];
    assign image[265:264] = format_info[8:7];
    assign image[285] = format_info[6];
    assign image[327] = format_info[5];
    assign image[348] = format_info[4];
    assign image[369] = format_info[3];
    assign image[390] = format_info[2];
    assign image[411] = format_info[1];
    assign image[432] = format_info[0];
    // format information second copy
    assign image[259:252] = format_info[7:0];
    assign image[12] = format_info[14];
    assign image[33] = format_info[13];
    assign image[54] = format_info[12];
    assign image[75] = format_info[11];
    assign image[96] = format_info[10];
    assign image[117] = format_info[9];
    assign image[138] = format_info[8];
    
endmodule
