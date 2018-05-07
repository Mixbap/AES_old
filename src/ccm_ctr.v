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
	input_data_length,
	key_aes,
	ctr_nonce,
	ctr_flag,
	
	out_data,
	out_en
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
input	[WIDTH-1:0]		input_data_length;
input	[WIDTH_KEY-1:0]		key_aes;
input	[WIDTH_NONCE-1:0]	ctr_nonce;
input	[WIDTH_FLAG-1:0]	ctr_flag;

output	[WIDTH-1:0]		out_data;
output	reg			out_en;
/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[WIDTH_KEY-1:0]		ctr_reg_in;
reg	[WIDTH_KEY-1:0]		ctr_reg_out;
reg	[WIDTH_KEY-1:0]		ctr_reg_encrypt;
reg	[WIDTH_COUNT-1:0]	ctr_reg_encrypt_count;
reg	[WIDTH_BYTE_VAL:0]	count_in_en;
reg	[WIDTH_BYTE_VAL:0]	count_out_en;
reg	[WIDTH-1:0]		length_reg;

wire	[WIDTH_KEY-1:0]		ctr_encrypt_aes;
wire				data_no_full_section;
wire				clr_count_in_en;
wire				clr_count_out_en;
/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//Initialization ctr
always @(posedge clk)
	if (reset)
		begin
			ctr_reg_encrypt <= 1'b0;
			ctr_reg_encrypt_count <= 1'b1;
		end
	else if (count_in_en == 1'b1)
		begin
			ctr_reg_encrypt <= {ctr_flag[WIDTH_FLAG-1:0], ctr_nonce[WIDTH_NONCE-1:0], ctr_reg_encrypt_count[WIDTH_COUNT-1:0]};
			ctr_reg_encrypt_count <= ctr_reg_encrypt_count + 1'b1;
		end

assign ctr_encrypt_aes = ctr_reg_encrypt ^ key_aes;

/**************************************************************************************************/
//Input shift register
always @(posedge clk)
	if (reset)
		ctr_reg_in <= 1'b0;
	else if (input_en)
		ctr_reg_in[WIDTH_KEY-1:0] <= {ctr_reg_in[WIDTH_KEY-WIDTH-1:0], input_data[WIDTH-1:0]};
	else if (~(count_in_en == 1'b1))
		ctr_reg_in[WIDTH_KEY-1:0] <= {ctr_reg_in[WIDTH_KEY-WIDTH-1:0], input_data[WIDTH-1:0]};

/**************************************************************************************************/
//Counter input enable
always @(posedge clk)
	if (reset)
		count_in_en <= 1'b0;
	else if (clr_count_in_en & input_en)
		count_in_en <= 1'b1;
	else if (clr_count_in_en)
		count_in_en <= 1'b0;
	else if (input_en)
		count_in_en <= count_in_en + 1'b1;
	else if (data_no_full_section)
		count_in_en <= count_in_en + 1'b1;

assign data_no_full_section = (~(| length_reg)) & (| count_in_en);
assign clr_count_in_en = count_in_en[4] & (~count_in_en[3]) & (~count_in_en[2]) & (~count_in_en[1]) & (~count_in_en[0]);

/**************************************************************************************************/
//Length register
always @(posedge clk)
	if (reset)
		length_reg <= 1'b0;	
	else if (input_en & (length_reg == 0))
		length_reg <= input_data_length - 4'b1000;
	else if (input_en & (length_reg != 0))
		length_reg <= length_reg - 4'b1000;

/**************************************************************************************************/
//Output shift register
always @(posedge clk)
	if (reset)
		ctr_reg_out <= 1'b0;
	else if (count_in_en == 5'd16)
		ctr_reg_out <= ctr_encrypt_aes ^ ctr_reg_in;
	else if (out_en)
		ctr_reg_out <= ctr_reg_out >> WIDTH;

assign out_data[WIDTH-1:0] = ctr_reg_out[WIDTH-1:0];

/**************************************************************************************************/
//Output enable
always @(posedge clk)
	if (reset)
		out_en <= 1'b0;
	else if (count_in_en == 5'd16)
		out_en <= 1'b1;
	else if (count_out_en == 5'd15)
		out_en <= 1'b0;


/**************************************************************************************************/
//Counter output enable
always @(posedge clk)
	if (reset)
		count_out_en <= 1'b0;
	else if (clr_count_out_en)
		count_out_en <= 1'b0;
	else if (out_en)
		count_out_en <= count_out_en + 1'b1;

assign clr_count_out_en = count_out_en[3] & count_out_en[2] & count_out_en[1] & count_out_en[0];

/**************************************************************************************************/


endmodule
