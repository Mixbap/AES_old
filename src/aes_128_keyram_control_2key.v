/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_keyram_control_2key.v                                                  *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block KeyRam 2 key set- 64 bit input write                                                    *
 *                                                                                                *
 **************************************************************************************************
 *    Synthesis in Vivado:                                                                        *
 *   			LUT:	35								  *
 *			FF:	88								  *
 *			BRAM:	0								  *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_keyram_control_2key (
	/* inputs */
	input			clk,
	input			kill,
	input			en_wr,
	input			key_ready,
	input		[63:0]	ram_out,
	
	/* outputs */
	output		[127:0]	key_round_rd,
	output	reg	[5:0]	addr_wr = 6'd22,
	output	reg	[5:0]	addr_rd = 6'b0,
	output	reg		wr_idle = 1'b0
	);

/**************************************************************************************************
*        PARAMETERS
 **************************************************************************************************/
parameter LENGTH_RAM = 64;
parameter LENGTH_KEY_SET = 22;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg			key_ready_r = 1'b0;
reg	[63:0]		key_round_buf;
reg			flag_addr = 1'b0;
reg			wr_idx = 1'b1;
reg			wr_last = 1'b0;
reg	[5:0]		key_ready_count = 6'b0;
reg			read_status = 1'b0;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//key_round_buf - buffer for a half of a key
always @(posedge clk)
	if (kill)
		key_round_buf <= 64'b0;
	else if (flag_addr)
		key_round_buf <= ram_out;

/**************************************************************************************************/
//key_round_rd
assign key_round_rd[63:0] = (~flag_addr) ? key_round_buf : key_round_rd[63:0];
assign key_round_rd[127:64] =  ram_out; 

/**************************************************************************************************/
//flag_addr- flag of switching of the buffer
always @(posedge clk)
	if (kill)
		flag_addr <= 1'b0;
	else if (key_ready | key_ready_r | (addr_rd < 6'b1))
		flag_addr <= 1'b1;
	else 
		flag_addr <= 1'b0;

/**************************************************************************************************/
//addr_rd
always @(posedge clk)
	if (kill)
		addr_rd <= 6'b0;
	else if ((addr_rd == (2 * LENGTH_KEY_SET)-1) & key_ready & (~wr_idx)) 	//addr_rd = (22-44); wr_idx = 0
		addr_rd <= LENGTH_KEY_SET;
	else if ((addr_rd == LENGTH_KEY_SET-1) & key_ready & wr_idx) 		//addr_rd = (0-22); wr_idx = 1 
		addr_rd <= 6'b0;
	else if ((addr_rd == LENGTH_KEY_SET-1) & key_ready & (~wr_idx)) 	//addr_rd = (0-22); wr_idx = 0 
		addr_rd <= LENGTH_KEY_SET;
	else if ((addr_rd == (2 * LENGTH_KEY_SET)-1) & key_ready & wr_idx) 	//addr_rd = (22-44); wr_idx = 1
		addr_rd <= 6'b0;
	else if (key_ready | key_ready_r | (addr_rd == 6'b0) | (addr_rd == LENGTH_KEY_SET))
		addr_rd <= addr_rd + 6'b1;

/**************************************************************************************************/
//wr_idx - number ram buffer write
always @(posedge clk)
	if (kill)
		wr_idx <= 1'b1;
	else if ((addr_wr == LENGTH_KEY_SET-1) | (addr_wr == (2 * LENGTH_KEY_SET)-1))
		wr_idx <= ~wr_idx;

/**************************************************************************************************/
//wr_last
always @(posedge clk)
	if (kill)
		wr_last <= 1'b0;
	else if ((addr_wr == LENGTH_KEY_SET-2) | (addr_wr == (2 * LENGTH_KEY_SET)-2))
		wr_last <= 1'b1;
	else
		wr_last <= 1'b0;

/**************************************************************************************************/
//addr_wr	
always @(posedge clk)
	if (kill)
		addr_wr <= LENGTH_KEY_SET;
	else if (addr_wr == (2 * LENGTH_KEY_SET)-1)
		addr_wr <= 6'b0;
	else if (en_wr)
		addr_wr <= addr_wr + 6'b1;

/**************************************************************************************************/
//key_ready_r
always @(posedge clk)
	if (kill)
		key_ready_r <= 1'b0;
	else if (key_ready)
		key_ready_r <= 1'b1;
	else
		key_ready_r <= 1'b0;

/**************************************************************************************************/
//key_ready_count
always @(posedge clk)
	if (kill)
		key_ready_count <= 6'b0;
	else if (key_ready_count == LENGTH_KEY_SET/2)
		key_ready_count <= 6'b0;
	else if (key_ready)
		key_ready_count <= key_ready_count + 6'b1;

/**************************************************************************************************/
//read_status - high level transmit key_set; low level no transmit
always @(posedge clk)
	if (kill)
		read_status <= 1'b0;
	else if (key_ready_count == 6'b0)
		read_status <= 1'b0;
	else
		read_status <= 1'b1;

/**************************************************************************************************/
//wr_idle - high level no write key
always @(posedge clk)
	if (kill)
		wr_idle <= 1'b0;
	else if (wr_last & read_status)
		wr_idle <= 1'b1;
	else if (~wr_last & ~read_status)
		wr_idle <= 1'b0;

/**************************************************************************************************/
endmodule






