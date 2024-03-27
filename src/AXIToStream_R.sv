`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02/20/2024 04:36:04 PM
// Design Name:
// Module Name: AXIToStream_R
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module AXIToStream_R #(
    parameter DATA_WIDTH = 128,
    parameter ID_WIDTH = 32,
    parameter USER_WIDTH = 64,
    parameter STREAM_TYPE = 3'b010,
    parameter STREAM_TYPE_WIDTH = 3
) (
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
    // high when this submodule is the last piece of burst
    output wire                  last,
    // the data to be streamed
    output wire [DATA_WIDTH-1:0] data,
    // AXI master (output wire) Interface, will forward the AXIS transaction to destination
    input  wire [  ID_WIDTH-1:0] AXIM_rid,
    input  wire [DATA_WIDTH-1:0] AXIM_rdata,
    input  wire [           1:0] AXIM_rresp,
    input  wire                  AXIM_rlast,
    input  wire [USER_WIDTH-1:0] AXIM_ruser,
    input  wire                  AXIM_rvalid,
    output wire                  AXIM_rready,
    // AXI Slave (input wire) interface
    output wire [  ID_WIDTH-1:0] AXIS_rid,
    output wire [DATA_WIDTH-1:0] AXIS_rdata,
    output wire [           1:0] AXIS_rresp,
    output wire                  AXIS_rlast,
    output wire [USER_WIDTH-1:0] AXIS_ruser,
    output wire                  AXIS_rvalid,
    input  wire                  AXIS_rready
);
  //when we get a ready, we have know when the burst is done
  //so we have a sending register, that will be high when we are in the middle of a burst
  reg sending;
  assign AXIS_rid = AXIM_rid;
  assign AXIS_rdata = AXIM_rdata;
  assign AXIS_rresp = AXIM_rresp;
  assign AXIS_rlast = AXIM_rlast;
  assign AXIS_ruser = AXIM_ruser;
  //we mask the ready and valid signals with our conditions, to make sure we stall the transaction so we can follow it
  //NOTE: here we stall the transaction so we can send metadata at the beginning and then we just follow the transaction
  assign AXIS_rvalid = AXIM_rvalid && (~resetn || (ready && sending));
  assign AXIM_rready = AXIS_rready && (~resetn || (ready && sending));

  // we do not have valid data if we are in reset
  // NOTE: Here we are using the signals that come from the top level modules not the masked ones!
  assign valid = resetn && AXIS_rready && AXIM_rvalid;

  assign in_progress = sending;
  //we mask last with reset, to avoid problems if the reset is asserted
  assign last = resetn && AXIM_rlast;

  //the sending register will determine if we are sending data or metadata
  assign data =  //did we get a handshake?
      (valid & ready) ?
      // did we already send metadata?
      (sending) ?
      // was there no error?
      (AXIS_rresp < 2'b10) ?
      // if all the checks are true we send the data
      AXIS_rdata :
      // we failed the error check, send the error as metadata
      {STREAM_TYPE, {DATA_WIDTH - STREAM_TYPE_WIDTH - 2{1'b0}}, AXIM_rresp} :
      // we failed the metadata checks, send the metadata
      {STREAM_TYPE, {DATA_WIDTH - STREAM_TYPE_WIDTH - ID_WIDTH{1'b0}}, AXIS_rid} :
      //no handshake, we send noting
      0;

  always @(posedge clk) begin
    if (resetn) begin
      if (ready && valid) begin
        sending <= ~AXIM_rlast;
      end else begin
        sending <= sending;
      end
    end else begin
      sending <= 0;
    end
  end

endmodule
