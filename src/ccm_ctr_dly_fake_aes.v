/**************************************************************************************************
 *                                                                                                *
 *  File Name:     ccm_ctr_dly_fake_aes.v                                                         *
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
module ccm_ctr_dly_fake_aes (
	clk,
	kill,
	key_aes,
	ccm_ctr_nonce,
	ccm_ctr_flag,
	input_en_buf,
	
	encrypt_data,
	encrypt_en
	);

/**************************************************************************************************
*        PARAMETERS
 **************************************************************************************************/
 parameter  T_DLY = 10;
 parameter  WIDTH_NONCE = 100;
 parameter  WIDTH_FLAG = 8;
 parameter  WIDTH_COUNT = 20;

localparam  WIDTH_KEY = WIDTH_NONCE + WIDTH_FLAG + WIDTH_COUNT;
localparam  T_DLY_WIDTH = $clog2(T_DLY);

/**************************************************************************************************
*        I/O PORTS
 **************************************************************************************************/
input				clk;
input				kill;
input	[WIDTH_KEY-1:0]		key_aes;
input	[WIDTH_NONCE-1:0]	ccm_ctr_nonce;
input	[WIDTH_FLAG-1:0]	ccm_ctr_flag;
input				input_en_buf;

output	[WIDTH_KEY-1:0]		encrypt_data;
output	reg			encrypt_en;

/**************************************************************************************************
 *      LOCAL WIRES, REGS                                                                         *
 **************************************************************************************************/
reg				input_en_buf_r;
reg	[T_DLY_WIDTH-1:0]	count_dly;
reg	[WIDTH_COUNT-1:0]	encrypt_ctr_buf;
reg	[WIDTH_KEY-1:0]		encrypt_buf;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
//encrypt_ctr_buf
always @(posedge clk)
	if (kill)
		encrypt_ctr_buf <= {WIDTH_COUNT{1'b0}};
	else if (input_en_buf)
		encrypt_ctr_buf <= encrypt_ctr_buf + {{WIDTH_COUNT-1{1'b0}}, 1'b1};

/**************************************************************************************************/
//encrypt_buf
always @(posedge clk)
	if (kill)
		encrypt_buf <= {WIDTH_KEY{1'b0}};
	else if (~input_en_buf)
		encrypt_buf <= {ccm_ctr_flag, ccm_ctr_nonce, encrypt_ctr_buf};


/**************************************************************************************************/
//count_dly
always @(posedge clk)
	if (kill)
		count_dly <= {T_DLY_WIDTH{1'b0}};
	else if (input_en_buf_r)
		count_dly <= count_dly + {{T_DLY_WIDTH-1{1'b0}}, 1'b1};
	else
		count_dly <= {T_DLY_WIDTH{1'b0}};

/**************************************************************************************************/
//input_en_buf_r
always @(posedge clk)
	if (kill)
		input_en_buf_r <= 1'b0;
	else if (input_en_buf)
		input_en_buf_r <= 1'b1;
	else if (encrypt_en)
		input_en_buf_r <= 1'b0;
	

/**************************************************************************************************/
//encrypt_en
always @(posedge clk)
	if (kill)
		encrypt_en <= 1'b0;
	else if (count_dly == T_DLY-1)
		encrypt_en <= 1'b1;
	else 
		encrypt_en <= 1'b0;

/**************************************************************************************************/
//encrypt_data
assign encrypt_data = (count_dly == T_DLY) ? (encrypt_buf ^ key_aes) : {WIDTH_KEY{1'b0}};

/**************************************************************************************************/


endmodule
