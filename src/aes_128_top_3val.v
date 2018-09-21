/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_top_3val.v                                                             *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block AES - 128 bit input, s-box 4 BRAM, 3 cycle round                                        *
 *                                                                                                *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_top_3val (
	/* inputs */
	input			clk,
	input			kill,
	input		[127:0]	in_data,
	input			in_en,
	input			en_wr,
	input		[127:0]	key_round_wr,
	
	/* outputs */
	output		[127:0]	out_data,
	output			out_en,
	output			in_en_collision_irq_pulse
	);

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
wire		[127:0]	key_round;
wire			key_ready;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
/*
//Start only with keyram_3val
aes_128_core_full_3val aes_128_core_full_3val (	.clk(clk),
						.kill(kill),
						.in_data(in_data),
						.in_en(in_en),
						.key_round(key_round),
						.key_ready(key_ready),
						.out_data(out_data),
						.out_en(out_en),
						.in_en_collision_irq_pulse(in_en_collision_irq_pulse));
*/

aes_128_core_full_4cyc_3val aes_128_core_full_4cyc_3val (	.clk(clk),
								.kill(kill),
								.in_data(in_data),
								.in_en(in_en),
								.key_round(key_round),
								.key_ready(key_ready),
								.out_data(out_data),
								.out_en(out_en),
								.in_en_collision_irq_pulse(in_en_collision_irq_pulse));

/**************************************************************************************************/
/*
//Start only with core_full_3val
aes_128_keyram_3val aes_128_keyram_3val (	.clk(clk),
						.kill(kill),
						.en_wr(en_wr),
						.key_round_wr(key_round_wr),
						.key_ready(key_ready),
						.key_round_rd(key_round));
*/
aes_128_keyram aes_128_keyram (			.clk(clk),
						.kill(kill),
						.en_wr(en_wr),
						.key_round_wr(key_round_wr),
						.key_ready(key_ready),
						.key_round_rd(key_round));	
			
/**************************************************************************************************/
endmodule
