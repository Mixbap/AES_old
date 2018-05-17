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
	ccm_ctr_nonce,
	ccm_ctr_flag,
	
	out_data,
	out_en,
	out_last
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
input	[WIDTH_NONCE-1:0]	ccm_ctr_nonce;
input	[WIDTH_FLAG-1:0]	ccm_ctr_flag;

output	[WIDTH-1:0]		out_data;
output	reg			out_en;
output	reg			out_last;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[WIDTH_KEY-1:0]		in_buf;
reg	[WIDTH_KEY-1:0]		out_buf;
reg	[WIDTH_KEY-1:0]		encrypt_buf;
reg	[WIDTH_COUNT-1:0]	encrypt_ctr_buf;
reg	[WIDTH_BYTE_VAL-1:0]	in_en_val;
reg	[WIDTH_BYTE_VAL-1:0]	out_en_val;
reg				max_in_en_val;
reg				input_last_r;
reg				out_last_flag;

wire	[WIDTH_KEY-1:0]		encrypt_data;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//Initialization ctr
always @(posedge clk)
	if (reset)
		begin
			encrypt_buf <= {WIDTH_KEY{1'b0}};
			encrypt_ctr_buf <= 1'b1;
		end
	else if (max_in_en_val)
		encrypt_ctr_buf <= encrypt_ctr_buf + 1'b1;
	else
		encrypt_buf <= {ccm_ctr_flag, ccm_ctr_nonce, encrypt_ctr_buf};

assign encrypt_data = encrypt_buf ^ key_aes;

/**************************************************************************************************/
//Input shift register

always @(posedge clk)
	if (reset)
		in_buf <= {WIDTH_KEY{1'b0}};
	else if (input_en)
		in_buf <= {in_buf[WIDTH_KEY-WIDTH-1:0], input_data[WIDTH-1:0]};
	else if (input_last_r)
		in_buf <= {in_buf[WIDTH_KEY-WIDTH-1:0], {WIDTH{1'b0}}};

/**************************************************************************************************/
//input last
always @(posedge clk)
	if (reset)
		input_last_r <= 1'b0;
	else if (input_last)
		input_last_r <= 1'b1;
	else if (in_en_val == {WIDTH_BYTE_VAL{1'b0}})
		input_last_r <= 1'b0;


/**************************************************************************************************/
//Counter input enable
always @(posedge clk)
	if (reset)
		in_en_val <= {WIDTH_BYTE_VAL{1'b0}};
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
		out_buf <= {WIDTH_KEY{1'b0}};
	else if (max_in_en_val)
		out_buf <= encrypt_data ^ in_buf;
	else if (out_en)
		out_buf <= out_buf << WIDTH;

assign out_data = out_buf[WIDTH_KEY-1:WIDTH_KEY-WIDTH];

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
		out_en_val <= {WIDTH_BYTE_VAL{1'b0}};
	else if (out_en)
		out_en_val <= out_en_val + 1'b1;

/**************************************************************************************************/
//out_last_flag
always @(posedge clk)
	if (reset)
		out_last_flag <= 1'b0;
	else if (input_last_r & (out_en_val == {WIDTH_BYTE_VAL{1'b0}}))
		out_last_flag <= 1'b1;
	else if (out_last)
		out_last_flag <= 1'b0;

/**************************************************************************************************/
//Out last
always @(posedge clk)
	if (reset)
		out_last <= 1'b0;
	else if ((out_en_val == 4'd14) & out_last_flag)
		out_last <= 1'b1;
	else 
		out_last <= 1'b0;

/**************************************************************************************************/

endmodule








