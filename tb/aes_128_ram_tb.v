/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_ram.v                                                                  *
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

module aes_128_ram_tb;


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
reg	[127:0]	input_data;
reg		input_en;
reg	[127:0]	key_round;

//outputs
wire	[127:0]	output_data;
wire		output_en;

//Matlab data vectors

//Matlab files descriptors

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
aes_128_ram aes_128_ram(	.clk(clk),
				.kill(kill),
				.input_data(input_data),
				.input_en(input_en),
				.key_round(key_round),
				.output_data(output_data),
				.output_en(output_en));


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
	aes_rst;
	aes_ini;
	wait_n_clocks(2);
	aes_set_data_en;

end

/*************************************************************************************
 *            TASKS                                                                  *
 *************************************************************************************/
//reset signal
task aes_rst;
begin
	kill <= 1'b1;
	#rst_dly kill <= 1'b0;
end
endtask

/**************************************************************************************************/
//initialization all signal
task aes_ini;
begin
	input_en = 1'b0;
	input_data = 128'b0;
	key_round = 128'hff00ff00ff00ff00ff00ff00ff00ff00;
	
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
//set input enable and data
task aes_set_data_en;
integer i;
begin
	@(posedge clk)
	input_en <= 1'b1;
	input_data <= 127'b1;
	@(posedge clk);
	input_en <= 1'b0;
	input_data <= 127'b0;
	
	$display("Input data was set\n");
end
endtask
/**************************************************************************************************/

endmodule
