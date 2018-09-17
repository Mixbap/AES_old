/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_core_full_3val.v                                                       *
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

module aes_128_core_full_3val (
	/* inputs */
	input			clk,
	input			kill,
	input		[127:0]	in_data,
	input			in_en,
	input		[127:0]	key_round,

	/* outputs */
	output			key_ready,
	output		[127:0]	out_data,
	output			out_en,
	output			in_en_collision_irq_pulse
	);

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
wire			en_mixcol;
wire			idle;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//aes_128_core
aes_128_core aes_128_core (			.clk(clk),
						.kill(kill),
						.en_mixcol(en_mixcol),
						.start(in_en),
						.in_data(in_data),
						.key_round(key_round),
						.out_data(out_data));

/**************************************************************************************************/
//aes_128_control
aes_128_control_3val aes_128_control_3val(	.clk(clk),
						.kill(kill),
						.in_en(in_en),
						.en_mixcol(en_mixcol),
						.key_ready(key_ready),
						.idle(idle),
						.out_en(out_en),
						.in_en_collision_irq_pulse(in_en_collision_irq_pulse));


/**************************************************************************************************/
endmodule

