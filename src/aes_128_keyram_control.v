/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_key_ram_control.v                                                      *
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

module aes_128_keyram_control (
	/* inputs */
	input			clk,
	input			kill,
	input			en_wr,
	input			key_ready,
	input		[63:0]	ram_out,
	
	/* outputs */
	output		[127:0]	key_round_rd,
	output		[4:0]	addr
	);

/**************************************************************************************************
*        PARAMETERS
 **************************************************************************************************/
parameter LENGTH_RAM = 32;
parameter LENGTH_KEY_SET = 22;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[4:0]		addr_rd;
reg	[4:0]		addr_wr;
reg			key_ready_r = 1'b0;
reg	[63:0]		key_round_buf;
reg			flag_addr = 1'b0;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//key_round_buf
always @(posedge clk)
	if (kill)
		key_round_buf <= 64'b0;
	else if (flag_addr)
		key_round_buf <= ram_out;

/**************************************************************************************************/
//addr
assign addr = (en_wr) ? addr_wr : addr_rd;

/**************************************************************************************************/
//key_round_rd
assign key_round_rd[63:0] = (~flag_addr) ? key_round_buf : key_round_rd[63:0];
assign key_round_rd[127:64] =  ram_out; 

/**************************************************************************************************/
//flag_addr
always @(posedge clk)
	if (kill)
		flag_addr <= 1'b0;
	else if (key_ready | key_ready_r | (addr_rd < 5'b1))
		flag_addr <= 1'b1;
	else 
		flag_addr <= 1'b0;

/**************************************************************************************************/
//addr_rd
always @(posedge clk)
	if (kill)
		addr_rd <= 5'b0;
	else if (en_wr)
		addr_rd <= 5'b0;
	else if ((addr_rd == LENGTH_KEY_SET-1) & key_ready)
		addr_rd <= 5'b0;
	else if (key_ready | key_ready_r | (addr_rd < 5'b1))
		addr_rd <= addr_rd + 5'b1;

/**************************************************************************************************/
//addr_wr	
always @(posedge clk)
	if (kill)
		addr_wr <= 5'b0;
	else if (key_ready)
		addr_wr <= 5'b0;
	else if (en_wr)
		addr_wr <= addr_wr + 5'b1;

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
endmodule
