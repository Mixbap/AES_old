/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_ram.v                                                                  *
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

module aes_128_ram (
	clk,
	kill,
	input_data,
	input_en,
	key_round,
	
	output_data,
	output_en,
	);

/**************************************************************************************************
*        PARAMETERS
 **************************************************************************************************/
parameter LENGTH_RAM = 2^16;

/**************************************************************************************************
*        I/O PORTS
 **************************************************************************************************/
input			clk;
input			kill;
input	[127:0]		input_data;
input			input_en;
input	[127:0]		key_round;

output	reg	[127:0]	output_data;
output	reg		output_en;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[31:0]		ram0 [LENGTH_RAM-1:0];
reg	[31:0]		ram1 [LENGTH_RAM-1:0];
reg	[31:0]		ram2 [LENGTH_RAM-1:0];
reg	[31:0]		ram3 [LENGTH_RAM-1:0];

reg	[31:0]		ram0_out;
reg	[31:0]		ram1_out;
reg	[31:0]		ram2_out;
reg	[31:0]		ram3_out;

reg	[127:0]		mixcolumns_out;
reg			input_en_r;
reg	[127:0]		round_data;
reg	[3:0]		round;
reg	[1:0]		count_clk;

/*************************************************************************************
 *            INITIAL                                                                *
 *************************************************************************************/
//initialization ram
integer i;
initial 
begin
	for (i = 0; i < LENGTH_RAM; i = i + 1) 
		ram0[i] = 32'hffffffff;
	for (i = 0; i < LENGTH_RAM; i = i + 1) 
		ram1[i] = 32'b0;
	for (i = 0; i < LENGTH_RAM; i = i + 1) 
		ram2[i] = 32'b0;
	for (i = 0; i < LENGTH_RAM; i = i + 1) 
		ram3[i] = 32'b0;
end

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//ShiftRows and SubBytes
always @(posedge clk)
	if (kill)
		begin
			ram0_out <= 32'b0;
			ram1_out <= 32'b0;
			ram2_out <= 32'b0;
			ram3_out <= 32'b0;
		end
	else 
		begin
			ram0_out <= ram0[ {round_data[7:0], round_data[47:40], round_data[87:80], round_data[127:120]} ];
			ram1_out <= ram1[ {round_data[39:32], round_data[79:72], round_data[119:112], round_data[31:24] }];
			ram2_out <= ram2[ {round_data[71:64], round_data[111:104], round_data[15:8], round_data[63:56] }];
			ram3_out <= ram3[ {round_data[103:96], round_data[7:0], round_data[55:48], round_data[95:88] }];
		end

/**************************************************************************************************/
//MixColumns
always @(posedge clk)
	if (kill)
		mixcolumns_out <= 128'b0;
	else if (round == 4'ha)
		begin
			mixcolumns_out[31:0] <= ram0_out;
			mixcolumns_out[63:32] <= ram1_out;
			mixcolumns_out[95:64] <= ram2_out;
			mixcolumns_out[127:96] <= ram3_out;
		end
	else
		begin
			mixcolumns_out[31:0] <= mix_columns_func(ram0_out);
			mixcolumns_out[63:32] <= mix_columns_func(ram1_out);
			mixcolumns_out[95:64] <= mix_columns_func(ram2_out);
			mixcolumns_out[127:96] <= mix_columns_func(ram3_out);
		end
			
/**************************************************************************************************/
//multiply 2 in MixColumns
function [7:0] mult2;
input	[7:0]	data;
begin
	if (data[0])
		mult2 = {1'b0, data[7:1]} ^ 8'h1b;
	else
		mult2 = {1'b0, data[7:1]};
end
endfunction			
		
/**************************************************************************************************/
//multiply 3 in MixColumns
function [7:0] mult3;
input	[7:0]	data;
begin
	if (data[0])
		mult3 = {1'b0, data[7:1]} ^ 8'h1b ^ data;
	else
		mult3 = {1'b0, data[7:1]} ^ data;
end
endfunction	

/**************************************************************************************************/
//MixColumns function
function [31:0] mix_columns_func;
input	[31:0]	data;
begin
	mix_columns_func[7:0] = mult2(data[7:0]) ^ mult3(data[15:8]) ^ data[23:16] ^ data[31:24]; 
	mix_columns_func[15:8] = data[7:0] ^ mult2(data[15:8]) ^ mult3(data[23:16]) ^ data[31:24]; 
	mix_columns_func[23:16] = data[7:0] ^ data[15:8] ^ mult2(data[23:16]) ^ mult3(data[31:24]); 
	mix_columns_func[31:24] = mult3(data[7:0]) ^ data[15:8] ^ data[23:16] ^ mult2(data[31:24]); 
end
endfunction

/**************************************************************************************************/
//AddRoundKey
always @(posedge clk)
	if (kill)
		round_data <= 128'b0;
	else if (input_en)
		round_data <= input_data ^ key_round;
	else
		round_data <= mixcolumns_out ^ key_round;

/**************************************************************************************************/
//Round
always @(posedge clk)
	if (kill)
		round <= 4'b1;
	else if (input_en)
		round <= 4'b1;
	else if ((round == 4'b1) | (count_clk == 2'b10))
		round <= round + 4'b1;

/**************************************************************************************************/
//input_en_r
always @(posedge clk)
	if (kill)
		input_en_r <= 1'b0;
	else if (round == 4'ha)
		input_en_r <= 1'b0;
	else if (input_en)
		input_en_r <= 1'b1;

/**************************************************************************************************/
//count_clk
always @(posedge clk)
	if (kill)
		count_clk <= 2'b0;
	else if (count_clk == 2'b10)
		count_clk <= 2'b0;
	else if (input_en_r)
		count_clk <= count_clk + 2'b1;

/**************************************************************************************************/
//Output data
always @(posedge clk)
	if (kill)
		output_data <= 128'b0;
	else if (round == 4'ha)
		output_data <= round_data;
	else
		output_data <= 128'b0;

/**************************************************************************************************/
//Output enable
always @(posedge clk)
	if (kill)
		output_en <= 1'b0;
	else if (round == 4'ha)
		output_en <= 1'b1;
	else
		output_en <= 1'b0;

/**************************************************************************************************/
endmodule
