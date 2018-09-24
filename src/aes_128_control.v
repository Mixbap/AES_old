/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_control.v                                                              *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block AES control - 128 bit input, 3 cycle round                                              *
 *                                                                                                *
 **************************************************************************************************
 *    Synthesis in Vivado:                                                                        *
 *   			LUT:	10								  *
 *			FF:	11								  *
 *			BRAM:	0								  *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_control (
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
reg	[4:0]	round_count;
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
		round_count <= 5'b0;
	else if (start)
		round_count <= 5'b0;
	else if (start_r)
		round_count <= round_count + 5'b1;

/**************************************************************************************************/
//en_mixcol - signal the disconnecting Mixcolums
always @(posedge clk)
	if (kill)
		en_mixcol <= 1'b0;
	else if (start)
		en_mixcol <= 1'b0;
	else if (round_count == 5'd27)
		en_mixcol <= 1'b1;
	else 
		en_mixcol <= 1'b0;

/**************************************************************************************************/
//key_ready_r
always @(posedge clk)
	if (kill)
		key_ready_r <= 1'b0;
	else if ((round_count == 5'd1 | 		round_count == 5'd4 | 		round_count == 5'd7 | 		round_count == 5'd10 |
	    	  round_count == 5'd13 | 		round_count == 5'd16 | 		round_count == 5'd19 | 		round_count == 5'd22 |
	    	  round_count == 5'd25 | 		round_count == 5'd28) & start_r)
		key_ready_r <= 1'b1;
	else
		key_ready_r <= 1'b0;

assign key_ready = start | key_ready_r;

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
//start_r
always @(posedge clk)
	if (kill)
		start_r <= 1'b0;
	else if (start)
		start_r <= 1'b1;
	else if (out_en)
		start_r <= 1'b0;

/**************************************************************************************************/
//idle - high level  - status AES_CALC, low level  - status AES_IDLE
always @(posedge clk)
	if (kill)
		idle <= 1'b0;
	else if (start)
		idle <= 1'b1;
	else if (out_en)
		idle <= 1'b0;

/**************************************************************************************************/
//in_en_collision_irq - flag double in_en
always @(posedge clk)
	if (kill)
		in_en_collision_irq <= 1'b0;
	else if (in_en & idle)
		in_en_collision_irq <= 1'b1;
	else if (in_en)
		in_en_collision_irq <= 1'b0;

/**************************************************************************************************/
//in_en_collision_irq_pulse - debug signal
always @(posedge clk)
	if (kill)
		in_en_collision_irq_pulse <= 1'b0;
	else if (in_en_collision_irq)
		in_en_collision_irq_pulse <= ~in_en_collision_irq_pulse;
	else 
		in_en_collision_irq_pulse <= 1'b0;

/**************************************************************************************************/
endmodule
