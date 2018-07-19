/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_mixcol.v                                                               *
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

module aes_128_mixcol (
	clk,
	kill,
	en,
	in_data,

	out_data
	);

/**************************************************************************************************
*        I/O PORTS
 **************************************************************************************************/
input			clk;
input			kill;
input			en;
input		[127:0]	in_data;

output	reg	[127:0]	out_data;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//MixColumns
always @(posedge clk)
	if (kill)
		out_data <= 128'b0;
	else if (en)
		out_data <= in_data;
	else 
		begin
			out_data[31:0] <= mix_columns(in_data[31:0]);
			out_data[63:32] <= mix_columns(in_data[63:32]);
			out_data[95:64] <= mix_columns(in_data[95:64]);
			out_data[127:96] <= mix_columns(in_data[127:96]);
		end
			
/**************************************************************************************************/
//multiplication on 2 in MixColumns
function [7:0] mult2;
input	[7:0]	data;
begin
	if (data[7])
		mult2 = {data[6:0], 1'b0} ^ 8'h1b;
	else
		mult2 = {data[6:0], 1'b0};
end
endfunction			
		
/**************************************************************************************************/
//multiplication on 3 in MixColumns
function [7:0] mult3;
input	[7:0]	data;
begin
	if (data[7])
		mult3 = {data[6:0], 1'b0} ^ 8'h1b ^ data;
	else
		mult3 = {data[6:0], 1'b0} ^ data;
end
endfunction	

/**************************************************************************************************/
//MixColumns function
function [31:0] mix_columns;
input	[31:0]	data;
begin
	mix_columns[7:0] = mult2(data[7:0]) ^ mult3(data[15:8]) ^ data[23:16] ^ data[31:24]; 
	mix_columns[15:8] = data[7:0] ^ mult2(data[15:8]) ^ mult3(data[23:16]) ^ data[31:24]; 
	mix_columns[23:16] = data[7:0] ^ data[15:8] ^ mult2(data[23:16]) ^ mult3(data[31:24]); 
	mix_columns[31:24] = mult3(data[7:0]) ^ data[15:8] ^ data[23:16] ^ mult2(data[31:24]);
end
endfunction

/**************************************************************************************************/

endmodule

