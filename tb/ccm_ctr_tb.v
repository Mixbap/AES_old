/**************************************************************************************************
 *                                                                                                *
 *  File Name:     ccm_ctr_tb.v                                                                   *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Testbench block CCM - encrypted counter and xor input data                                    *
 *                                                                                                *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/

`timescale 1ns / 1ps

module test_tb;


 /*************************************************************************************
 *            PARAMETERS                                                             *
 *************************************************************************************/
parameter clk_dly = 20;
parameter rst_dly = 50;

parameter  LENGTH_DATA = 272;

parameter  WIDTH = 8;
parameter  WIDTH_NONCE = 100;
parameter  WIDTH_FLAG = 8;
parameter  WIDTH_COUNT = 20;

localparam  WIDTH_KEY = WIDTH_NONCE + WIDTH_FLAG + WIDTH_COUNT;
localparam  WIDTH_BYTE_VAL = $clog2(WIDTH_KEY/8);
localparam  LENGTH_DATA_OUT = LENGTH_DATA + (128 - (LENGTH_DATA%128));

/*************************************************************************************
 *            INTERNAL WIRES & REGS                                                  *
 *************************************************************************************/
//inputs
reg				clk;
reg				reset;
reg	[WIDTH-1:0]		input_data;
reg				input_en;
reg	[WIDTH-1:0]		input_data_length;
reg	[WIDTH_KEY-1:0]		key_aes;
reg	[WIDTH_NONCE-1:0]	ctr_nonce;
reg	[WIDTH_FLAG-1:0]	ctr_flag;

//outputs
wire	[WIDTH-1:0]		out_data;
wire				out_en;

//Matlab data vectors
reg	[LENGTH_DATA-1:0]	input_data_m;
reg	[LENGTH_DATA_OUT-1:0]	output_data_m;

//Matlab files descriptors
integer		input_data_fd;		//"input_data.dat"	
integer		output_data_fd;		//"output_data.dat"

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
ccm_ctr ccm_ctr(clk, reset, input_data, input_en, input_data_length, key_aes, ctr_nonce, ctr_flag, out_data, out_en);


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
	ccm_ctr_rst;
	ccm_ctr_ini;
	ccm_ctr_set_data_ini;
	//ccm_ctr_set_matlab_data;
	wait_n_clocks(0);
	fork
		ccm_ctr_set_enable;
		ccm_ctr_set_data;
	join
	ccm_ctr_write_data;
	ccm_ctr_write2matlab;
end

/*************************************************************************************
 *            TASKS                                                                  *
 *************************************************************************************/
//reset signal
task ccm_ctr_rst;
begin
	reset <= 1'b1;
	#rst_dly reset <= 1'b0;
end
endtask

/**************************************************************************************************/
//initialization all signal
task ccm_ctr_ini;
begin
	input_en = 1'b0;
	input_data = 1'b0;
	input_data_length = LENGTH_DATA;
	key_aes = 128'hff00ff00ff00ff00ff00ff00ff00ff00;
	ctr_nonce = 1'b0;
	ctr_flag = 1'b0;
end
endtask

/**************************************************************************************************/
//set Matlab data

task ccm_ctr_set_matlab_data;
begin
	input_data_fd = $fopen("D:/Project/Project_MATLAB/CCM_model/input_data.dat", "r");
	$fscanf(input_data_fd, "%d", input_data_m);

	$fclose(input_data_fd);
	$display("Matlab vector written\n");
end
endtask
/**************************************************************************************************/
//write Matlab data

task ccm_ctr_write2matlab;
begin
	output_data_fd = $fopen("D:/Project/Project_Modelsim/CCM/data/output_data.dat","w");
	$fdisplay(output_data_fd, "%d", output_data_m);
	
	$fclose(output_data_fd);
	$display("Output data written to Matlab\n");
end
endtask

/**************************************************************************************************/
//set input data
task ccm_ctr_set_data_ini;
begin
	//input_data_m = 16'b1100110011110000;
	input_data_m = 272'haaff00ff00ff00ff00ff00ff00ff00ff332201010101010101010101010101013534;
	//input_data_m = 384'haaff00ff00ff00ff00ff00ff00ff00ff33220101010101010101010101010101ff220101010101010101010101010101;
	//input_data_m = 144'haaff00ff00ff00ff00ff00ff00ff00ffb7b2;
	input_data = input_data_m[LENGTH_DATA-1:LENGTH_DATA-WIDTH];
	input_data_m = input_data_m << WIDTH;
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

task ccm_ctr_set_enable;
integer i;
begin
	//@(posedge clk);
	for (i = 0; i < (LENGTH_DATA/8); i = i + 1)
		begin
			input_en <= 1'b1;
			@(posedge clk);
		end
	input_en <= 1'b0;
end
endtask

/**************************************************************************************************/
//set input data

task ccm_ctr_set_data;
integer i;
begin
	@(posedge clk);
	for (i = 0; i < LENGTH_DATA; i = i + 1)
		begin
			if (input_en)
				begin
					input_data <= input_data_m[LENGTH_DATA-1:LENGTH_DATA-WIDTH];
					input_data_m <= input_data_m << WIDTH;
					@(posedge clk);
				end
		end
	
end
endtask

/**************************************************************************************************/
//wtite output data

task ccm_ctr_write_data;
begin
	if (out_en)
		begin
			output_data_m[WIDTH-1:0] <= out_data;
			output_data_m <= output_data_m << WIDTH;
			@(posedge clk);
		end
end
endtask

/**************************************************************************************************/


endmodule
