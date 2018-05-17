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
parameter  LENGTH_IN_EN = 79;

parameter  WIDTH = 8;
parameter  WIDTH_NONCE = 100;
parameter  WIDTH_FLAG = 8;
parameter  WIDTH_COUNT = 20;

localparam  WIDTH_KEY = WIDTH_NONCE + WIDTH_FLAG + WIDTH_COUNT;
localparam  WIDTH_BYTE_VAL = $clog2(WIDTH_KEY/8);
localparam  LENGTH_DATA_OUT = LENGTH_DATA + (128 - (LENGTH_DATA%128));
localparam  OUT_DATA_BYTE_VAL = LENGTH_DATA_OUT/8;

/*************************************************************************************
 *            INTERNAL WIRES & REGS                                                  *
 *************************************************************************************/
//inputs
reg				clk;
reg				reset;
reg	[WIDTH-1:0]		input_data;
reg				input_en;
reg				input_last;
reg	[WIDTH_KEY-1:0]		key_aes;
reg	[WIDTH_NONCE-1:0]	ccm_ctr_nonce;
reg	[WIDTH_FLAG-1:0]	ccm_ctr_flag;

//outputs
wire	[WIDTH-1:0]		out_data;
wire				out_en;
wire				out_last;

//Matlab data vectors
reg	[31:0]			input_data_len;
reg	[31:0]			input_enable_len;
reg	[31:0]			output_data_len;

reg	[WIDTH-1:0]		input_data_m[0:LENGTH_DATA/8];
reg				input_enable_m[0:LENGTH_IN_EN - 1];
reg	[WIDTH-1:0]		output_data_m[0:LENGTH_DATA_OUT/8];

reg 				input_enable_r;

//Matlab files descriptors
integer		input_data_fd;		//"input_data.dat"	
integer		input_enable_fd;	//"input_enable.dat"	
integer		output_data_fd;		//"output_data.dat"

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
ccm_ctr ccm_ctr( 	.clk(clk), 
			.reset(reset), 
			.input_data(input_data), 
			.input_en(input_en), 
			.input_last(input_last), 
			.key_aes(key_aes),
			.ccm_ctr_nonce(ccm_ctr_nonce), 
			.ccm_ctr_flag(ccm_ctr_flag), 
			.out_data(out_data), 
			.out_en(out_en),
			.out_last(out_last));


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
	//ccm_ctr_set_data_ini;
	ccm_ctr_set_matlab_data;
	wait_n_clocks(0);
	fork
		ccm_ctr_set_enable;
		ccm_ctr_set_data;
		ccm_ctr_write_data;
	join
	ccm_ctr_write2matlab;
	wait_n_clocks(50);
	$stop;
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
	input_last = 1'b0;
	key_aes = 128'hff00ff00ff00ff00ff00ff00ff00ff00;
	//key_aes = 128'd0;
	ccm_ctr_nonce = 1'b0;
	ccm_ctr_flag = 1'b0;
	
end
endtask

/**************************************************************************************************/
//set Matlab data

task ccm_ctr_set_matlab_data;
integer i;
begin
	input_data_fd = $fopen("D:/Project/PROJECT_GIGABIT/CCM_AES/data/input_data.dat", "r");
	$fscanf(input_data_fd, "%d", input_data_len);

	input_enable_fd = $fopen("D:/Project/PROJECT_GIGABIT/CCM_AES/data/input_enable.dat", "r");
	$fscanf(input_enable_fd, "%d", input_enable_len);

	for (i = 0; i < input_data_len; i = i + 1)
	begin
		$fscanf(input_data_fd, "%b", input_data_m[i]);
	end

	for (i = 0; i < input_enable_len; i = i + 1)
	begin
		$fscanf(input_enable_fd, "%b", input_enable_m[i]);
	end

	$fclose(input_data_fd);
	$fclose(input_enable_fd);
	$display("Matlab vector written\n");
end
endtask
/**************************************************************************************************/
//write Matlab data

task ccm_ctr_write2matlab;
integer i;
begin
	output_data_fd = $fopen("D:/Project/PROJECT_GIGABIT/CCM_AES/data/output_data.dat","w");
	$fdisplay(output_data_fd, "%d", OUT_DATA_BYTE_VAL);

	for (i = 0; i < OUT_DATA_BYTE_VAL; i = i + 1)
	begin
		$fdisplay(output_data_fd, "%b", output_data_m[i]);
	end
	
	$fclose(output_data_fd);
	$display("Output data written to Matlab\n");
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
	@(posedge clk)
	for (i = 0; i <= input_enable_len; i = i + 1)
	begin
		input_enable_r <= input_enable_m[i];
		input_en <= input_enable_r;
		if (i == input_enable_len)
			input_last <= 1'b1;
		@(posedge clk);
	end
	input_last <= 1'b0;
	input_enable_r <= 1'b0;
	input_en <= 1'b0;

	$display("Input enable was set\n");
end
endtask

/**************************************************************************************************/
//set input data

task ccm_ctr_set_data;
integer i;
begin
	@(posedge clk);
	i = 0;
	while (i < input_data_len)
	begin
		if (input_enable_r)
		begin
			input_data <= input_data_m[i];
			i = i + 1;
		end
		@(posedge clk);
	end
	$display("Input data was set\n");
	
end
endtask

/**************************************************************************************************/
//wtite output data

task ccm_ctr_write_data;
integer i;
begin
	i = 0;
	while (i < OUT_DATA_BYTE_VAL)
	begin
		while (out_en == 0)
			@(posedge clk);

		output_data_m[i] <= out_data;
		i = i + 1;
		@(posedge clk);
	end
	$display("Output data transmit\n");

end
endtask

/**************************************************************************************************/


endmodule
