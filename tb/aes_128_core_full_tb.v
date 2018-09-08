/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_core_full_tb.v                                                         *
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

module aes_128_core_full_tb;

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
reg	[127:0]		key_round;

//outputs
wire			key_ready;
wire			out_en;
wire	[127:0]		out_data;

//Key_round
reg	[127:0]		key_round_full[9:0];

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
aes_128_core_full aes_128_core_full (	.clk(clk),
					.kill(kill),
					.in_data(in_data),
					.in_en(in_en),
					.key_round(key_round),
					.key_ready(key_ready),
					.out_data(out_data),
					.out_en(out_en));

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
	fork
		aes_128_set_data;
		aes_128_set_key;
	join
	wait_n_clocks(10);
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
	key_round = 128'h0f0e0d0c0b0a09080706050403020100;

	key_round_full[0] = 128'hfe76abd6f178a6dafa72afd2fd74aad6;
	key_round_full[1] = 128'hfeb3306800c59bbef1bd3d640bcf92b6;
	key_round_full[2] = 128'h41bf6904bf0c596cbfc9c2d24e74ffb6;
	key_round_full[3] = 128'hfd8d05fdbc326cf9033e3595bcf7f747;
	key_round_full[4] = 128'haa22f6ad57aff350eb9d9fa9e8a3aa3c;
	key_round_full[5] = 128'h6b1fa30ac13d55a79692a6f77d0f395e;
	key_round_full[6] = 128'h26c0a94e4ddf0a448ce25fe31a70f914;
	key_round_full[7] = 128'hd27abfaef4ba16e0b9651ca435874347;
	key_round_full[8] = 128'h4e972cbe9ced9310685785f0d1329954;
	key_round_full[9] = 128'hc5302b4d8ba707f3174a94e37f1d1113;
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
end
endtask
/**************************************************************************************************/
//set key_round
task aes_128_set_key;
integer i;
begin
	i = 0;
	while (!out_en)
	begin
		@(posedge clk);
		if (in_en)
			i = 0;
		if (key_ready)
			begin
				key_round <= key_round_full[i];
				i = i + 1;
			end
	end

end
endtask


/**************************************************************************************************/

endmodule



