/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_control_4cyc.v                                                         *
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

module aes_128_control_4cyc (
	/* inputs */
	input			clk,
	input			kill,
	input			in_en,

	/* outputs */
	output			start,
	output	reg		en_mixcol = 1'b0,
	output			key_ready,
	output	reg		idle = 1'b0,
	output	reg		out_en = 1'b0,
	output	reg		in_en_collision_irq_pulse = 1'b0
	);

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg		start_r = 1'b0;
reg		key_ready_r = 1'b0;
reg	[5:0]	round_count;
reg		in_en_collision_irq = 1'b0;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//start
assign start = (idle) ? 1'b0 : in_en;

/**************************************************************************************************/
//round_count
always @(posedge clk)
	if (kill)
		round_count <= 6'b0;
	else if (start)
		round_count <= 6'b0;
	else if (start_r)
		round_count <= round_count + 6'b1;

/**************************************************************************************************/
//en_mixcol
always @(posedge clk)
	if (kill)
		en_mixcol <= 1'b0;
	else if (start)
		en_mixcol <= 1'b0;
	else if (round_count == 6'd37)
		en_mixcol <= 1'b1;
	else 
		en_mixcol <= 1'b0;

/**************************************************************************************************/
//key_ready_r
always @(posedge clk)
	if (kill)
		key_ready_r <= 1'b0;
	else if ((round_count == 6'd2 | 		round_count == 6'd6 | 		round_count == 6'd10 | 		round_count == 6'd14 |
	    	  round_count == 6'd18 | 		round_count == 6'd22 | 		round_count == 6'd26 | 		round_count == 6'd30 |
	    	  round_count == 6'd34 | 		round_count == 6'd38) & start_r)
		key_ready_r <= 1'b1;
	else
		key_ready_r <= 1'b0;

assign key_ready = start | key_ready_r;

/**************************************************************************************************/
//out_en
always @(posedge clk)
	if (kill)
		out_en <= 1'b0;
	else if (round_count == 6'd40)
		out_en <= 1'b1;
	else
		out_en <= 1'b0;

/**************************************************************************************************/
//start_r
always @(posedge clk)
	if (kill)
		start_r <= 1'b0;
	else if (start)
		start_r <= 1'b1;
	else if (out_en)
		start_r <= 1'b0;

/**************************************************************************************************/
//idle
always @(posedge clk)
	if (kill)
		idle <= 1'b0;
	else if (start)
		idle <= 1'b1;
	else if (out_en)
		idle <= 1'b0;

/**************************************************************************************************/
//in_en_collision_irq
always @(posedge clk)
	if (kill)
		in_en_collision_irq <= 1'b0;
	else if (in_en & idle)
		in_en_collision_irq <= 1'b1;
	else if (in_en)
		in_en_collision_irq <= 1'b0;

/**************************************************************************************************/
//in_en_collision_irq_pulse
always @(posedge clk)
	if (kill)
		in_en_collision_irq_pulse <= 1'b0;
	else if (in_en_collision_irq)
		in_en_collision_irq_pulse <= ~in_en_collision_irq_pulse;
	else 
		in_en_collision_irq_pulse <= 1'b0;

/**************************************************************************************************/
endmodule;
