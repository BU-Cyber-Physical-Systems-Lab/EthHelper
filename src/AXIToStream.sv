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
    input wire                    clk,
    input wire                      resetn,
    // AXI Slave (input wire) interface, will snoop a transaction
    input wire       [    ID_WIDTH-1:0] snoop_awid,
    input wire       [  ADDR_WIDTH-1:0] snoop_awaddr,
    input wire       [   BURST_LEN-1:0] snoop_awlen,
    input wire       [             2:0] snoop_awsize,
    input wire       [             1:0] snoop_awburst,
    input wire       [  LOCK_WIDTH-1:0] snoop_awlock,
    input wire       [             3:0] snoop_awcache,
    input wire       [             2:0] snoop_awprot,
    input wire       [             3:0] snoop_awregion,
    input wire       [             3:0] snoop_awqos,
    input wire       [  USER_WIDTH-1:0] snoop_awuser,
    input wire                          snoop_awvalid,
    output wire                         snoop_awready,
    input wire       [    ID_WIDTH-1:0] snoop_wid,
    input wire       [  DATA_WIDTH-1:0] snoop_wdata,
    input wire       [DATA_WIDTH/8-1:0] snoop_wstrb,
    input wire                          snoop_wlast,
    input wire       [  USER_WIDTH-1:0] snoop_wuser,
    input wire                          snoop_wvalid,
    output wire                         snoop_wready,
    output wire      [    ID_WIDTH-1:0] snoop_bid,
    output wire      [             1:0] snoop_bresp,
    output wire      [  USER_WIDTH-1:0] snoop_buser,
    output wire                         snoop_bvalid,
    input wire                          snoop_bready,
    input wire       [    ID_WIDTH-1:0] snoop_arid,
    input wire       [  ADDR_WIDTH-1:0] snoop_araddr,
    input wire       [   BURST_LEN-1:0] snoop_arlen,
    input wire       [             2:0] snoop_arsize,
    input wire       [             1:0] snoop_arburst,
    input wire       [  LOCK_WIDTH-1:0] snoop_arlock,
    input wire       [             3:0] snoop_arcache,
    input wire       [             2:0] snoop_arprot,
    input wire       [             3:0] snoop_arregion,
    input wire       [             3:0] snoop_arqos,
    input wire       [  USER_WIDTH-1:0] snoop_aruser,
    input wire                          snoop_arvalid,
    output wire                         snoop_arready,
    output wire      [    ID_WIDTH-1:0] snoop_rid,
    output wire      [  DATA_WIDTH-1:0] snoop_rdata,
    output wire      [             1:0] snoop_rresp,
    output wire                         snoop_rlast,
    output wire      [  USER_WIDTH-1:0] snoop_ruser,
    output wire                         snoop_rvalid,
    input wire                          snoop_rready,
    // AXI master (output wire) Interface, will forward the snooped transaction to destination
    output wire       [    ID_WIDTH-1:0] forward_awid,
    output wire       [  ADDR_WIDTH-1:0] forward_awaddr,
    output wire       [   BURST_LEN-1:0] forward_awlen,
    output wire       [             2:0] forward_awsize,
    output wire       [             1:0] forward_awburst,
    output wire       [  LOCK_WIDTH-1:0] forward_awlock,
    output wire       [             3:0] forward_awcache,
    output wire       [             2:0] forward_awprot,
    output wire       [             3:0] forward_awregion,
    output wire       [             3:0] forward_awqos,
    output wire       [  USER_WIDTH-1:0] forward_awuser,
    output wire                          forward_awvalid,
    input wire                         forward_awready,
    output wire       [    ID_WIDTH-1:0] forward_wid,
    output wire       [  DATA_WIDTH-1:0] forward_wdata,
    output wire       [DATA_WIDTH/8-1:0] forward_wstrb,
    output wire                          forward_wlast,
    output wire       [  USER_WIDTH-1:0] forward_wuser,
    output wire                          forward_wvalid,
    input wire                         forward_wready,
    input wire      [    ID_WIDTH-1:0] forward_bid,
    input wire      [             1:0] forward_bresp,
    input wire      [  USER_WIDTH-1:0] forward_buser,
    input wire                         forward_bvalid,
    output wire                          forward_bready,
    output wire       [    ID_WIDTH-1:0] forward_arid,
    output wire       [  ADDR_WIDTH-1:0] forward_araddr,
    output wire       [   BURST_LEN-1:0] forward_arlen,
    output wire       [             2:0] forward_arsize,
    output wire       [             1:0] forward_arburst,
    output wire       [  LOCK_WIDTH-1:0] forward_arlock,
    output wire       [             3:0] forward_arcache,
    output wire       [             2:0] forward_arprot,
    output wire       [             3:0] forward_arregion,
    output wire       [             3:0] forward_arqos,
    output wire       [  USER_WIDTH-1:0] forward_aruser,
    output wire                          forward_arvalid,
    input wire                         forward_arready,
    input wire      [    ID_WIDTH-1:0] forward_rid,
    input wire      [  DATA_WIDTH-1:0] forward_rdata,
    input wire      [             1:0] forward_rresp,
    input wire                         forward_rlast,
    input wire      [  USER_WIDTH-1:0] forward_ruser,
    input wire                         forward_rvalid,
    output wire                          forward_rready,
    // AXI stream Master (stream output wire) interface
    output wire       [    ID_WIDTH-1:0] stream_tid,
    output wire       [  DEST_WIDTH-1:0] stream_tdest,
    output wire       [  DATA_WIDTH-1:0] stream_tdata,
    output wire       [DATA_WIDTH/8-1:0] stream_tstrb,
    output wire       [DATA_WIDTH/8-1:0] stream_tkeep,
    output wire                          stream_tlast,
    output wire       [  USER_WIDTH-1:0] stream_tuser,
    output wire                          stream_tvalid,
    input wire                         stream_tready
);

 /// The type of the ongoing stream (matches the AXI4 channels).
  typedef enum {
    AR,
    R,
    AW,
    W,
    B
  } _stream_type;

  /// Data to be streamed in to the AXIStream slave.
  reg [DATA_WIDTH-1:0] _stream_data;

  /** State of the module.
	 * *NOTE*: Each stream transaction is "tagged" with ::_stream_type so we need
	 * two bursts to send the read and write data. Additionally, the write data
	 * contains the original AXI4 strobe.
	 */
  enum reg [3:0] {
    IDLE = 0,
    ADDR,  // streaming an address (AW / AR)
    RESP,  // streaming a response ( B )
    WDATA1,  // streaming W strobe and transaction type
    WDATA2,  // streaming W data
    RDATA1,  // streaming transaction type for R
    RDATA2  // streaming R data
  } _stream_state;

  /** To have meaningful transactions and not lose data we stall the AXI4 slave
	 * ready signal until the current AXIStream transaction has completed and
	 * the AXIStream is ready to process another transaction.
	 */
  wire can_stream;
  assign can_stream = stream_tready & (_stream_state == IDLE);
  reg [DATA_WIDTH/8-1:0] _stream_strobe;

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
  assign forward_awvalid = snoop_awvalid;
  assign snoop_awready = forward_awready & can_stream;

  assign forward_wid = snoop_wid;
  assign forward_wdata = snoop_wdata;
  assign forward_wstrb = snoop_wstrb;
  assign forward_wlast = snoop_wlast;
  assign forward_wuser = snoop_wuser;
  assign forward_wvalid = snoop_wvalid;
  assign snoop_wready = forward_wready & can_stream;

  assign snoop_bid = forward_bid;
  assign snoop_bresp = forward_bresp;
  assign snoop_buser = forward_buser;
  assign forward_bready = snoop_bready;
  assign snoop_bvalid = forward_bvalid & can_stream;

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
  assign forward_arvalid = snoop_arvalid;
  assign snoop_arready = forward_arready & can_stream;

  assign snoop_rid = forward_rid;
  assign snoop_rdata = forward_rdata;
  assign snoop_rresp = forward_rresp;
  assign snoop_rlast = forward_rlast;
  assign snoop_ruser = forward_ruser;
  assign snoop_rvalid = forward_rvalid & can_stream;
  assign forward_rready = snoop_rready;

  //build the stream data register
  always @(posedge clk) begin
    if (~resetn) begin
      _stream_state  <= IDLE;
      _stream_strobe <= {DATA_WIDTH / 8{1'b0}};
      _stream_data   <= {DATA_WIDTH{1'b0}};
    end else if (snoop_arvalid & forward_arready & can_stream) begin
      _stream_data <= {AR, {(DATA_WIDTH - STREAM_TYPE_WIDTH - ADDR_WIDTH) {1'b0}}, snoop_araddr};
      _stream_state <= ADDR;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}},
        {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7 - ADDR_WIDTH) / 8{1'b0}},
        {ADDR_WIDTH / 8{1'b1}}
      };
    end else if (snoop_awvalid & forward_awready & can_stream) begin
      _stream_data <= {AW, {DATA_WIDTH - STREAM_TYPE_WIDTH - ADDR_WIDTH{1'b0}}, snoop_awaddr};
      _stream_state <= ADDR;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}},
        {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7 - ADDR_WIDTH) / 8{1'b0}},
        {ADDR_WIDTH / 8{1'b1}}
      };
    end else if (snoop_bready & forward_bvalid & can_stream) begin
      _stream_data <= {B, {DATA_WIDTH - STREAM_TYPE_WIDTH - 2{1'b0}}, snoop_bresp};
      _stream_state <= RESP;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}},
        {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7 - 2) / 8{1'b0}},
        8'b1
      };
    end else if (snoop_rvalid & forward_rready & can_stream) begin
      _stream_data <= {R, {DATA_WIDTH - STREAM_TYPE_WIDTH{1'b0}}};
      _stream_state <= RDATA1;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}}, {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7) / 8{1'b0}}
      };
    end else if (stream_tready & _stream_state == RDATA1) begin
      _stream_state  <= RDATA2;
      _stream_data   <= snoop_rdata;
      _stream_strobe <= {DATA_WIDTH{1'b1}};
    end else if (snoop_rvalid & forward_rready & can_stream) begin
      _stream_data <= {W, {DATA_WIDTH - (DATA_WIDTH / 8) {1'b0}}, snoop_wstrb};
      _stream_state <= WDATA1;
      _stream_strobe <= {
        {(STREAM_TYPE_WIDTH + 7) / 8{1'b1}},
        {(DATA_WIDTH - STREAM_TYPE_WIDTH + 7 - DATA_WIDTH / 8) / 8{1'b0}},
        {DATA_WIDTH / 8{1'b1}}
      };
    end else if (stream_tready & _stream_state == WDATA1) begin
      _stream_state  <= WDATA2;
      _stream_data   <= snoop_wdata;
      _stream_strobe <= {DATA_WIDTH{1'b1}};
    end else if (_stream_state != IDLE & _stream_state != RDATA1 & _stream_state != WDATA1) begin
      _stream_state  <= IDLE;
      _stream_data   <= 0;
      _stream_strobe <= 0;
    end else begin
      _stream_state  <= _stream_state;
      _stream_data   <= _stream_data;
      _stream_strobe <= _stream_strobe;
    end
  end

  // connect remaining AXI stream cables
  assign stream_tvalid = _stream_state != IDLE;
  assign stream_tdata = _stream_data;
  assign stream_tstrb = _stream_strobe;
  assign stream_tkeep = {DATA_WIDTH / 8{1'b1}};
  assign stream_tlast = (_stream_state != WDATA1 & _stream_state != RDATA1 & _stream_state != IDLE);
  assign stream_tid = 0;
  assign stream_tdest = 0;
  assign stream_tuser = 0;
endmodule
