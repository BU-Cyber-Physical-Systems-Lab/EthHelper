`timescale 1ns / 1ps
/** @file AXIToStream.sv
 * @brief Snoop AXI4 transaction and send a copy of their data from the
 *  AXIStream port.
 * @author Mattia Nicolella
 */

/** @brief Snoop AXI4 transaction and send a copy of their data from the
 *  AXIStream port.
 * @details This module acts as a passtrough between an AXI4 master/slave,
 * while creating an equivalent transaction from the AXIStream master.
 *
 * *NOTE:* This module introduces a ~3 clock delay in each AXI4 transaction.
 */
module AXIToStream #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 32,
    parameter BURST_LEN = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64,
    parameter DEST_WIDTH = 32,
    parameter STREAM_TYPE_WIDTH = 3,
    localparam STREAM_DATA_WIDTH = DATA_WIDTH + STREAM_TYPE_WIDTH + ADDR_WIDTH + (DATA_WIDTH / 8)
) (
    input  wire                    clk,
    input  wire                    resetn,
    // AXI Slave (input wire) interface, will snoop a transaction
    input  wire [    ID_WIDTH-1:0] snoop_awid,
    input  wire [  ADDR_WIDTH-1:0] snoop_awaddr,
    input  wire [   BURST_LEN-1:0] snoop_awlen,
    input  wire [             2:0] snoop_awsize,
    input  wire [             1:0] snoop_awburst,
    input  wire [  LOCK_WIDTH-1:0] snoop_awlock,
    input  wire [             3:0] snoop_awcache,
    input  wire [             2:0] snoop_awprot,
    input  wire [             3:0] snoop_awregion,
    input  wire [             3:0] snoop_awqos,
    input  wire [  USER_WIDTH-1:0] snoop_awuser,
    input  wire                    snoop_awvalid,
    output wire                    snoop_awready,
    input  wire [    ID_WIDTH-1:0] snoop_wid,
    input  wire [  DATA_WIDTH-1:0] snoop_wdata,
    input  wire [DATA_WIDTH/8-1:0] snoop_wstrb,
    input  wire                    snoop_wlast,
    input  wire [  USER_WIDTH-1:0] snoop_wuser,
    input  wire                    snoop_wvalid,
    output wire                    snoop_wready,
    output wire [    ID_WIDTH-1:0] snoop_bid,
    output wire [             1:0] snoop_bresp,
    output wire [  USER_WIDTH-1:0] snoop_buser,
    output wire                    snoop_bvalid,
    input  wire                    snoop_bready,
    input  wire [    ID_WIDTH-1:0] snoop_arid,
    input  wire [  ADDR_WIDTH-1:0] snoop_araddr,
    input  wire [   BURST_LEN-1:0] snoop_arlen,
    input  wire [             2:0] snoop_arsize,
    input  wire [             1:0] snoop_arburst,
    input  wire [  LOCK_WIDTH-1:0] snoop_arlock,
    input  wire [             3:0] snoop_arcache,
    input  wire [             2:0] snoop_arprot,
    input  wire [             3:0] snoop_arregion,
    input  wire [             3:0] snoop_arqos,
    input  wire [  USER_WIDTH-1:0] snoop_aruser,
    input  wire                    snoop_arvalid,
    output wire                    snoop_arready,
    output wire [    ID_WIDTH-1:0] snoop_rid,
    output wire [  DATA_WIDTH-1:0] snoop_rdata,
    output wire [             1:0] snoop_rresp,
    output wire                    snoop_rlast,
    output wire [  USER_WIDTH-1:0] snoop_ruser,
    output wire                    snoop_rvalid,
    input  wire                    snoop_rready,
    // AXI master (output wire) Interface, will forward the snooped transaction to destination
    output wire [    ID_WIDTH-1:0] forward_awid,
    output wire [  ADDR_WIDTH-1:0] forward_awaddr,
    output wire [   BURST_LEN-1:0] forward_awlen,
    output wire [             2:0] forward_awsize,
    output wire [             1:0] forward_awburst,
    output wire [  LOCK_WIDTH-1:0] forward_awlock,
    output wire [             3:0] forward_awcache,
    output wire [             2:0] forward_awprot,
    output wire [             3:0] forward_awregion,
    output wire [             3:0] forward_awqos,
    output wire [  USER_WIDTH-1:0] forward_awuser,
    output wire                    forward_awvalid,
    input  wire                    forward_awready,
    output wire [    ID_WIDTH-1:0] forward_wid,
    output wire [  DATA_WIDTH-1:0] forward_wdata,
    output wire [DATA_WIDTH/8-1:0] forward_wstrb,
    output wire                    forward_wlast,
    output wire [  USER_WIDTH-1:0] forward_wuser,
    output wire                    forward_wvalid,
    input  wire                    forward_wready,
    input  wire [    ID_WIDTH-1:0] forward_bid,
    input  wire [             1:0] forward_bresp,
    input  wire [  USER_WIDTH-1:0] forward_buser,
    input  wire                    forward_bvalid,
    output wire                    forward_bready,
    output wire [    ID_WIDTH-1:0] forward_arid,
    output wire [  ADDR_WIDTH-1:0] forward_araddr,
    output wire [   BURST_LEN-1:0] forward_arlen,
    output wire [             2:0] forward_arsize,
    output wire [             1:0] forward_arburst,
    output wire [  LOCK_WIDTH-1:0] forward_arlock,
    output wire [             3:0] forward_arcache,
    output wire [             2:0] forward_arprot,
    output wire [             3:0] forward_arregion,
    output wire [             3:0] forward_arqos,
    output wire [  USER_WIDTH-1:0] forward_aruser,
    output wire                    forward_arvalid,
    input  wire                    forward_arready,
    input  wire [    ID_WIDTH-1:0] forward_rid,
    input  wire [  DATA_WIDTH-1:0] forward_rdata,
    input  wire [             1:0] forward_rresp,
    input  wire                    forward_rlast,
    input  wire [  USER_WIDTH-1:0] forward_ruser,
    input  wire                    forward_rvalid,
    output wire                    forward_rready,
    // AXI stream Master (stream output wire) interface
    output wire [    ID_WIDTH-1:0] stream_tid,
    output wire [  DEST_WIDTH-1:0] stream_tdest,
    output wire [  DATA_WIDTH-1:0] stream_tdata,
    output wire [DATA_WIDTH/8-1:0] stream_tstrb,
    output wire [DATA_WIDTH/8-1:0] stream_tkeep,
    output wire                    stream_tlast,
    output wire [  USER_WIDTH-1:0] stream_tuser,
    output wire                    stream_tvalid,
    input  wire                    stream_tready,

    //debug pins
    output wire DBG_can_forward,
    output wire [1-1:0] DBG_stream_state,
    output wire [STREAM_TYPE_WIDTH-1:0] DBG_stream_type
);

  /** The type of the ongoing stream (matches the AXI4 channels).
	 * *NOTE*: Each stream transaction is "tagged" with ::_stream_type so we need
	 * two bursts to send the read and write data. Additionally, the write data
	 * contains the original AXI4 strobe.
	 */
  enum reg [STREAM_TYPE_WIDTH-1:0] {
    NONE = 0,
    AR,
    R,
    AW,
    W,
    B
  } _stream_type;

  /** This register is used to make sure that we don´t starve neither read or write transactions,
   * by remembering which transaction was streamed during last contentions.
	 */
  enum reg {
    AR,  // contention, do AR
    AW   // contention, do AW
  } _address_rr;

  /** Data to be streamed in to the AXIStream slave.
   * In case of RDATA and WDATA streams we need to compose the metadata and
   * save the contents of the data line since we do not have any spare bits
   * in stream_tdata, so we use a tag team of two registers to send the output
   * save the one we will send next.
  */
  reg [DATA_WIDTH-1:0] _stream_data, _stream_data_next;

  /// Since we are deferring the data transaction we need to save its strobe to send them together
  reg [DATA_WIDTH/8-1:0] _stream_strobe;

  /**@brief keep track how how long is the burst,
   * reminder: burst len is defined as 1+Ax_LEN, and for R/W transaction
   */
  reg [BURST_LEN+1-1:0] _burst_len;


  /** To have meaningful transactions and not lose data we stall the AXI4 slave
	 * ready signal until the current AXIStream transaction has completed and
	 * the AXIStream is ready to process another transaction.
	 * We also ahve to enforce the AXI4 protocol dependencies for the different transactions
	 */
  /** We accept an AR transaction if:
	 * - stream module is ready (`stream_tready`)
	 * - we are not streaming already another transaction (`_stream_type==NONE`)
	 * - there is no conflict with a write transaction (`!snoop_arvalid`)
	 * - there was a conflict with a write transaction and we stalled the read transaction (`_address_rr == AW`)
	 */
  wire can_forwardAR;
  assign can_forwardAR = ~resetn || (stream_tready && _stream_type == NONE && (!snoop_awvalid || _address_rr == AW));
  /** We accept an AW transaction if:
	 * - stream module is ready (`stream_tready`)
	 * - we are not streaming already another transaction (`_stream_type==NONE`)
	 * - there is no conflict with a write transaction (`!snoop_arvalid`)
	 * - there was a conflict with a write transaction and we stalled the read transaction (`_address_rr == AW`)
	 */
  wire can_forwardAW;
  assign can_forwardAW = ~resetn || (stream_tready && _stream_type == NONE && (!snoop_arvalid || _address_rr == AR));
  ///For R/W  we depend on the completion of the previous AR/AW and there can be multiple R/W bursts in the same transaction
  wire can_forwardR, can_forwardW;
  assign can_forwardR = ~resetn || (stream_tready && (_stream_type == AR || _stream_type == R));
  assign can_forwardW = ~resetn || (stream_tready && (_stream_type == AW || _stream_type == W));
  /// For B transaction we only depend on the completion of the previous write transaction
  wire can_forwardB;
  assign can_forwardB = ~resetn || (stream_tready && _stream_type == W);
  assign DBG_can_forwardAR = can_forwardAR;
  assign DBG_can_forwardR = can_forwardR;
  assign DBG_can_forwardAW = can_forwardAW;
  assign DBG_can_forwardW = can_forwardW;
  assign DBG_can_forwardB = can_forwardB;


  // connect the master to the slave port, so we can forward downstream the signals we received.
  assign forward_awid = snoop_awid;
  assign forward_awaddr = snoop_awaddr;
  assign forward_awlen = snoop_awlen;
  assign forward_awsize = snoop_awsize;
  assign forward_awburst = snoop_awburst;
  assign forward_awlock = snoop_awlock;
  assign forawrd_awcache = snoop_awcache;
  assign forward_awprot = snoop_awprot;
  assign forward_awregion = snoop_awregion;
  assign forward_awqos = snoop_awqos;
  assign forward_awuser = snoop_awuser;
  assign forward_awvalid = snoop_awvalid && can_forwardAW;
  assign snoop_awready = forward_awready && can_forwardAW;

  assign forward_wid = snoop_wid;
  assign forward_wdata = snoop_wdata;
  assign forward_wstrb = snoop_wstrb;
  assign forward_wlast = snoop_wlast;
  assign forward_wuser = snoop_wuser;
  assign forward_wvalid = snoop_wvalid && can_forwardW;
  assign snoop_wready = forward_wready && can_forwardW;

  assign snoop_bid = forward_bid;
  assign snoop_bresp = forward_bresp;
  assign snoop_buser = forward_buser;
  assign forward_bready = snoop_bready && can_forwardB;
  assign snoop_bvalid = forward_bvalid && can_forwardB;

  assign forward_arid = snoop_arid;
  assign forward_araddr = snoop_araddr;
  assign forward_arlen = snoop_arlen;
  assign forward_arsize = snoop_arsize;
  assign forward_arburst = snoop_arburst;
  assign forward_arlock = snoop_arlock;
  assign forward_arcache = snoop_arcache;
  assign forward_arprot = snoop_arprot;
  assign forward_arregion = snoop_arregion;
  assign forward_arqos = snoop_arqos;
  assign forward_aruser = snoop_aruser;
  assign forward_arvalid = snoop_arvalid && can_forwardAR;
  assign snoop_arready = forward_arready && can_forwardAR;

  assign snoop_rid = forward_rid;
  assign snoop_rdata = forward_rdata;
  assign snoop_rresp = forward_rresp;
  assign snoop_rlast = forward_rlast;
  assign snoop_ruser = forward_ruser;
  assign snoop_rvalid = forward_rvalid && can_forwardR;
  assign forward_rready = snoop_rready && can_forwardR;

  //state machine handling
  // we are using the valid and ready wires that take the streaming module state into account
  always @(posedge clk) begin
    if (~resetn) begin
      _stream_type <= NONE;
      _burst_len   <= 0;
      _address_rr  <= AR;
      // Ax transaction
    end else if ((forward_arvalid && snoop_arready) || (forward_awvalid && snoop_awready)) begin
      _address_rr  <= (forward_arvalid && snoop_arready) ? AR : AW;
      _stream_type <= (forward_arvalid && snoop_arready) ? AR : AW;
      // arlen value + 1st burst transaction (manual) + metadata
      _burst_len   <= ((forward_arvalid && snoop_arready) ? snoop_arlen : snoop_awlen) + 1 + 1;
      // R/W transaction
    end else if ((forward_rready && snoop_rvalid) || (forward_wready && snoop_wvalid)) begin
      _stream_type <= (forward_rready && snoop_rvalid) ? R : W;
      _burst_len   <= _burst_len - 1;
      _address_rr  <= _address_rr;
      // B transaction
    end else if (forward_bvalid && snoop_bready) begin
      _stream_type <= B;
      _burst_len   <= 0;
      _address_rr  <= _address_rr;
    end else if (burst_len == 0) begin
      _stream_type <= (_stream_type == R || _stream_type == B) ? NONE : _stream_type;
      _burst_len   <= 0;
    end else begin
      _stream_type <= _stream_type;
      _burst_len   <= _burst_len;
      _address_rr  <= _address_rr;
    end
  end


  //@bug: THIS HAS TO BE TOTALLY REWORKED ACCORDING TO THE STATE MACHINE ABOVE
	//build the stream data register
  always @(posedge clk) begin
    // reset
    if (~resetn) begin
      _stream_state <= IDLE;
      _stream_strobe <= 0;
      _stream_data <= 0;
      _stream_data_next <= 0;
      _stream_type <= NONE;
      _burst_len <= 0;
      // transaction on the AR channel, pack the address with metadata and stream it
    end else if (snoop_arvalid && forward_arready && stream_tready) begin
      _stream_data <= {AR, {(DATA_WIDTH - STREAM_TYPE_WIDTH - ADDR_WIDTH) {1'b0}}, snoop_araddr};
      _stream_data_next <= 0;
      _stream_state <= STREAM;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}},
        {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7 - ADDR_WIDTH) / 8{1'b0}},
        {ADDR_WIDTH / 8{1'b1}}
      };
      _burst_len <= 1;
      // transaction on the AW channel, pack the address with metadata and stream it
    end else if (snoop_awvalid && forward_awready && stream_tready) begin
      _stream_data <= {AW, {DATA_WIDTH - STREAM_TYPE_WIDTH - ADDR_WIDTH{1'b0}}, snoop_awaddr};
      _stream_state <= ADDR;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}},
        {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7 - ADDR_WIDTH) / 8{1'b0}},
        {ADDR_WIDTH / 8{1'b1}}
      };
      // transaction on the B channel, pack resp with metadata and stream
    end else if (snoop_bready && forward_bvalid && stream_tready) begin
      _stream_data <= {B, {DATA_WIDTH - STREAM_TYPE_WIDTH - 2{1'b0}}, snoop_bresp};
      _stream_state <= RESP;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}},
        {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7 - 2) / 8{1'b0}},
        8'b1
      };
      // 1st burst element of a transaction in the R channel, send the metadata and store the data
    end else if (forward_rvalid && snoop_rready && stream_tready && _stream_state == IDLE) begin
      _stream_data <= {R, {DATA_WIDTH - STREAM_TYPE_WIDTH{1'b0}}};
      _stream_state <= RMETADATA;
      _stream_data_next <= forward_rdata;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}}, {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7) / 8{1'b0}}
      };
      // R transaction, from 2nd element of the burst
      // send the previous data burst and store the next
    end else if (forward_rvalid && snoop_rready && stream_tready && (_stream_state == RMETADATA || _stream_state == RBURST)) begin
      // the next state depends on forward_rlast
      _stream_state <= (forward_rlast) ? RLAST : RBURST;
      _stream_data <= _stream_data_next;
      _stream_data_next <= forward_rdata;
      _stream_strobe <= {DATA_WIDTH{1'b1}};
      // last element of a burst transaction on the R channel
    end else if (snoop_rready && stream_tready && _stream_state == RLAST && forward_rvalid && forward_rlast) begin
      _stream_data <= _stream_data_next;
      _stream_data_next <= {DATA_WIDTH - 1{1'b0}};
      _stream_strobe <= {DATA_WIDTH / 8{1'b1}};
      _stream_state <= STALL;
      // 1st burst element of a transaction in the W channel, send the metadata and store the data
    end else if (snoop_wvalid && forward_wready && stream_tready && _stream_state == IDLE) begin
      _stream_data <= {W, {DATA_WIDTH - (DATA_WIDTH / 8) {1'b0}}, snoop_wstrb};
      _stream_data_next <= snoop_wdata;
      _stream_state <= WMETADATA;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}},
        {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7 - DATA_WIDTH / 8) / 8{1'b0}},
        {DATA_WIDTH / 8{1'b1}}
      };
      // W transaction, from 2nd element of the burst
      // send the previous data burst and store the next
    end else if (forward_wready && stream_tready && _stream_state == WMETADATA && snoop_wvalid) begin
      // the next state depends on forward_rlast
      _stream_state <= (snoop_wlast) ? WLAST : WBURST;
      _stream_data_next <= snoop_wdata;
      _stream_data <= _stream_data_next;
      _stream_strobe <= {DATA_WIDTH / 8{1'b1}};
      // last element of a burst transaction on the W channel
    end else if (stream_tready && _stream_state == WLAST && snoop_wvalid && forward_wready) begin
      _stream_data <= _stream_data_next;
      _stream_data_next <= {DATA_WIDTH - 1{1'b0}};
      _stream_strobe <= {DATA_WIDTH / 8{1'b1}};
      _stream_state <= STALL;
      // we are completing a single burst transaction, so we will go idle next clock
    end else if (_stream_state == ADDR || _stream_state == RESP || _stream_state == STALL) begin
      _stream_state <= IDLE;
      _stream_data <= 0;
      _stream_data_next <= 0;
      _stream_strobe <= 0;
      // we are waiting for one interface
    end else begin
      _stream_state <= _stream_state;
      _stream_data <= _stream_data;
      _stream_data_next <= _stream_data_next;
      _stream_strobe <= _stream_strobe;
    end
  end

  // check wether the last piece of data was received
  always @(posedge clk) begin
    if (~resetn) begin
      _stream_received <= 1;  // there's no data to send at reset
    end else if (stream_tvalid && stream_tready && _stream_state != IDLE) begin
      _stream_received <= 1;
    end else begin
      _stream_received <= 0;
    end
  end


  // connect remaining AXI stream cables
  assign stream_tvalid = !_stream_received;
  assign stream_tdata = _stream_data;
  assign stream_tstrb = _stream_strobe;
  assign stream_tkeep = {DATA_WIDTH / 8{1'b1}};
  assign stream_tlast = (_stream_state == ADDR || _stream_state == RESP || _stream_state == STALL);
  assign stream_tid = 0;
  assign stream_tdest = 0;
  assign stream_tuser = 0;
endmodule
