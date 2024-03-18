`timescale 1ns / 1ps
/** @file AXIToStream_B.sv
 * @brief Snoop AXI4 B transaction and send a copy of their data from the
 *  AXIStream port.
 * @author Mattia Nicolella
 */

/** @brief Snoop AXI4 B transaction and send a copy of their data from the
 *  AXIStream port.
 * @details This module acts as a passtrough between an AXI4 master/slave,
 * while creating an equivalent transaction from the AXIStream master.
 */
module AXIToStream_B #(
    parameter DATA_WIDTH = 128,
    parameter ID_WIDTH = 32,
    parameter USER_WIDTH = 64,
    parameter STREAM_TYPE = 3'b100,
    parameter STREAM_TYPE_WIDTH = 3
) (
    //module inputs pins
    //unused input, but it is necessary to keep the same interface as the other modules
    input  wire                  clk,
    //negative edge synchronous reset, active low, synchronous to the clk
    input  wire                  resetn,
    // when this ready is high we can start the transaction, otherwise we have to wait
    input  wire                  ready,
    //module output pins
    // high when this submodule has valid data to be streamed
    output wire                  valid,
    // high when this submodule is streaming data (to block the other submodules from streaming data at the same time)
    output wire                  in_progress,
    // high when this submodule is the last piece of burst (always in this case)
    output wire                  last,
    // the data to be streamed
    output wire [DATA_WIDTH-1:0] data,
    // AXI Slave (input wire) interface, will snoop a transaction
    output  wire [  ID_WIDTH-1:0] AXIS_bid,
    output  wire [           1:0] AXIS_bresp,
    output  wire [USER_WIDTH-1:0] AXIS_buser,
    output  wire                  AXIS_bvalid,
    input wire                  AXIS_bready,
    // AXI master (output wire) Interface, will forward the snooped transaction to destination
    input wire [  ID_WIDTH-1:0] AXIM_bid,
    input wire [           1:0] AXIM_bresp,
    input wire [USER_WIDTH-1:0] AXIM_buser,
    input wire                  AXIM_bvalid,
    output  wire                  AXIM_bready
);
  assign AXIS_bid = AXIM_bid;
  assign AXIS_bresp = AXIM_bresp;
  assign AXIS_buser = AXIM_buser;
  // mask the handshake of the full AXI interfaces to start the transaction only when we are ready to stream the output
  // or when we are in reset state
  assign AXIS_bvalid = AXIM_bvalid && (~resetn || ready);
  assign AXIM_bready = AXIS_bready && (~resetn || ready);
  //out data is valid only when there is a handshake and we are not in reset state
  assign valid = resetn && AXIM_bvalid && AXIS_bready;
  // these transaction need only one clock cycle to be completed, so we are in progress only when the input is valid
  assign in_progress = valid;
  assign last = ready && valid;
  // the output data is composed as follows
  assign data = {
    STREAM_TYPE,
    AXIM_bid,
    {DATA_WIDTH - STREAM_TYPE_WIDTH - ID_WIDTH - 2{1'b0}},
    AXIM_bresp
  };
endmodule
