/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_keyram_mem_2key.v                                                      *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block KeyRam 2 key_set - 64 bit input write                                                   *
 *                                                                                                *
 **************************************************************************************************
 *    Synthesis in Vivado:                                                                        *
 *   			LUT:	1								  *
 *			FF:	0								  *
 *			BRAM:	1								  *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_keyram_mem_2key (
	/* inputs */
	input			clk,
	input			kill,
	input			en_wr,
	input		[5:0]	addr_wr,
	input		[5:0]	addr_rd,
	input		[63:0]	key_round_wr,

	/* outputs */
	output	reg	[63:0]	ram_out
	);

/**************************************************************************************************
*        PARAMETERS
 **************************************************************************************************/
parameter LENGTH_RAM = 64;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[63:0]		ram [LENGTH_RAM-1:0];

/**************************************************************************************************
 *            INITIAL                                                                             *
 **************************************************************************************************/
initial
begin
	//ram buffer 0
	ram[0] <= 64'h0706050403020100;		ram[1] <= 64'h0f0e0d0c0b0a0908;		ram[2] <= 64'hfa72afd2fd74aad6;		ram[3] <= 64'hfe76abd6f178a6da;
	ram[4] <= 64'hf1bd3d640bcf92b6;		ram[5] <= 64'hfeb3306800c59bbe;		ram[6] <= 64'hbfc9c2d24e74ffb6;		ram[7] <= 64'h41bf6904bf0c596c;
	ram[8] <= 64'h033e3595bcf7f747;		ram[9] <= 64'hfd8d05fdbc326cf9;		ram[10] <= 64'heb9d9fa9e8a3aa3c;	ram[11] <= 64'haa22f6ad57aff350;
	ram[12] <= 64'h9692a6f77d0f395e;	ram[13] <= 64'h6b1fa30ac13d55a7;	ram[14] <= 64'h8ce25fe31a70f914;	ram[15] <= 64'h26c0a94e4ddf0a44;
	ram[16] <= 64'hb9651ca435874347;	ram[17] <= 64'hd27abfaef4ba16e0;	ram[18] <= 64'h685785f0d1329954;	ram[19] <= 64'h4e972cbe9ced9310;
	ram[20] <= 64'h174a94e37f1d1113;	ram[21] <= 64'hc5302b4d8ba707f3;		

	//ram buffer 1
	ram[22] <= 64'h0706050403020100;	ram[23] <= 64'h0f0e0d0c0b0a0908;	ram[24] <= 64'hfa72afd2fd74aad6;	ram[25] <= 64'hfe76abd6f178a6da;
	ram[26] <= 64'hf1bd3d640bcf92b6;	ram[27] <= 64'hfeb3306800c59bbe;	ram[28] <= 64'hbfc9c2d24e74ffb6;	ram[29] <= 64'h41bf6904bf0c596c;
	ram[30] <= 64'h033e3595bcf7f747;	ram[31] <= 64'hfd8d05fdbc326cf9;	ram[32] <= 64'heb9d9fa9e8a3aa3c;	ram[33] <= 64'haa22f6ad57aff350;
	ram[34] <= 64'h9692a6f77d0f395e;	ram[35] <= 64'h6b1fa30ac13d55a7;	ram[36] <= 64'h8ce25fe31a70f914;	ram[37] <= 64'h26c0a94e4ddf0a44;
	ram[38] <= 64'hb9651ca435874347;	ram[39] <= 64'hd27abfaef4ba16e0;	ram[40] <= 64'h685785f0d1329954;	ram[41] <= 64'h4e972cbe9ced9310;
	ram[42] <= 64'h174a94e37f1d1113;	ram[43] <= 64'hc5302b4d8ba707f3;		

end
/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//ram
always @(posedge clk)
begin
	if (kill)
		ram_out <= 64'b0;
	else 
	begin
		if (en_wr)
			ram[addr_wr] <= key_round_wr;
		ram_out <= ram[addr_rd];
	end
end

/**************************************************************************************************/
endmodule

