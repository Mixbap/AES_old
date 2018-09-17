/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_top_tb.v                                                               *
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

module aes_128_top_tb;

 /*************************************************************************************
 *            PARAMETERS                                                             *
 *************************************************************************************/
parameter clk_dly = 20;
parameter rst_dly = 50;

/*************************************************************************************
 *            INTERNAL WIRES & REGS                                                  *
 *************************************************************************************/
//inputs
reg			clk;
reg			kill;
reg	[127:0]		in_data;
reg			in_en;
reg	[63:0]		key_round_wr;
reg			en_wr;

//outputs
/*
wire			out_en;
wire	[127:0]		out_data;

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
aes_128_top aes_128_top (		.clk(clk),
					.kill(kill),
					.in_data(in_data),
					.in_en(in_en),
					.en_wr(en_wr),
					.key_round_wr(key_round_wr),
					.out_data(out_data),
					.out_en(out_en),
					.in_en_collision_irq_pulse(in_en_collision_irq_pulse));

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
	aes_128_rst;
	aes_128_ini;
	wait_n_clocks(4);
	aes_128_set_data;
	wait_n_clocks(45);
	aes_128_set_data;
	wait_n_clocks(45);
	aes_128_write_key;
	wait_n_clocks(4);
	aes_128_set_data;
	wait_n_clocks(50);
	$stop;
end

/*************************************************************************************
 *            TASKS                                                                  *
 *************************************************************************************/
//reset signal
task aes_128_rst;
begin
	kill <= 1'b1;
	#rst_dly kill <= 1'b0;
end
endtask

/**************************************************************************************************/
//initialization all signal
task aes_128_ini;
begin
	in_en = 1'b0;
	in_data = 128'b0;
	en_wr = 1'b0;
	key_round_wr = 128'b0;
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
//set data
task aes_128_set_data;
begin
	@(posedge clk);
	in_en <= 1'b1;
	in_data <= 128'hffeeddccbbaa99887766554433221100;
	@(posedge clk);
	in_en <= 1'b0;
	in_data <= 128'b0;
/*
//double in_en
	@(posedge clk);
	in_en <= 1'b1;
	@(posedge clk);
	in_en <= 1'b0;
*/
end
endtask

/**************************************************************************************************/
//write key
task aes_128_write_key;
begin
	@(posedge clk);
	en_wr <= 1'b1;
	key_round_wr <= 128'hff;
	@(posedge clk);
	en_wr <= 1'b1;
	key_round_wr <= 128'haa;
	@(posedge clk);
	en_wr <= 1'b0;
	key_round_wr <= 128'b0;
end
endtask

/**************************************************************************************************/

endmodule

