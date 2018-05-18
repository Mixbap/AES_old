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
module ccm_ctr_data_buf (
	clk,
	kill,
	input_data,
	input_en,
	input_last,
	encrypt_data,
	encrypt_en,
	max_in_en_val,

	out_data,
	out_en,
	out_last,
	out_ready
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
input				kill;
input	[WIDTH-1:0]		input_data;
input				input_en;
input				input_last;
input	[WIDTH_KEY-1:0]		encrypt_data;
input				encrypt_en;

output	reg			max_in_en_val;
output	[WIDTH-1:0]		out_data;
output	reg			out_en;
output	reg			out_last;
output	reg			out_ready;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[WIDTH_KEY-1:0]		in_buf;
reg	[WIDTH_KEY-1:0]		out_buf;
reg	[WIDTH_BYTE_VAL-1:0]	in_en_val;
reg	[WIDTH_BYTE_VAL-1:0]	out_en_val;
reg				input_last_r;
reg				out_last_flag;


/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//Input shift register

always @(posedge clk)
	if (kill)
		in_buf <= {WIDTH_KEY{1'b0}};
	else if (input_en & (~max_in_en_val) & out_ready)
		in_buf <= {in_buf[WIDTH_KEY-WIDTH-1:0], input_data[WIDTH-1:0]};
	else if (input_last_r & (~max_in_en_val) & out_ready)
		in_buf <= {in_buf[WIDTH_KEY-WIDTH-1:0], {WIDTH{1'b0}}};

/**************************************************************************************************/
//input last
always @(posedge clk)
	if (kill)
		input_last_r <= 1'b0;
	else if (input_last)
		input_last_r <= 1'b1;
	else if (in_en_val == {WIDTH_BYTE_VAL{1'b0}})
		input_last_r <= 1'b0;


/**************************************************************************************************/
//Counter input enable
always @(posedge clk)
	if (kill)
		in_en_val <= {WIDTH_BYTE_VAL{1'b0}};
	else if (input_en & (~max_in_en_val) & out_ready)
		in_en_val <= in_en_val + {{WIDTH_BYTE_VAL-1{1'b0}}, 1'b1};
	else if (input_last_r)
		in_en_val <= in_en_val + {{WIDTH_BYTE_VAL-1{1'b0}}, 1'b1};

/**************************************************************************************************/
//max_in_en_val
always @(posedge clk)
	if (kill)
		max_in_en_val <= 1'b0;
	else if ((in_en_val == {{WIDTH_BYTE_VAL-4{1'b0}}, 4'd15}) & (input_en | input_last_r))
		max_in_en_val <= 1'b1;
	else 
		max_in_en_val <= 1'b0;

/**************************************************************************************************/
//Output shift register
always @(posedge clk)
	if (kill)
		out_buf <= {WIDTH_KEY{1'b0}};
	else if (encrypt_en)
		out_buf <= encrypt_data ^ in_buf;
	else if (out_en)
		out_buf <= out_buf << WIDTH;

assign out_data = out_buf[WIDTH_KEY-1:WIDTH_KEY-WIDTH];

/**************************************************************************************************/
//Output enable
always @(posedge clk)
	if (kill)
		out_en <= 1'b0;
	else if (encrypt_en)
		out_en <= 1'b1;
	else if (out_en_val == {{WIDTH_BYTE_VAL-4{1'b0}}, 4'd15})
		out_en <= 1'b0;


/**************************************************************************************************/
//Counter output enable
always @(posedge clk)
	if (kill)
		out_en_val <= {WIDTH_BYTE_VAL{1'b0}};
	else if (out_en)
		out_en_val <= out_en_val + {{WIDTH_BYTE_VAL-1{1'b0}}, 1'b1};

/**************************************************************************************************/
//out_last_flag
always @(posedge clk)
	if (kill)
		out_last_flag <= 1'b0;
	else if (input_last_r & (out_en_val == {WIDTH_BYTE_VAL{1'b0}}))
		out_last_flag <= 1'b1;
	else if (out_last)
		out_last_flag <= 1'b0;

/**************************************************************************************************/
//Out last
always @(posedge clk)
	if (kill)
		out_last <= 1'b0;
	else if ((out_en_val == {{WIDTH_BYTE_VAL-4{1'b0}}, 4'd14}) & out_last_flag)
		out_last <= 1'b1;
	else 
		out_last <= 1'b0;

/**************************************************************************************************/
//Out ready
always @(posedge clk)
	if (kill)
		out_ready <= 1'b1;
	else if (max_in_en_val)
		out_ready <= 1'b0;
	else if (encrypt_en)
		out_ready <= 1'b1;

/**************************************************************************************************/



endmodule








