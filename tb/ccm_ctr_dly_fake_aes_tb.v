/**************************************************************************************************
 *                                                                                                *
 *  File Name:     ccm_ctr_dly_fake_aes_tb.v                                                      *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Testbench block CCM - encrypted counter                                                       *
 *                                                                                                *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

`timescale 1ns / 1ps

module ccm_ctr_dly_fake_aes_tb;

 /*************************************************************************************
 *            PARAMETERS                                                             *
 *************************************************************************************/
 parameter clk_dly = 20;
 parameter rst_dly = 50;

 parameter  WIDTH_NONCE = 100;
 parameter  WIDTH_FLAG = 8;
 parameter  WIDTH_COUNT = 20;

localparam  WIDTH_KEY = WIDTH_NONCE + WIDTH_FLAG + WIDTH_COUNT;

/*************************************************************************************
 *            INTERNAL WIRES & REGS                                                  *
 *************************************************************************************/
//inputs
reg				clk;
reg				reset;
reg	[WIDTH_KEY-1:0]		key_aes;
reg	[WIDTH_NONCE-1:0]	ccm_ctr_nonce;
reg	[WIDTH_FLAG-1:0]	ccm_ctr_flag;
reg				input_en_buf;

//outputs
wire	[WIDTH_KEY-1:0]		encrypt_data;
wire				encrypt_en;

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
ccm_ctr_dly_fake_aes ccm_ctr_dly_fake_aes( 	.clk(clk), 
						.reset(reset),  
						.key_aes(key_aes),
						.ccm_ctr_nonce(ccm_ctr_nonce), 
						.ccm_ctr_flag(ccm_ctr_flag),  
						.input_en_buf(input_en_buf),
						.encrypt_data(encrypt_data),
						.encrypt_en(encrypt_en));


/*************************************************************************************
 *            INITIAL                                                                *
 *************************************************************************************/
//initialization clock signals
initial
begin
	clk = 1'b0;
	reset = 1'b0;
end

always
#clk_dly clk = ~clk;


//initial full
initial
begin
	rst;
	init;
	wait_n_clocks(0);
	set_enable;
	wait_n_clocks(8);
	set_enable;
	wait_n_clocks(50);
end

/*************************************************************************************
 *            TASKS                                                                  *
 *************************************************************************************/
//reset signal
task rst;
begin
	reset <= 1'b1;
	#rst_dly reset <= 1'b0;
end
endtask

/**************************************************************************************************/
//initialization all signal
task init;
begin
	input_en_buf = 1'b0;
	key_aes = 128'hff00ff00ff00ff00ff00ff00ff00ff00;
	ccm_ctr_nonce = 1'b0;
	ccm_ctr_flag = 1'b0;
	
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
//set input enable
task set_enable;
begin
	@(posedge clk)
	input_en_buf <= 1'b1;
	@(posedge clk);
	input_en_buf <= 1'b0;
end
endtask

/**************************************************************************************************/

endmodule

