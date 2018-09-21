/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_core_4cyc.v                                                            *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block AES - 128 bit input, s-box 4 BRAM, 4 cycle round                                        *
 *                                                                                                *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_core_4cyc (
	/* inputs */
	input			clk,
	input			kill,
	input			en_mixcol,
	input			start,
	input		[127:0]	in_data,
	input		[127:0]	key_round,

	/* outputs */
	output		[127:0]	out_data
	);

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
wire	[127:0]		mixcol_out;
wire	[127:0]		subbytes_out;

reg	[127:0]		round_data;
reg	[127:0]		round_data_buf;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//SubBytes and ShiftRows
aes_128_subbytes aes_128_subbytes (	.clk(clk),
					.kill(kill),
					.in_data(round_data_buf),
					.out_data(subbytes_out));

/**************************************************************************************************/
//MixColums
aes_128_mixcol aes_128_mixcol (		.clk(clk),
					.kill(kill),
					.en(en_mixcol),
					.in_data(subbytes_out),
					.out_data(mixcol_out));

/**************************************************************************************************/
//AddRoundKey
always @(posedge clk)
	if (kill)
		round_data <= 128'b0;
	else if (start)
		round_data <= in_data ^ key_round;
	else
		round_data <= mixcol_out ^ key_round;

/**************************************************************************************************/
//Buffer delay round_data
always @(posedge clk)
	if (kill)
		round_data_buf <= 128'b0;
	else 
		round_data_buf <= round_data;

/**************************************************************************************************/
//Output data
assign out_data =  round_data_buf;

/**************************************************************************************************/

endmodule






