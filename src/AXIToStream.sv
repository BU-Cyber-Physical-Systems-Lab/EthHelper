`timescale 1ns / 1ps
/** @file AXIToStream_orchestrator.sv
 * @brief orchestrator top module Axi to axistream translation
 * @details
 * todo
 */

module AXIToStream #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 32,
    parameter BURST_LEN = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64,
    parameter DEST_WIDTH = 32,
    // reset params
    parameter RESET_AR = 0,
    parameter RESET_AW = 0,
    parameter RESET_R = 0,
    parameter RESET_W = 0,
    parameter RESET_B = 0,
    // how many channels this module supports
    localparam channels = 5,
    //the bit needed to represent this channels in binary
    localparam channels_bits = $clog2(channels),

    /// the ids of the submodules (used in various indexing operations)
    localparam AR_ID = {channels_bits{1'b0}},
    localparam AW_ID = {{channels_bits - 1{1'b0}}, 1'b1},
    localparam R_ID  = {{channels_bits - 2{1'b0}}, 2'b10},
    localparam W_ID  = {{channels_bits - 2{1'b0}}, 2'b11},
    localparam B_ID  = {{channels_bits - 3{1'b0}}, 3'b100},

    ///the one-hot encoding of the ready signal
    localparam NONE_HOT = {channels{1'b0}},  // no channel ready
    localparam AR_HOT = {{channels - 1{1'b0}}, 1'b1},  // AR ready
    localparam AW_HOT = {{channels - 2{1'b0}}, 2'b10},  //AW ready
    localparam R_HOT = {{channels - 3{1'b0}}, 3'b100},  //R ready
    localparam W_HOT = {{channels - 4{1'b0}}, 4'b1000},  //W ready
    localparam B_HOT = {{channels - 5{1'b0}}, 5'b10000}  //B ready

) (
    input  wire                    clk,
    input  wire                    resetn,
    // AXI Slave (input wire) interface, will AXIS a transaction
    input  wire [    ID_WIDTH-1:0] AXIS_awid,
    input  wire [  ADDR_WIDTH-1:0] AXIS_awaddr,
    input  wire [   BURST_LEN-1:0] AXIS_awlen,
    input  wire [             2:0] AXIS_awsize,
    input  wire [             1:0] AXIS_awburst,
    input  wire [  LOCK_WIDTH-1:0] AXIS_awlock,
    input  wire [             3:0] AXIS_awcache,
    input  wire [             2:0] AXIS_awprot,
    input  wire [             3:0] AXIS_awregion,
    input  wire [             3:0] AXIS_awqos,
    input  wire [  USER_WIDTH-1:0] AXIS_awuser,
    input  wire                    AXIS_awvalid,
    output wire                    AXIS_awready,
    input  wire [    ID_WIDTH-1:0] AXIS_wid,
    input  wire [  DATA_WIDTH-1:0] AXIS_wdata,
    input  wire [DATA_WIDTH/8-1:0] AXIS_wstrb,
    input  wire                    AXIS_wlast,
    input  wire [  USER_WIDTH-1:0] AXIS_wuser,
    input  wire                    AXIS_wvalid,
    output wire                    AXIS_wready,
    output wire [    ID_WIDTH-1:0] AXIS_bid,
    output wire [             1:0] AXIS_bresp,
    output wire [  USER_WIDTH-1:0] AXIS_buser,
    output wire                    AXIS_bvalid,
    input  wire                    AXIS_bready,
    input  wire [    ID_WIDTH-1:0] AXIS_arid,
    input  wire [  ADDR_WIDTH-1:0] AXIS_araddr,
    input  wire [   BURST_LEN-1:0] AXIS_arlen,
    input  wire [             2:0] AXIS_arsize,
    input  wire [             1:0] AXIS_arburst,
    input  wire [  LOCK_WIDTH-1:0] AXIS_arlock,
    input  wire [             3:0] AXIS_arcache,
    input  wire [             2:0] AXIS_arprot,
    input  wire [             3:0] AXIS_arregion,
    input  wire [             3:0] AXIS_arqos,
    input  wire [  USER_WIDTH-1:0] AXIS_aruser,
    input  wire                    AXIS_arvalid,
    output wire                    AXIS_arready,
    output wire [    ID_WIDTH-1:0] AXIS_rid,
    output wire [  DATA_WIDTH-1:0] AXIS_rdata,
    output wire [             1:0] AXIS_rresp,
    output wire                    AXIS_rlast,
    output wire [  USER_WIDTH-1:0] AXIS_ruser,
    output wire                    AXIS_rvalid,
    input  wire                    AXIS_rready,
    // AXI master (output wire) Interface, will AXIM the AXISed transaction to destination
    output wire [    ID_WIDTH-1:0] AXIM_awid,
    output wire [  ADDR_WIDTH-1:0] AXIM_awaddr,
    output wire [   BURST_LEN-1:0] AXIM_awlen,
    output wire [             2:0] AXIM_awsize,
    output wire [             1:0] AXIM_awburst,
    output wire [  LOCK_WIDTH-1:0] AXIM_awlock,
    output wire [             3:0] AXIM_awcache,
    output wire [             2:0] AXIM_awprot,
    output wire [             3:0] AXIM_awregion,
    output wire [             3:0] AXIM_awqos,
    output wire [  USER_WIDTH-1:0] AXIM_awuser,
    output wire                    AXIM_awvalid,
    input  wire                    AXIM_awready,
    output wire [    ID_WIDTH-1:0] AXIM_wid,
    output wire [  DATA_WIDTH-1:0] AXIM_wdata,
    output wire [DATA_WIDTH/8-1:0] AXIM_wstrb,
    output wire                    AXIM_wlast,
    output wire [  USER_WIDTH-1:0] AXIM_wuser,
    output wire                    AXIM_wvalid,
    input  wire                    AXIM_wready,
    input  wire [    ID_WIDTH-1:0] AXIM_bid,
    input  wire [             1:0] AXIM_bresp,
    input  wire [  USER_WIDTH-1:0] AXIM_buser,
    input  wire                    AXIM_bvalid,
    output wire                    AXIM_bready,
    output wire [    ID_WIDTH-1:0] AXIM_arid,
    output wire [  ADDR_WIDTH-1:0] AXIM_araddr,
    output wire [   BURST_LEN-1:0] AXIM_arlen,
    output wire [             2:0] AXIM_arsize,
    output wire [             1:0] AXIM_arburst,
    output wire [  LOCK_WIDTH-1:0] AXIM_arlock,
    output wire [             3:0] AXIM_arcache,
    output wire [             2:0] AXIM_arprot,
    output wire [             3:0] AXIM_arregion,
    output wire [             3:0] AXIM_arqos,
    output wire [  USER_WIDTH-1:0] AXIM_aruser,
    output wire                    AXIM_arvalid,
    input  wire                    AXIM_arready,
    input  wire [    ID_WIDTH-1:0] AXIM_rid,
    input  wire [  DATA_WIDTH-1:0] AXIM_rdata,
    input  wire [             1:0] AXIM_rresp,
    input  wire                    AXIM_rlast,
    input  wire [  USER_WIDTH-1:0] AXIM_ruser,
    input  wire                    AXIM_rvalid,
    output wire                    AXIM_rready,
    // AXI stream Master (stream output wire) interface
    output wire [    ID_WIDTH-1:0] stream_tid,
    output wire [  DEST_WIDTH-1:0] stream_tdest,
    output wire [  DATA_WIDTH-1:0] stream_tdata,
    output wire [DATA_WIDTH/8-1:0] stream_tstrb,
    output wire [DATA_WIDTH/8-1:0] stream_tkeep,
    output wire                    stream_tlast,
    output wire [  USER_WIDTH-1:0] stream_tuser,
    output wire                    stream_tvalid,
    input  wire                    stream_tready
);
  //Submodules instantiation
  AXIToStream_Ax #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .ID_WIDTH(ID_WIDTH),
      .BURST_LEN(BURST_LEN),
      .LOCK_WIDTH(LOCK_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .STREAM_TYPE_WIDTH(channels_bits),
      .STREAM_TYPE(AR_ID)
  ) AR (
      .clk(clk),
      .resetn(resets[AR_ID]),
      .ready(ready[AR_ID]),
      .valid(valid[AR_ID]),
      .data(submodule_data[AR_ID]),
      .in_progress(in_progress[AR_ID]),
      .last(stream_tlast),

      //subordinate
      .AXIS_axid(AXIS_arid),
      .AXIS_axaddr(AXIS_araddr),
      .AXIS_axlen(AXIS_arlen),
      .AXIS_axsize(AXIS_arsize),
      .AXIS_axburst(AXIS_arburst),
      .AXIS_axlock(AXIS_arlock),
      .AXIS_axcache(AXIS_arcache),
      .AXIS_axprot(AXIS_arprot),
      .AXIS_axregion(AXIS_arregion),
      .AXIS_axqos(AXIS_arqos),
      .AXIS_axuser(AXIS_aruser),
      .AXIS_axready(AXIS_arready),
      .AXIS_axvalid(AXIS_arvalid),

      //manager
      .AXIM_axid(AXIM_arid),
      .AXIM_axaddr(AXIM_araddr),
      .AXIM_axlen(AXIM_arlen),
      .AXIM_axsize(AXIM_arsize),
      .AXIM_axburst(AXIM_arburst),
      .AXIM_axlock(AXIM_arlock),
      .AXIM_axcache(AXIM_arcache),
      .AXIM_axprot(AXIM_arprot),
      .AXIM_axregion(AXIM_arregion),
      .AXIM_axqos(AXIM_arqos),
      .AXIM_axuser(AXIM_aruser),
      .AXIM_axready(AXIM_arready),
      .AXIM_axvalid(AXIM_arvalid)
  );

  AXIToStream_Ax #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .ID_WIDTH(ID_WIDTH),
      .BURST_LEN(BURST_LEN),
      .LOCK_WIDTH(LOCK_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .STREAM_TYPE_WIDTH(channels_bits),
      .STREAM_TYPE(AW_ID)
  ) AW (
      .clk(clk),
      .resetn(resets[AW_ID]),
      .ready(ready[AW_ID]),
      .valid(valid[AW_ID]),
      .data(submodule_data[AW_ID]),
      .in_progress(in_progress[AW_ID]),
      .last(stream_tlast),

      //subordinate
      .AXIS_axid(AXIS_awid),
      .AXIS_axaddr(AXIS_awaddr),
      .AXIS_axlen(AXIS_awlen),
      .AXIS_axsize(AXIS_awsize),
      .AXIS_axburst(AXIS_awburst),
      .AXIS_axlock(AXIS_awlock),
      .AXIS_axcache(AXIS_awcache),
      .AXIS_axprot(AXIS_awprot),
      .AXIS_axregion(AXIS_awregion),
      .AXIS_axqos(AXIS_awqos),
      .AXIS_axuser(AXIS_awuser),
      .AXIS_axready(AXIS_awready),
      .AXIS_axvalid(AXIS_awvalid),

      //manager
      .AXIM_axid(AXIM_awid),
      .AXIM_axaddr(AXIM_awaddr),
      .AXIM_axlen(AXIM_awlen),
      .AXIM_axsize(AXIM_awsize),
      .AXIM_axburst(AXIM_awburst),
      .AXIM_axlock(AXIM_awlock),
      .AXIM_axcache(AXIM_awcache),
      .AXIM_axprot(AXIM_awprot),
      .AXIM_axregion(AXIM_awregion),
      .AXIM_axqos(AXIM_awqos),
      .AXIM_axuser(AXIM_awuser),
      .AXIM_axready(AXIM_awready),
      .AXIM_axvalid(AXIM_awvalid)
  );

  AXIToStream_B #(
      .DATA_WIDTH(DATA_WIDTH),
      .ID_WIDTH(ID_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .STREAM_TYPE_WIDTH(channels_bits),
      .STREAM_TYPE(B_ID)
  ) B (
      .clk(clk),
      .resetn(resets[B_ID]),
      .ready(ready[B_ID]),
      .valid(valid[B_ID]),
      .data(submodule_data[B_ID]),
      .in_progress(in_progress[B_ID]),
      .last(stream_tlast),

      // AXI master (output wire) Interface, will forward the AXIS transaction to destination
      .AXIM_bid(AXIM_bid),
      .AXIM_bresp(AXIM_bresp),
      .AXIM_buser(AXIM_buser),
      .AXIM_bvalid(AXIM_bvalid),
      .AXIM_bready(AXIM_bready),
      // AXI Slave (input wire) interface
      .AXIS_bid(AXIS_bid),
      .AXIS_bresp(AXIS_bresp),
      .AXIS_buser(AXIS_buser),
      .AXIS_bvalid(AXIS_bvalid),
      .AXIS_bready(AXIS_bready)
  );

  AXIToStream_R #(
      .DATA_WIDTH(DATA_WIDTH),
      .ID_WIDTH(ID_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .STREAM_TYPE_WIDTH(channels_bits),
      .STREAM_TYPE(R_ID)
  ) R (
      .clk(clk),
      .resetn(resets[R_ID]),
      .ready(ready[R_ID]),
      .valid(valid[R_ID]),
      .data(submodule_data[R_ID]),
      .in_progress(in_progress[R_ID]),
      .last(stream_tlast),
      // AXI master (output wire) Interface, will forward the AXIS transaction to destination
      .AXIM_rid(AXIM_rid),
      .AXIM_rdata(AXIM_rdata),
      .AXIM_rresp(AXIM_rresp),
      .AXIM_rlast(AXIM_rlast),
      .AXIM_ruser(AXIM_ruser),
      .AXIM_rvalid(AXIM_rvalid),
      .AXIM_rready(AXIM_rready),
      // AXI Slave (input wire) interface
      .AXIS_rid(AXIS_rid),
      .AXIS_rdata(AXIS_rdata),
      .AXIS_rresp(AXIS_rresp),
      .AXIS_rlast(AXIS_rlast),
      .AXIS_ruser(AXIS_ruser),
      .AXIS_rvalid(AXIS_rvalid),
      .AXIS_rready(AXIS_rready)
  );

  AXIToStream_W #(
      .DATA_WIDTH(DATA_WIDTH),
      .ID_WIDTH(ID_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .STREAM_TYPE_WIDTH(channels_bits),
      .STREAM_TYPE(W_ID),
      .BURST_SIZE(BURST_LEN)
  ) W (
      .clk(clk),
      .resetn(resets[W_ID]),
      .ready(ready[W_ID]),
      .valid(valid[W_ID]),
      .data(submodule_data[W_ID]),
      .in_progress(in_progress[W_ID]),
      .last(stream_tlast),
      // AXI master (output wire) Interface, will forward the AXIS transaction to destination
      .AXIM_wid(AXIM_wid),
      .AXIM_wdata(AXIM_wdata),
      .AXIM_wstrb(AXIM_wstrb),
      .AXIM_wlast(AXIM_wlast),
      .AXIM_wuser(AXIM_wuser),
      .AXIM_wvalid(AXIM_wvalid),
      .AXIM_wready(AXIM_wready),
      // AXI Slave (input wire) interface
      .AXIS_wid(AXIS_wid),
      .AXIS_wdata(AXIS_wdata),
      .AXIS_wstrb(AXIS_wstrb),
      .AXIS_wlast(AXIS_wlast),
      .AXIS_wuser(AXIS_wuser),
      .AXIS_wvalid(AXIS_wvalid),
      .AXIS_wready(AXIS_wready)
  );


  //AXI stream wirings
  assign stream_tid   = 0;
  assign stream_tdest = 0;
  assign stream_tstrb = 0;
  assign stream_tkeep = {DATA_WIDTH / 8{1'b1}};
  assign stream_tuser = 0;

  ///send reset to individual submodules (and keep unwanted submodules in reset)
  wire [channels-1:0] resets;
  assign resets[AR_ID] = resetn && RESET_AR;
  assign resets[AW_ID] = resetn && RESET_AW;
  assign resets[R_ID]  = resetn && RESET_R;
  assign resets[W_ID]  = resetn && RESET_W;
  assign resets[B_ID]  = resetn && RESET_B;

  /// how the top module signals a specific submodule that the transaction can proceed
  wire [channels-1:0] ready;

  /// how the submodules will signal to the top module that they have valid data
  /// (after having detected a handshake between the two original axi
  /// interfaces), or a multi-clock cycle transaction is still in progress (e.g.
  /// R/w).
  wire [channels-1:0] valid, in_progress;
  assign stream_tvalid = |valid;

  /// since everything is relative to last_index we need also the one-hot
  /// encoding for the ready to be relative to last_index
  reg [channels-1:0][channels-1:0] encodings;

  ///finally also the data that we send to the AXI4stream has to be relative to
  ///last_index
  //why is this a 2d array again? was it to have one dimension to index it and
  //the next to have the data
  wire [channels-1:0][DATA_WIDTH-1:0] submodule_data;

  ///to implement round robin we need a register that will cycle between all the
  ///possible channels (when they are valid)
  // this register will hold the id of the last channel that has transmitted
  // data
  reg [channels_bits-1:0] last_index;

  // assign the one-hot encodings to the ready signal, in a round robing fashion
  ///this has to unroll to channels-1 amount regardless if the channels are used
  ///@todo is there a way to do this in a neater way?
  assign ready = (stream_tready && valid[last_index]) ?  encodings[last_index][channels-1:0] :
 ( stream_tready && valid[last_index+1]) ? encodings[last_index+1][channels-1:0] :
 ( stream_tready && valid[last_index+2]) ? encodings[last_index+2][channels-1:0] :
 ( stream_tready && valid[last_index+3]) ? encodings[last_index+3][channels-1:0] :
 ( stream_tready && valid[last_index+4]) ? encodings[last_index+4][channels-1:0] :
 NONE_HOT;//continue for all channels then last else is NONE_HOT;

  /// with the same logic as the ready, we send the matching data
  ///this has to unroll to channels-1 amount regardless if the channels are used
	//@todo is there a way to do this in a neater way?
  assign stream_tdata = (ready[last_index] || in_progress[last_index]) ? submodule_data[last_index][DATA_WIDTH-1:0] :
(ready[last_index+1] || in_progress[last_index+1]) ? submodule_data[last_index+1][DATA_WIDTH-1:0] :
(ready[last_index+2] || in_progress[last_index+2]) ? submodule_data[last_index+2][DATA_WIDTH-1:0] :
(ready[last_index+3] || in_progress[last_index+3]) ? submodule_data[last_index+3][DATA_WIDTH-1:0] :
(ready[last_index+4] || in_progress[last_index+4]) ? submodule_data[last_index+4][DATA_WIDTH-1:0] :
 0; //continue for all channels then last else is 0;

  //have the encoding maps always be refreshed in this always block
  //helps separate somewhat static code with the actual logic
  //*NOTE:* use the IDs to index the encodings.
  always @(posedge clk) begin
    encodings[AR_ID] <= AR_HOT;
    encodings[AW_ID] <= AW_HOT;
    encodings[R_ID]  <= R_HOT;
    encodings[W_ID]  <= W_HOT;
    encodings[B_ID]  <= B_HOT;
  end

  //Here we need to check all channels
  //starting from last_index and accept the first valid channel (meaning that
  //this for should unroll in a cascading if-else for all the entries encoded by
  //the channels bit.)
  integer i;
  always @(posedge clk) begin
    //we do 2^channels_bits iterations to check all the possible positions
    //encoded by the channels_bits, so we can find the first valid channel by
    //leveraging the overflow of last_index

    // @todo check if increment of last_index wraps properly (unused entries
    // encoded by the channels_bits should be skipped)
    for (i = 0; i < 2 ** channels_bits; i++) begin
      if ((last_index + i < channels) && (valid[last_index+i] || in_progress[last_index+i])) begin
        last_index <= i + last_index;
        break;
      end
    end
  end

endmodule
