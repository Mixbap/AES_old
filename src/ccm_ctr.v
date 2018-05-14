/**************************************************************************************************
 *                                                                                                *
 *  File Name:     ccm_ctr.v                                                                      *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block CCM - encrypted counter and xor input data                                              *
 *                                                                                                *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/
module ccm_ctr (
	clk,
	reset,
	input_data,
	input_en,
	input_last,
	key_aes,
	ctr_nonce,
	ctr_flag,
	
	out_data,
	out_en,
	max_in_en_val,
	in_en_val
	);

/**************************************************************************************************
*        PARAMETERS
 **************************************************************************************************/
 parameter  WIDTH = 8;
 parameter  WIDTH_NONCE = 100;
 parameter  WIDTH_FLAG = 8;
 parameter  WIDTH_COUNT = 20;

localparam  WIDTH_KEY = WIDTH_NONCE + WIDTH_FLAG + WIDTH_COUNT;
localparam  WIDTH_BYTE_VAL = $clog2(WIDTH_KEY/8);

/**************************************************************************************************
*        I/O PORTS
 **************************************************************************************************/
input				clk;
input				reset;
input	[WIDTH-1:0]		input_data;
input				input_en;
input				input_last;
input	[WIDTH_KEY-1:0]		key_aes;
input	[WIDTH_NONCE-1:0]	ctr_nonce;
input	[WIDTH_FLAG-1:0]	ctr_flag;

output	[WIDTH-1:0]		out_data;
output	reg			out_en;
output	reg			max_in_en_val;
output	reg	[3:0]		in_en_val;
/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[WIDTH_KEY-1:0]		ctr_reg_in;
reg	[WIDTH_KEY-1:0]		ctr_reg_out;
reg	[WIDTH_KEY-1:0]		ctr_reg_encrypt;
reg	[WIDTH_COUNT-1:0]	ctr_reg_encrypt_count;
//reg	[WIDTH_BYTE_VAL-1:0]	in_en_val;
reg	[WIDTH_BYTE_VAL-1:0]	out_en_val;
//reg				max_in_en_val;
reg				input_last_r;

wire	[WIDTH_KEY-1:0]		ctr_encrypt_aes;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//Initialization ctr
always @(posedge clk)
	if (reset)
		begin
			ctr_reg_encrypt <= 1'b0;
			ctr_reg_encrypt_count <= 20'd1;
		end
	else if (max_in_en_val)
		ctr_reg_encrypt_count <= ctr_reg_encrypt_count + 1'b1;
	else
		ctr_reg_encrypt <= {ctr_flag, ctr_nonce, ctr_reg_encrypt_count};

assign ctr_encrypt_aes = ctr_reg_encrypt ^ key_aes;

/**************************************************************************************************/
//Input shift register
always @(posedge clk)
	if (reset)
		ctr_reg_in <= 1'b0;
	else if (input_en)
		ctr_reg_in <= {ctr_reg_in[WIDTH_KEY-WIDTH-1:0], input_data[WIDTH-1:0]};
	else if (input_last_r)
		ctr_reg_in <= {ctr_reg_in[WIDTH_KEY-WIDTH-1:0], 8'd0};

/**************************************************************************************************/
//input last
always @(posedge clk)
	if (reset)
		input_last_r <= 1'b0;
	else if (input_last)
		input_last_r <= 1'b1;
	else if (in_en_val == 1'b0)
		input_last_r <= 1'b0;


/**************************************************************************************************/
//Counter input enable
always @(posedge clk)
	if (reset)
		in_en_val <= 1'b0;
	else if (input_en)
		in_en_val <= in_en_val + 1'b1;
	else if (input_last_r)
		in_en_val <= in_en_val + 1'b1;

/**************************************************************************************************/
//max_in_en_val
always @(posedge clk)
	if (reset)
		max_in_en_val <= 1'b0;
	else if ((in_en_val == 4'd15) & (input_en | input_last_r))
		max_in_en_val <= 1'b1;
	else 
		max_in_en_val <= 1'b0;

/**************************************************************************************************/
//Output shift register
always @(posedge clk)
	if (reset)
		ctr_reg_out <= 1'b0;
	else if (max_in_en_val)
		ctr_reg_out <= ctr_encrypt_aes ^ ctr_reg_in;
	else if (out_en)
		ctr_reg_out <= ctr_reg_out << WIDTH;

assign out_data[WIDTH-1:0] = ctr_reg_out[WIDTH_KEY-1:WIDTH_KEY-WIDTH];

/**************************************************************************************************/
//Output enable
always @(posedge clk)
	if (reset)
		out_en <= 1'b0;
	else if (max_in_en_val)
		out_en <= 1'b1;
	else if (out_en_val == 4'd15)
		out_en <= 1'b0;


/**************************************************************************************************/
//Counter output enable
always @(posedge clk)
	if (reset)
		out_en_val <= 1'b0;
	else if (out_en)
		out_en_val <= out_en_val + 1'b1;

/**************************************************************************************************/


endmodule
