/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_top.v                                                             *
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

module aes_128_top (
	clk,
	kill,
	in_data,
	in_en,
	key_round,

	key_ready,
	out_data,
	out_en
	);

/**************************************************************************************************
*        I/O PORTS
 **************************************************************************************************/
input			clk;
input			kill;
input	[127:0]		in_data;
input			in_en;
input	[127:0]		key_round;

output			key_ready;
output	[127:0]		out_data;
output	reg		out_en;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg			en_mixcol;
reg			rounds_end;
reg	[4:0]		round_count;
reg			in_en_r;
reg			key_ready_r;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//aes_128_core
aes_128_core aes_128_core (	.clk(clk),
				.kill(kill),
				.en_mixcol(en_mixcol),
				.start(in_en),
				.rounds_end(rounds_end),
				.in_data(in_data),
				.key_round(key_round),
				.out_data(out_data));

/**************************************************************************************************/
//round_count
always @(posedge clk)
	if (kill)
		round_count <= 5'b0;
	else if (in_en)
		round_count <= 5'b0;
	else
		round_count <= round_count + 5'b1;

/**************************************************************************************************/
//en_mixcol
always @(posedge clk)
	if (kill)
		en_mixcol <= 1'b0;
	else if (in_en)
		en_mixcol <= 1'b0;
	else if (round_count == 5'd27)
		en_mixcol <= 1'b1;
	else 
		en_mixcol <= 1'b0;
		
/**************************************************************************************************/
//rounds_end
always @(posedge clk)
	if (kill)
		rounds_end <= 1'b0;
	else if (in_en)
		rounds_end <= 1'b0;
	else if (round_count == 5'd29)
		rounds_end <= 1'b1;
	else
		rounds_end <= 1'b0;

/**************************************************************************************************/
//key_ready_r
always @(posedge clk)
	if (kill)
		key_ready_r <= 1'b0;
	else if ((round_count == 5'd1 | 		round_count == 5'd4 | 		round_count == 5'd7 | 		round_count == 5'd10 |
	    	  round_count == 5'd13 | 		round_count == 5'd16 | 		round_count == 5'd19 | 		round_count == 5'd22 |
	    	  round_count == 5'd25 | 		round_count == 5'd28) & in_en_r)
		key_ready_r <= 1'b1;
	else
		key_ready_r <= 1'b0;

assign key_ready = in_en | key_ready_r;

/**************************************************************************************************/
//out_en
always @(posedge clk)
	if (kill)
		out_en <= 1'b0;
	else if (round_count == 5'd29)
		out_en <= 1'b1;
	else
		out_en <= 1'b0;

/**************************************************************************************************/
//in_en_r
always @(posedge clk)
	if (kill)
		in_en_r <= 1'b0;
	else if (in_en)
		in_en_r <= 1'b1;
	else if (out_en)
		in_en_r <= 1'b0;

/**************************************************************************************************/
endmodule







