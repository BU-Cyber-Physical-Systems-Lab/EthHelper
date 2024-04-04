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
  /// This register will keep track of the last data piece that we saw on the wire
  reg [DATA_WIDTH-1:0] out_reg;
  // this reister represent what we are sending to the stream module once we have a handshake
  enum reg [1:0] {
    METADATA,  // at the beginning we send metadata
    SENDING,  // then the transaction
    SEND_LAST // but the last transaction piece will be delayed, since we sent metadata first, so we need to remeber about it
  } sending;
  assign AXIS_rid = AXIM_rid;
  assign AXIS_rdata = AXIM_rdata;
  assign AXIS_rresp = AXIM_rresp;
  assign AXIS_rlast = AXIM_rlast;
  assign AXIS_ruser = AXIM_ruser;
  //we mask the ready and valid signals with our conditions, to make sure we stall the transaction so we can follow it
  //NOTE: here we stall the transaction so we can send metadata at the beginning and then we just follow the transaction
  assign AXIS_rvalid = AXIM_rvalid && (ready || ~resetn);
  assign AXIM_rready = AXIS_rready && (ready || ~resetn);

  // we do not have valid data if we are in reset
  // NOTE: Here we are using the signals that come from the top level modules not the masked ones!
  assign valid = resetn && ((AXIS_rready && AXIM_rvalid) || (sending != METADATA));
  assign in_progress = sending != METADATA;
  //we mask last with reset, to avoid problems if the reset is asserted
  assign last = sending == SEND_LAST;

  //the sending register will determine if we are sending data or metadata
  assign data = (sending == METADATA) ?
      //in the metadata state send the metadata on the bus
      {STREAM_TYPE, {DATA_WIDTH - STREAM_TYPE_WIDTH - ID_WIDTH{1'b0}}, AXIS_rid} :
      //otherwise use the out_reg data
      out_reg;

  always @(posedge clk) begin
    if (resetn) begin
      //if we get a handshake we already sent metedata
      if (valid && ready) begin
        // if we were sending the last piece we cycle back to metadata (which won't be valid)
        if (sending == SEND_LAST) begin
          sending <= METADATA;
        end else begin
          // if we are not sending the last piece, we need to check if the last piece is in the next clock cycle
          if (AXIM_rlast) begin
            sending <= SEND_LAST;
          end else begin
            sending <= SENDING;
          end
        end
        //avoid latching
      end else begin
        sending <= sending;
      end
    end else begin
      //we start with invalid metadata
      sending <= METADATA;
    end
  end

  always @(posedge clk) begin
    if (resetn) begin
      //did we get a handshake?
      if (valid && ready) begin
        // was there no error?
        if (AXIS_rresp < 2'b10) begin
          // if all the checks are true we send the data
          out_reg <= AXIS_rdata;
        end else begin
          // we failed the error check, send the error as metadata
          out_reg <= {STREAM_TYPE, {DATA_WIDTH - STREAM_TYPE_WIDTH - 2{1'b0}}, AXIM_rresp};
        end
      end else begin
        //if we are not in metadata state, we keep the current value
        if (sending != METADATA) begin
          out_reg <= out_reg;
        end else begin
          // otherwise reset to 0
          out_reg <= 0;
        end
      end
    end else begin
      out_reg <= 0;
    end
  end

endmodule
