/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_control_3val.v                                                         *
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

module aes_128_control_3val (
	/* inputs */
	input			clk,
	input			kill,
	input			in_en,

	/* outputs */
	output	reg		en_mixcol = 1'b0,
	output			key_ready,
	output			idle,
	output	reg		out_en = 1'b0
	);

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg		in_en_r = 1'b0;
reg		in_en_tr = 1'b0;
reg		key_ready_r = 1'b0;
reg	[1:0]	count_in_en;
reg	[4:0]	round_count;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//round_count
always @(posedge clk)
	if (kill)
		round_count <= 5'b0;
	else if (in_en)
		round_count <= 5'b0;
	else if (in_en_r | out_en)
		round_count <= round_count + 5'b1;

/**************************************************************************************************/
//en_mixcol
always @(posedge clk)
	if (kill)
		en_mixcol <= 1'b0;
	else if (in_en)
		en_mixcol <= 1'b0;
	else if (round_count == 5'd25)
		en_mixcol <= 1'b1;
	//else 
		//en_mixcol <= 1'b0;

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

assign key_ready = in_en_tr | key_ready_r;

/**************************************************************************************************/
//count_in_en
always @(posedge clk)
	if (kill)
		count_in_en <= 2'b0;
	else if (in_en_tr)
		count_in_en <= 2'b0;
	else if (in_en)
		count_in_en <= count_in_en + 2'b1;

/**************************************************************************************************/
//in_en_tr
always @(posedge clk)
	if (kill)
		in_en_tr <= 1'b0;
	else if (count_in_en == 2'b1)
		in_en_tr <= 1'b1;
	else 
		in_en_tr <= 1'b0;

/**************************************************************************************************/
//out_en
always @(posedge clk)
	if (kill)
		out_en <= 1'b0;
	else if ((round_count == 5'd27) | (round_count == 5'd28) | (round_count == 5'd29))
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
//idle
assign idle = in_en_r | out_en;

/**************************************************************************************************/
endmodule