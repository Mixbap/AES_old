/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_keyram_3val_tb.v                                                       *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Testbench block AES - 128 bit input, s-box 4 BRAM, 3 cycle round                              *
 *                                                                                                *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

`timescale 1ns / 1ps

module aes_128_keyram_3val_tb;

 /*************************************************************************************
 *            PARAMETERS                                                             *
 *************************************************************************************/
parameter clk_dly = 20;
parameter rst_dly = 50;

/*************************************************************************************
 *            INTERNAL WIRES & REGS                                                  *
 *************************************************************************************/
//inputs
reg		clk;
reg		kill;
reg		en_wr;
reg	[127:0]	key_round_wr;
reg	[3:0]	addr_wr;
reg		key_ready;

//outputs
wire	[127:0]	key_round_rd;

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
aes_128_keyram_3val aes_128_keyram_3val (	.clk(clk),
						.kill(kill),
						.key_ready(key_ready),
						.en_wr(en_wr),
						.key_round_wr(key_round_wr),
						.addr_wr(addr_wr),
						.key_round_rd(key_round_rd));

/*************************************************************************************
 *            INITIAL                                                                *
 *************************************************************************************/
//initialization clock signals
initial
begin
	clk = 1'b0;
	kill = 1'b0;
end

always
#clk_dly clk = ~clk;

//initial full
initial
begin
	aes_128_keyram_rst;
	aes_128_keyram_ini;
	wait_n_clocks(3);
	aes_128_keyram_set_ready(11);
	wait_n_clocks(5);
	aes_128_keyram_write_key;
	wait_n_clocks(5);
	aes_128_keyram_set_ready(11);
	wait_n_clocks(5);
	$stop;
end

/*************************************************************************************
 *            TASKS                                                                  *
 *************************************************************************************/
//reset signal
task aes_128_keyram_rst;
begin
	kill <= 1'b1;
	#rst_dly kill <= 1'b0;
end
endtask

/**************************************************************************************************/
//initialization all signal
task aes_128_keyram_ini;
begin
	en_wr = 1'b0;
	addr_wr = 4'b0;
	key_round_wr = 128'b0;
	key_ready = 1'b0;
end
endtask

/**************************************************************************************************/
// wait N clocks

task wait_n_clocks;
input integer N;
integer n; 
begin
	@(posedge clk);
	for (n = 0; n < N; n = n + 1)
		@(posedge clk);
end
endtask

/**************************************************************************************************/
//set ready
task aes_128_keyram_set_ready;
input integer N;
integer n;
begin
	for (n = 0; n < N; n = n + 1)
	begin
		@(posedge clk);
		key_ready <= 1'b1;
		@(posedge clk);
		key_ready <= 1'b0;
		@(posedge clk);
		@(posedge clk);
	end
end
endtask

/**************************************************************************************************/
//write key
task aes_128_keyram_write_key;
begin
	@(posedge clk);
	en_wr <= 1'b1;
	addr_wr <= 4'd2;
	key_round_wr <= 128'hff;
	@(posedge clk);
	en_wr <= 1'b0;
	addr_wr <= 5'b0;
	key_round_wr <= 128'h0;

end
endtask

/**************************************************************************************************/
endmodule
