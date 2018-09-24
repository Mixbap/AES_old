/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_keyram_2key_switch.v                                                   *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block KeyRam 2 key_set- 64 bit input write                                                    *
 *                                                                                                *
 **************************************************************************************************
 *    Synthesis in Vivado:                                                                        *
 *   			LUT:	33								  *
 *			FF:	88								  *
 *			BRAM:	1								  *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_keyram_2key_switch (
	/* inputs */
	input			clk,
	input			kill,
	input			en_wr,
	input		[63:0]	key_round_wr,
	input			key_ready,
	input			switch_key,
	
	/* outputs */
	output		[127:0]	key_round_rd,
	output			key_idx
	);

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
wire		[63:0]	ram_out;
wire		[5:0]	addr_wr;
wire		[5:0]	addr_rd;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
aes_128_keyram_mem_2key aes_128_keyram_mem_2key(	.clk(clk),
							.kill(kill),
							.en_wr(en_wr),
							.addr_wr(addr_wr),
							.addr_rd(addr_rd),
							.key_round_wr(key_round_wr),
							.ram_out(ram_out));

/**************************************************************************************************/					
aes_128_keyram_control_2key_switch aes_128_keyram_control_2key_swith(	.clk(clk),
									.kill(kill),
									.en_wr(en_wr),
									.key_ready(key_ready),
									.ram_out(ram_out),
									.switch_key(switch_key),
									.key_round_rd(key_round_rd),
									.addr_wr(addr_wr),
									.addr_rd(addr_rd),
									.key_idx(key_idx));

/**************************************************************************************************/
endmodule







