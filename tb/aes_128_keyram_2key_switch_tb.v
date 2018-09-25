
/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_keyram_2key_switch_tb.v                                                *
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

module aes_128_keyram_2key_switch_tb;

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
reg	[63:0]	key_round_wr;
reg		key_ready;
reg		switch_key;

//outputs
wire	[127:0]	key_round_rd;
wire		key_idx;

//Key_round
reg	[127:0]		key_round_new[43:0];

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
aes_128_keyram_2key_switch aes_128_keyram_2key_switch (	.clk(clk),
							.kill(kill),
							.en_wr(en_wr),
							.key_round_wr(key_round_wr),
							.key_ready(key_ready),
							.switch_key(switch_key),
							.key_round_rd(key_round_rd),
							.key_idx(key_idx));

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
	aes_128_keyram_write(0,22,0);
	wait_n_clocks(5);

	aes_128_set_switch_key(3);
	wait_n_clocks(3);
	fork
		aes_128_keyram_set_ready(11);
		aes_128_keyram_write(1,22,2);
	join
	wait_n_clocks(20);


	fork
		aes_128_keyram_set_ready(11);
		aes_128_set_switch_key(5);
		aes_128_keyram_write(0,22,4);
	join
	wait_n_clocks(20);
	aes_128_keyram_set_ready(11);
	wait_n_clocks(20);

	aes_128_set_switch_key(3);
	wait_n_clocks(1);
	aes_128_keyram_set_ready(11);
	wait_n_clocks(50);

	

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
	key_round_wr = 64'b0;
	key_ready = 1'b0;
	switch_key = 1'b0;

	key_round_new[0] <= 64'h0;
	key_round_new[1] <= 64'h1;
	key_round_new[2] <= 64'h2;
	key_round_new[3] <= 64'h3;
	key_round_new[4] <= 64'h4;
	key_round_new[5] <= 64'h5;
	key_round_new[6] <= 64'h6;
	key_round_new[7] <= 64'h7;
	key_round_new[8] <= 64'h8;
	key_round_new[9] <= 64'h9;
	key_round_new[10] <= 64'ha;
	key_round_new[11] <= 64'hb;
	key_round_new[12] <= 64'hc;
	key_round_new[13] <= 64'hd;
	key_round_new[14] <= 64'he;
	key_round_new[15] <= 64'hf;
	key_round_new[16] <= 64'h10;
	key_round_new[17] <= 64'h11;
	key_round_new[18] <= 64'h12;
	key_round_new[19] <= 64'h13;
	key_round_new[20] <= 64'h14;
	key_round_new[21] <= 64'h15;

	key_round_new[22] <= 64'h0706050403020100;
	key_round_new[23] <= 64'h0f0e0d0c0b0a0908;
	key_round_new[24] <= 64'hfa72afd2fd74aad6;	
	key_round_new[25] <= 64'hfe76abd6f178a6da;
	key_round_new[26] <= 64'hf1bd3d640bcf92b6;
	key_round_new[27] <= 64'hfeb3306800c59bbe;	
	key_round_new[28] <= 64'hbfc9c2d24e74ffb6;
	key_round_new[29] <= 64'h41bf6904bf0c596c;
	key_round_new[30] <= 64'h033e3595bcf7f747;
	key_round_new[31] <= 64'hfd8d05fdbc326cf9;
	key_round_new[32] <= 64'heb9d9fa9e8a3aa3c;
	key_round_new[33] <= 64'haa22f6ad57aff350;
	key_round_new[34] <= 64'h9692a6f77d0f395e;
	key_round_new[35] <= 64'h6b1fa30ac13d55a7;
	key_round_new[36] <= 64'h8ce25fe31a70f914;
	key_round_new[37] <= 64'h26c0a94e4ddf0a44;
	key_round_new[38] <= 64'hb9651ca435874347;
	key_round_new[39] <= 64'hd27abfaef4ba16e0;
	key_round_new[40] <= 64'h685785f0d1329954;
	key_round_new[41] <= 64'h4e972cbe9ced9310;
	key_round_new[42] <= 64'h174a94e37f1d1113;
	key_round_new[43] <= 64'hc5302b4d8ba707f3;
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
//set switch key
task aes_128_set_switch_key;
input integer DEL;
integer n;
begin
	//delay
	for (n = 0; n < DEL; n = n + 1)
		@(posedge clk);
	
	@(posedge clk);
	switch_key <= 1'b1;
	@(posedge clk);
	switch_key <= 1'b0;
	
end
endtask

/**************************************************************************************************/
//write key
task aes_128_keyram_write;
input integer num_buff;
input integer N;
input integer DEL;
integer i;
integer n;
begin
	//delay
	for (n = 0; n < DEL; n = n + 1)
		@(posedge clk);

	//write
	for (i = 0; i < N; i = i + 1)
	begin
		@(posedge clk);
		en_wr <= 1'b1;
		key_round_wr <= key_round_new[i + num_buff*22];
	end
	@(posedge clk);
	en_wr <= 1'b0;
	key_round_wr <= 128'b0;
end
endtask
/**************************************************************************************************/
endmodule