/**************************************************************************************************
 *                                                                                                *
 *  File Name:     ccm_ctr_fake_aes_tb.v                                                          *
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

module ccm_ctr_fake_aes_tb;

 /*************************************************************************************
 *            PARAMETERS                                                             *
 *************************************************************************************/
parameter clk_dly = 20;
parameter rst_dly = 50;

parameter LENGTH_READY = 50;
parameter LENGTH_STREAM = 33;

parameter WIDTH_KEY = 128;
parameter WIDTH_FLAG = 8;
parameter WIDTH_SECTOR_ID = 4;
parameter WIDTH_FRAME_IDX = 48;
parameter WIDTH_START_SLOT_IDX = 4;
parameter WIDTH_ADDRESS = 8;

/*************************************************************************************
 *            INTERNAL WIRES & REGS                                                  *
 *************************************************************************************/
//inputs
reg					clk;
reg					kill;
reg	[WIDTH_KEY-1:0]			key_aes;
reg	[WIDTH_FLAG-1:0]		ccm_ctr_flag;
reg	[WIDTH_SECTOR_ID-1:0]		nonce_sector_id;
reg	[WIDTH_FRAME_IDX-1:0]		nonce_frame_id;
reg	[WIDTH_START_SLOT_IDX-1:0]	nonce_start_slot_idx;
reg	[WIDTH_ADDRESS-1:0]		nonce_addr_idx;
reg					in_stream_idx;
reg					in_ready;

//outputs
wire					out_stream_idx;
wire	[WIDTH_KEY-1:0]			encrypt_ctr_data;
wire					encrypt_en;

//Matlab data vectors
reg					input_ready_m[0:LENGTH_READY];
reg					input_stream_idx_m[0:LENGTH_STREAM];

reg					input_ready_r;

//Matlab files descriptor
integer		input_ready_fd;		//"input_ready.dat"
integer		input_stream_idx_fd;	//"input_stream_idx.dat"

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
ccm_ctr_fake_aes ccm_ctr_fake_aes(	.clk(clk),
					.kill(kill),
					.key_aes(key_aes),
					.ccm_ctr_flag(ccm_ctr_flag),
					.nonce_sector_id(nonce_sector_id),
					.nonce_frame_id(nonce_frame_id),
					.nonce_start_slot_idx(nonce_start_slot_idx),
					.nonce_addr_idx(nonce_addr_idx),
					.in_stream_idx(in_stream_idx),
					.in_ready(in_ready),
					.out_stream_idx(out_stream_idx),
					.encrypt_ctr_data(encrypt_ctr_data),
					.encrypt_en(encrypt_en));

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
	rst;
	init;
	wait_n_clocks(0);
	set_matlab_data;
	fork
		set_ready;
		set_stream_index;
	join
	wait_n_clocks(30);
	//$stop;
end

/*************************************************************************************
 *            TASKS                                                                  *
 *************************************************************************************/
//reset signal
task rst;
begin
	kill <= 1'b1;
	#rst_dly kill <= 1'b0;
end
endtask

/**************************************************************************************************/
//initialization all signal
task init;
begin
	key_aes = 128'hff00ff00ff00ff00ff00ff00ff00ff00;
	ccm_ctr_flag = 1'b0;
	nonce_sector_id = 1'b0;
	nonce_frame_id = 1'b0;
	nonce_start_slot_idx = 1'b0;
	nonce_addr_idx = 1'b0;
	in_stream_idx = 1'b0;
	in_ready = 1'b0;
	input_ready_r = 1'b0;
	
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
//set matlab data
task set_matlab_data;
integer i;
begin
	input_ready_fd = $fopen("../data/input_ready.dat", "r");
	input_stream_idx_fd = $fopen("../data/input_stream_idx.dat", "r");

	for (i = 0; i < LENGTH_READY; i = i + 1)
	begin
		$fscanf(input_ready_fd, "%d", input_ready_m[i]);
	end

	for (i = 0; i < LENGTH_STREAM; i = i + 1)
	begin
		$fscanf(input_stream_idx_fd, "%d", input_stream_idx_m[i]);
	end

	$fclose(input_ready_fd);
	$fclose(input_stream_idx_fd);
	$display("Matlab vector written\n");
end
endtask

/**************************************************************************************************/
//set ready
task set_ready;
integer i;
begin
	@(posedge clk)
	for (i = 0; i < LENGTH_READY; i = i + 1)
	begin
		input_ready_r <= input_ready_m[i];
		in_ready <= input_ready_r;
		@(posedge clk);
	end
	input_ready_r <= 1'b0;
	in_ready <= 1'b0;
	$display("Set ready\n");
end
endtask

/**************************************************************************************************/
//set stream index
task set_stream_index;
integer i;
begin
	@(posedge clk);
	i = 0;
	while (i < LENGTH_STREAM)
	begin
		if (input_ready_r)
		begin
			in_stream_idx <= input_stream_idx_m[i];
			i = i + 1;
		end
		@(posedge clk);
	end
	$display("Set stream index\n");
end
endtask
/**************************************************************************************************/

endmodule 
