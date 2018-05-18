/**************************************************************************************************
 *                                                                                                *
 *  File Name:     ccm_ctr_top.v                                                                  *
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
module ccm_ctr_top (
	clk,
	kill,
	input_data,
	input_en,
	input_last,
	key_aes,
	ccm_ctr_nonce,
	ccm_ctr_flag,
	
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

/**************************************************************************************************
*        I/O PORTS
 **************************************************************************************************/
input				clk;
input				kill;
input	[WIDTH-1:0]		input_data;
input				input_en;
input				input_last;
input	[WIDTH_KEY-1:0]		key_aes;
input	[WIDTH_NONCE-1:0]	ccm_ctr_nonce;
input	[WIDTH_FLAG-1:0]	ccm_ctr_flag;

output	[WIDTH-1:0]		out_data;
output				out_en;
output				out_last;
output				out_ready;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
wire				input_en_buf;
wire				encrypt_en;
wire	[WIDTH_KEY-1:0]		encrypt_data;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
ccm_ctr_data_buf ccm_ctr_data_buf(	.clk(clk),
					.kill(kill),
					.input_data(input_data),
					.input_en(input_en),
					.input_last(input_last),

					.encrypt_data(encrypt_data),
					.encrypt_en(encrypt_en),
					.max_in_en_val(input_en_buf),
					.out_data(out_data),
					.out_en(out_en),
					.out_last(out_last),
					.out_ready(out_ready));

/**************************************************************************************************/
ccm_ctr_dly_fake_aes ccm_ctr_dly_fake_aes(	.clk(clk),
						.kill(kill),
						.key_aes(key_aes),
						.ccm_ctr_nonce(ccm_ctr_nonce),
						.ccm_ctr_flag(ccm_ctr_flag),
						.input_en_buf(input_en_buf),

						.encrypt_data(encrypt_data),
						.encrypt_en(encrypt_en));

/**************************************************************************************************/


endmodule

