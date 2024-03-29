/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_sbox.v                                                                 *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block Sbox/InvSbox                                                                            *
 *                                                                                                *
 **************************************************************************************************
 *    Synthesis in Vivado:                                                                        *
 *   			LUT:	1								  *
 *			BRAM:	0.5								  *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_sbox (
	/* inputs */
	input			clka,
	input			clkb,
	input			kill,
	input			wea,
	input			web,
	input		[7:0]	addra,
	input		[7:0]	addrb,
	input		[7:0]	dia,
	input		[7:0]	dib,

	/* outputs */
	output 	reg	[7:0]	doa,
	output	reg	[7:0]	dob
	);

/**************************************************************************************************
*        PARAMETERS
 **************************************************************************************************/
parameter LENGTH_RAM = 256;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[7:0]	ram [LENGTH_RAM-1:0];

/**************************************************************************************************
 *            INITIAL                                                                             *
 **************************************************************************************************/
initial
begin
/*
//Inverse S-box:
	ram[0] <= 16'h52; 	ram[1] <= 16'h01; 	ram[2] <= 16'h6a; 	ram[3] <= 16'hd5;
	ram[4] <= 16'h30; 	ram[5] <= 16'h36; 	ram[6] <= 16'ha5; 	ram[7] <= 16'h38;
	ram[8] <= 16'hbf; 	ram[9] <= 16'h40; 	ram[10] <= 16'ha3; 	ram[11] <= 16'h9e;
	ram[12] <= 16'h81; 	ram[13] <= 16'hf3; 	ram[14] <= 16'hd7; 	ram[15] <= 16'hfb;

	ram[16] <= 16'h7c; 	ram[17] <= 16'he3; 	ram[18] <= 16'h39; 	ram[19] <= 16'h82;
	ram[20] <= 16'h9b; 	ram[21] <= 16'h2f; 	ram[22] <= 16'hff; 	ram[23] <= 16'h87;
	ram[24] <= 16'h34; 	ram[25] <= 16'h8e; 	ram[26] <= 16'h43; 	ram[27] <= 16'h44;
	ram[28] <= 16'hc4; 	ram[29] <= 16'hde; 	ram[30] <= 16'he9; 	ram[31] <= 16'hcb;

	ram[32] <= 16'h54; 	ram[33] <= 16'h7b; 	ram[34] <= 16'h94; 	ram[35] <= 16'h32;
	ram[36] <= 16'ha6; 	ram[37] <= 16'hc2; 	ram[38] <= 16'h23; 	ram[39] <= 16'h3d;
	ram[40] <= 16'hee; 	ram[41] <= 16'h4c;	ram[42] <= 16'h95;	ram[43] <= 16'h0b;
	ram[44] <= 16'h42; 	ram[45] <= 16'hfa; 	ram[46] <= 16'hc3; 	ram[47] <= 16'h4e;

	ram[48] <= 16'h08; 	ram[49] <= 16'h2e; 	ram[50] <= 16'ha1; 	ram[51] <= 16'h66;
	ram[52] <= 16'h28; 	ram[53] <= 16'hd9; 	ram[54] <= 16'h24; 	ram[55] <= 16'hb2;
	ram[56] <= 16'h76; 	ram[57] <= 16'h5b; 	ram[58] <= 16'ha2; 	ram[59] <= 16'h49;
	ram[60] <= 16'h6d; 	ram[61] <= 16'h8b; 	ram[62] <= 16'hd1; 	ram[63] <= 16'h25;

	ram[64] <= 16'h72; 	ram[65] <= 16'hf8; 	ram[66] <= 16'hf6; 	ram[67] <= 16'h64;
	ram[68] <= 16'h86; 	ram[69] <= 16'h68; 	ram[70] <= 16'h98; 	ram[71] <= 16'h16;
	ram[72] <= 16'hd4; 	ram[73] <= 16'ha4; 	ram[74] <= 16'h5c; 	ram[75] <= 16'hcc;
	ram[76] <= 16'h5d; 	ram[77] <= 16'h65; 	ram[78] <= 16'hb6; 	ram[79] <= 16'h92;

	ram[80] <= 16'h6c; 	ram[81] <= 16'h70; 	ram[82] <= 16'h48; 	ram[83] <= 16'h50;
	ram[84] <= 16'hfd; 	ram[85] <= 16'hed; 	ram[86] <= 16'hb9; 	ram[87] <= 16'hda;
	ram[88] <= 16'h5e; 	ram[89] <= 16'h15; 	ram[90] <= 16'h46; 	ram[91] <= 16'h57;
	ram[92] <= 16'ha7; 	ram[93] <= 16'h8d; 	ram[94] <= 16'h9d; 	ram[95] <= 16'h84;

	ram[96] <= 16'h90; 	ram[97] <= 16'hd8; 	ram[98] <= 16'hab; 	ram[99] <= 16'h00;
	ram[100] <= 16'h8c; 	ram[101] <= 16'hbc; 	ram[102] <= 16'hd3; 	ram[103] <= 16'h0a;
	ram[104] <= 16'hf7; 	ram[105] <= 16'he4; 	ram[106] <= 16'h58; 	ram[107] <= 16'h05;
	ram[108] <= 16'hb8; 	ram[109] <= 16'hb3; 	ram[110] <= 16'h45; 	ram[111] <= 16'h06;

	ram[112] <= 16'hd0; 	ram[113] <= 16'h2c; 	ram[114] <= 16'h1e; 	ram[115] <= 16'h8f;
	ram[116] <= 16'hca; 	ram[117] <= 16'h3f; 	ram[118] <= 16'h0f; 	ram[119] <= 16'h02;
	ram[120] <= 16'hc1; 	ram[121] <= 16'haf; 	ram[122] <= 16'hbd; 	ram[123] <= 16'h03;
	ram[124] <= 16'h01; 	ram[125] <= 16'h13; 	ram[126] <= 16'h8a; 	ram[127] <= 16'h6b;

	ram[128] <= 16'h3a; 	ram[129] <= 16'h91; 	ram[130] <= 16'h11; 	ram[131] <= 16'h41;
	ram[132] <= 16'h4f; 	ram[133] <= 16'h67; 	ram[134] <= 16'hdc; 	ram[135] <= 16'hea;
	ram[136] <= 16'h97; 	ram[137] <= 16'hf2; 	ram[138] <= 16'hcf; 	ram[139] <= 16'hce;
	ram[140] <= 16'hf0; 	ram[141] <= 16'hb4; 	ram[142] <= 16'he6; 	ram[143] <= 16'h73;

	ram[144] <= 16'h96; 	ram[145] <= 16'hac; 	ram[146] <= 16'h74; 	ram[147] <= 16'h22;
	ram[148] <= 16'he7; 	ram[149] <= 16'had; 	ram[150] <= 16'h35; 	ram[151] <= 16'h85;
	ram[152] <= 16'he2; 	ram[153] <= 16'hf9; 	ram[154] <= 16'h37; 	ram[155] <= 16'he8;
	ram[156] <= 16'h1c; 	ram[157] <= 16'h75; 	ram[158] <= 16'hdf; 	ram[159] <= 16'h6e;

	ram[160] <= 16'h47; 	ram[161] <= 16'hf1; 	ram[162] <= 16'h1a; 	ram[163] <= 16'h71;
	ram[164] <= 16'h1d; 	ram[165] <= 16'h29; 	ram[166] <= 16'hc5; 	ram[167] <= 16'h89;
	ram[168] <= 16'h6f; 	ram[169] <= 16'hb7; 	ram[170] <= 16'h62; 	ram[171] <= 16'h0e;
	ram[172] <= 16'haa; 	ram[173] <= 16'h18; 	ram[174] <= 16'hbe; 	ram[175] <= 16'h1b;

	ram[176] <= 16'hfc; 	ram[177] <= 16'h56; 	ram[178] <= 16'h3e; 	ram[179] <= 16'h4b;
	ram[180] <= 16'hc6; 	ram[181] <= 16'hd2; 	ram[182] <= 16'h79; 	ram[183] <= 16'h20;
	ram[184] <= 16'h9a; 	ram[185] <= 16'hdb; 	ram[186] <= 16'hc0; 	ram[187] <= 16'hfe;
	ram[188] <= 16'h78; 	ram[189] <= 16'hcd; 	ram[190] <= 16'h5a; 	ram[191] <= 16'hf4;

	ram[192] <= 16'h1f; 	ram[193] <= 16'hdd; 	ram[194] <= 16'ha8; 	ram[195] <= 16'h33;
	ram[196] <= 16'h88; 	ram[197] <= 16'h07; 	ram[198] <= 16'hc7; 	ram[199] <= 16'h31;
	ram[200] <= 16'hb1; 	ram[201] <= 16'h12; 	ram[202] <= 16'h10; 	ram[203] <= 16'h59;
	ram[204] <= 16'h27; 	ram[205] <= 16'h80; 	ram[206] <= 16'hec; 	ram[207] <= 16'h5f;

	ram[208] <= 16'h60; 	ram[209] <= 16'h51; 	ram[210] <= 16'h7f; 	ram[211] <= 16'ha9;
	ram[212] <= 16'h19; 	ram[213] <= 16'hb5; 	ram[214] <= 16'h4a;	ram[215] <= 16'h0d;
	ram[216] <= 16'h2d; 	ram[217] <= 16'he5; 	ram[218] <= 16'h7a;	ram[219] <= 16'h9f;
	ram[220] <= 16'h93; 	ram[221] <= 16'hc9; 	ram[222] <= 16'h9c; 	ram[223] <= 16'hef;

	ram[224] <= 16'ha0; 	ram[225] <= 16'he0; 	ram[226] <= 16'h3b; 	ram[227] <= 16'h4d;
	ram[228] <= 16'hae; 	ram[229] <= 16'h2a; 	ram[230] <= 16'hf5; 	ram[231] <= 16'hb0;
	ram[232] <= 16'hc8; 	ram[233] <= 16'heb; 	ram[234] <= 16'hbb; 	ram[235] <= 16'h3c;
	ram[236] <= 16'h83; 	ram[237] <= 16'h53; 	ram[238] <= 16'h99; 	ram[239] <= 16'h61;

	ram[240] <= 16'h17; 	ram[241] <= 16'h2b; 	ram[242] <= 16'h04; 	ram[243] <= 16'h7e;
	ram[244] <= 16'hba; 	ram[245] <= 16'h77; 	ram[246] <= 16'hd6; 	ram[247] <= 16'h26;
	ram[248] <= 16'he1; 	ram[249] <= 16'h69; 	ram[250] <= 16'h14; 	ram[251] <= 16'h63;
	ram[252] <= 16'h55; 	ram[253] <= 16'h21; 	ram[254] <= 16'h0c; 	ram[255] <= 16'h7d;
*/
//S-box
	ram[0] <= 16'h63; 	ram[1] <= 16'h7c; 	ram[2] <= 16'h77; 	ram[3] <= 16'h7b;
	ram[4] <= 16'hf2; 	ram[5] <= 16'h6b; 	ram[6] <= 16'h6f; 	ram[7] <= 16'hc5;
	ram[8] <= 16'h30; 	ram[9] <= 16'h01; 	ram[10] <= 16'h67; 	ram[11] <= 16'h2b;
	ram[12] <= 16'hfe; 	ram[13] <= 16'hd7; 	ram[14] <= 16'hab; 	ram[15] <= 16'h76;

	ram[16] <= 16'hca; 	ram[17] <= 16'h82; 	ram[18] <= 16'hc9; 	ram[19] <= 16'h7d;
	ram[20] <= 16'hfa; 	ram[21] <= 16'h59; 	ram[22] <= 16'h47; 	ram[23] <= 16'hf0;
	ram[24] <= 16'had; 	ram[25] <= 16'hd4; 	ram[26] <= 16'ha2; 	ram[27] <= 16'haf;
	ram[28] <= 16'h9c; 	ram[29] <= 16'ha4; 	ram[30] <= 16'h72; 	ram[31] <= 16'hc0;

	ram[32] <= 16'hb7; 	ram[33] <= 16'hfd; 	ram[34] <= 16'h93; 	ram[35] <= 16'h26;
	ram[36] <= 16'h36; 	ram[37] <= 16'h3f; 	ram[38] <= 16'hf7; 	ram[39] <= 16'hcc;
	ram[40] <= 16'h34; 	ram[41] <= 16'ha5;	ram[42] <= 16'he5;	ram[43] <= 16'hf1;
	ram[44] <= 16'h71; 	ram[45] <= 16'hd8; 	ram[46] <= 16'h31; 	ram[47] <= 16'h15;

	ram[48] <= 16'h04; 	ram[49] <= 16'hc7; 	ram[50] <= 16'h23; 	ram[51] <= 16'hc3;
	ram[52] <= 16'h18; 	ram[53] <= 16'h96; 	ram[54] <= 16'h05; 	ram[55] <= 16'h9a;
	ram[56] <= 16'h07; 	ram[57] <= 16'h12; 	ram[58] <= 16'h80; 	ram[59] <= 16'he2;
	ram[60] <= 16'heb; 	ram[61] <= 16'h27; 	ram[62] <= 16'hb2; 	ram[63] <= 16'h75;

	ram[64] <= 16'h09; 	ram[65] <= 16'h83; 	ram[66] <= 16'h2c; 	ram[67] <= 16'h1a;
	ram[68] <= 16'h1b; 	ram[69] <= 16'h6e; 	ram[70] <= 16'h5a; 	ram[71] <= 16'ha0;
	ram[72] <= 16'h52; 	ram[73] <= 16'h3b; 	ram[74] <= 16'hd6; 	ram[75] <= 16'hb3;
	ram[76] <= 16'h29; 	ram[77] <= 16'he3; 	ram[78] <= 16'h2f; 	ram[79] <= 16'h84;

	ram[80] <= 16'h53; 	ram[81] <= 16'hd1; 	ram[82] <= 16'h00; 	ram[83] <= 16'hed;
	ram[84] <= 16'h20; 	ram[85] <= 16'hfc; 	ram[86] <= 16'hb1; 	ram[87] <= 16'h5b;
	ram[88] <= 16'h6a; 	ram[89] <= 16'hcb; 	ram[90] <= 16'hbe; 	ram[91] <= 16'h39;
	ram[92] <= 16'h4a; 	ram[93] <= 16'h4c; 	ram[94] <= 16'h58; 	ram[95] <= 16'hcf;

	ram[96] <= 16'hd0; 	ram[97] <= 16'hef; 	ram[98] <= 16'haa; 	ram[99] <= 16'hfb;
	ram[100] <= 16'h43; 	ram[101] <= 16'h4d; 	ram[102] <= 16'h33; 	ram[103] <= 16'h85;
	ram[104] <= 16'h45; 	ram[105] <= 16'hf9; 	ram[106] <= 16'h02; 	ram[107] <= 16'h7f;
	ram[108] <= 16'h50; 	ram[109] <= 16'h3c; 	ram[110] <= 16'h9f; 	ram[111] <= 16'ha8;

	ram[112] <= 16'h51; 	ram[113] <= 16'ha3; 	ram[114] <= 16'h40; 	ram[115] <= 16'h8f;
	ram[116] <= 16'h92; 	ram[117] <= 16'h9d; 	ram[118] <= 16'h38; 	ram[119] <= 16'hf5;
	ram[120] <= 16'hbc; 	ram[121] <= 16'hb6; 	ram[122] <= 16'hda; 	ram[123] <= 16'h21;
	ram[124] <= 16'h10; 	ram[125] <= 16'hff; 	ram[126] <= 16'hf3; 	ram[127] <= 16'hd2;

	ram[128] <= 16'hcd; 	ram[129] <= 16'h0c; 	ram[130] <= 16'h13; 	ram[131] <= 16'hec;
	ram[132] <= 16'h5f; 	ram[133] <= 16'h97; 	ram[134] <= 16'h44; 	ram[135] <= 16'h17;
	ram[136] <= 16'hc4; 	ram[137] <= 16'ha7; 	ram[138] <= 16'h7e; 	ram[139] <= 16'h3d;
	ram[140] <= 16'h64; 	ram[141] <= 16'h5d; 	ram[142] <= 16'h19; 	ram[143] <= 16'h73;

	ram[144] <= 16'h60; 	ram[145] <= 16'h81; 	ram[146] <= 16'h4f; 	ram[147] <= 16'hdc;
	ram[148] <= 16'h22; 	ram[149] <= 16'h2a; 	ram[150] <= 16'h90; 	ram[151] <= 16'h88;
	ram[152] <= 16'h46; 	ram[153] <= 16'hee; 	ram[154] <= 16'hb8; 	ram[155] <= 16'h14;
	ram[156] <= 16'hde; 	ram[157] <= 16'h5e; 	ram[158] <= 16'h0b; 	ram[159] <= 16'hdb;

	ram[160] <= 16'he0; 	ram[161] <= 16'h32; 	ram[162] <= 16'h3a; 	ram[163] <= 16'h0a;
	ram[164] <= 16'h49; 	ram[165] <= 16'h06; 	ram[166] <= 16'h24; 	ram[167] <= 16'h5c;
	ram[168] <= 16'hc2; 	ram[169] <= 16'hd3; 	ram[170] <= 16'hac; 	ram[171] <= 16'h62;
	ram[172] <= 16'h91; 	ram[173] <= 16'h95; 	ram[174] <= 16'he4; 	ram[175] <= 16'h79;

	ram[176] <= 16'he7; 	ram[177] <= 16'hc8; 	ram[178] <= 16'h37; 	ram[179] <= 16'h6d;
	ram[180] <= 16'h8d; 	ram[181] <= 16'hd5; 	ram[182] <= 16'h4e; 	ram[183] <= 16'ha9;
	ram[184] <= 16'h6c; 	ram[185] <= 16'h56; 	ram[186] <= 16'hf4; 	ram[187] <= 16'hea;
	ram[188] <= 16'h65; 	ram[189] <= 16'h7a; 	ram[190] <= 16'hae; 	ram[191] <= 16'h08;

	ram[192] <= 16'hba; 	ram[193] <= 16'h78; 	ram[194] <= 16'h25; 	ram[195] <= 16'h2e;
	ram[196] <= 16'h1c; 	ram[197] <= 16'ha6; 	ram[198] <= 16'hb4; 	ram[199] <= 16'hc6;
	ram[200] <= 16'he8; 	ram[201] <= 16'hdd; 	ram[202] <= 16'h74; 	ram[203] <= 16'h1f;
	ram[204] <= 16'h4b; 	ram[205] <= 16'hbd; 	ram[206] <= 16'h8b; 	ram[207] <= 16'h8a;

	ram[208] <= 16'h70; 	ram[209] <= 16'h3e; 	ram[210] <= 16'hb5; 	ram[211] <= 16'h66;
	ram[212] <= 16'h48; 	ram[213] <= 16'h03; 	ram[214] <= 16'hf6;	ram[215] <= 16'h0e;
	ram[216] <= 16'h61; 	ram[217] <= 16'h35; 	ram[218] <= 16'h57;	ram[219] <= 16'hb9;
	ram[220] <= 16'h86; 	ram[221] <= 16'hc1; 	ram[222] <= 16'h1d; 	ram[223] <= 16'h9e;

	ram[224] <= 16'he1; 	ram[225] <= 16'hf8; 	ram[226] <= 16'h98; 	ram[227] <= 16'h11;
	ram[228] <= 16'h69; 	ram[229] <= 16'hd9; 	ram[230] <= 16'h8e; 	ram[231] <= 16'h94;
	ram[232] <= 16'h9b; 	ram[233] <= 16'h1e; 	ram[234] <= 16'h87; 	ram[235] <= 16'he9;
	ram[236] <= 16'hce; 	ram[237] <= 16'h55; 	ram[238] <= 16'h28; 	ram[239] <= 16'hdf;

	ram[240] <= 16'h8c; 	ram[241] <= 16'ha1; 	ram[242] <= 16'h89; 	ram[243] <= 16'h0d;
	ram[244] <= 16'hbf; 	ram[245] <= 16'he6; 	ram[246] <= 16'h42; 	ram[247] <= 16'h68;
	ram[248] <= 16'h41; 	ram[249] <= 16'h99; 	ram[250] <= 16'h2d; 	ram[251] <= 16'h0f;
	ram[252] <= 16'hb0; 	ram[253] <= 16'h54; 	ram[254] <= 16'hbb; 	ram[255] <= 16'h16;
end

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//port A
always @(posedge clka)
begin
	if (kill)
		doa <= 8'b0;
	else 
		begin
			if (wea)
				ram[addra] <= dia;
			doa <= ram[addra];
		end
end

//port B
always @(posedge clkb)
begin
	if (kill)
		dob <= 8'b0;
	else
		begin
			if (web)
				ram[addrb] <= dib;
			dob <= ram[addrb];
		end
end
/**************************************************************************************************/

endmodule





