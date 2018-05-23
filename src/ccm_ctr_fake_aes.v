/**************************************************************************************************
 *                                                                                                *
 *  File Name:     ccm_ctr_fake_aes.v                                                             *
 *                                                                                                *
 **************************************************************************************************
 *                                                                                                *
 *  Description:                                                                                  *
 *                                                                                                *
 *  Block CCM - encrypted counter                                                                 *
 *                                                                                                *
 **************************************************************************************************
 *  Verilog code                                                                                  *
 **************************************************************************************************/
module ccm_ctr_fake_aes(
	clk,
	kill,
	key_aes,
	ccm_ctr_flag,
	nonce_sector_id,
	nonce_frame_id,
	nonce_start_slot_idx,
	nonce_addr_idx,
	in_stream_idx,
	in_ready,

	out_stream_idx,
	encrypt_ctr_data,
	encrypt_en
	);

/**************************************************************************************************
*        PARAMETERS
 **************************************************************************************************/
parameter WIDTH_KEY = 128;
parameter WIDTH_FLAG = 8;
parameter WIDTH_COUNT = 20;
parameter WIDTH_SECTOR_ID = 4;
parameter WIDTH_FRAME_IDX = 48;
parameter WIDTH_START_SLOT_IDX = 4;
parameter WIDTH_ADDRESS = 8;

/**************************************************************************************************
*        I/O PORTS
 **************************************************************************************************/
input					clk;
input					kill;
input	[WIDTH_KEY-1:0]			key_aes;
input	[WIDTH_FLAG-1:0]		ccm_ctr_flag;
input	[WIDTH_SECTOR_ID-1:0]		nonce_sector_id;
input	[WIDTH_FRAME_IDX-1:0]		nonce_frame_id;
input	[WIDTH_START_SLOT_IDX-1:0]	nonce_start_slot_idx;
input	[WIDTH_ADDRESS-1:0]		nonce_addr_idx;
input					in_stream_idx;
input					in_ready;

output					out_stream_idx;
output	[WIDTH_KEY-1:0]			encrypt_ctr_data;
output	reg				encrypt_en;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg	[WIDTH_COUNT-1:0]	n_inc_0;
reg	[WIDTH_COUNT-1:0]	n_inc_1;
reg	[WIDTH_KEY-1:0]		encrypt_buf_0;
reg	[WIDTH_KEY-1:0]		encrypt_buf_1;
reg				in_stream_idx_r;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//in_stream_idx_r
always @(posedge clk)
	if (kill)
		in_stream_idx_r <= 1'b0;
	else if (in_ready)
		in_stream_idx_r <= in_stream_idx;

/**************************************************************************************************/
//out_stream_idx_r
assign out_stream_idx = in_stream_idx_r;

/**************************************************************************************************/
//n_inc_0
always @(posedge clk)
	if (kill)
		n_inc_0 <= {{WIDTH_COUNT-1{1'b0}}, 1'b1};
	else if (~in_stream_idx & in_ready)
		n_inc_0 <= n_inc_0 + {{WIDTH_COUNT-1{1'b0}}, 1'b1};

/**************************************************************************************************/
//n_inc_1
always @(posedge clk)
	if (kill)
		n_inc_1 <= {{WIDTH_COUNT-1{1'b0}}, 1'b1};
	else if (in_stream_idx & in_ready)
		n_inc_1 <= n_inc_1 + {{WIDTH_COUNT-1{1'b0}}, 1'b1};

/**************************************************************************************************/
//encrypt_buf_0
always @(posedge clk)
	if (kill)
		encrypt_buf_0 <= {WIDTH_KEY{1'b0}};
	else if (~in_stream_idx & in_ready)
		encrypt_buf_0 <= {ccm_ctr_flag, nonce_sector_id, nonce_frame_id, nonce_start_slot_idx, nonce_addr_idx, in_stream_idx, {35{1'b0}}, n_inc_0};

/**************************************************************************************************/
//encrypt_buf_1
always @(posedge clk)
	if (kill)
		encrypt_buf_1 <= {WIDTH_KEY{1'b0}};
	else if (in_stream_idx & in_ready)
		encrypt_buf_1 <= {ccm_ctr_flag, nonce_sector_id, nonce_frame_id, nonce_start_slot_idx, nonce_addr_idx, in_stream_idx, {35{1'b0}}, n_inc_1};

/**************************************************************************************************/
//encrypt_en
always @(posedge clk)
	if (kill)
		encrypt_en <= 1'b0;
	else if (in_ready)
		encrypt_en <= 1'b1;
	else 
		encrypt_en <= 1'b0;

/**************************************************************************************************/
//encrypt_ctr_data
assign encrypt_ctr_data = in_stream_idx_r ? (encrypt_buf_1 ^ key_aes) : (encrypt_buf_0 ^ key_aes);

/**************************************************************************************************/





endmodule 