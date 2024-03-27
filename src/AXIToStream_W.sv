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


module AXIToStream_W #(
    parameter DATA_WIDTH = 128,
    parameter ID_WIDTH = 32,
    parameter USER_WIDTH = 64,
    parameter STREAM_TYPE = 3'b011,
    parameter STREAM_TYPE_WIDTH = 3,
    parameter BURST_SIZE = 4
) (
    input  wire                    clk,
    //negative edge synchronous reset, active low, synchronous to the clk
    input  wire                    resetn,
    // when this ready is high we can start the transaction, otherwise we have to wait
    input  wire                    ready,
    //module output pins
    // high when this submodule has valid data to be streamed
    output wire                    valid,
    // high when this submodule is streaming data (to block the other submodules from streaming data at the same time)
    output wire                    in_progress,
    // high when this submodule is the last piece of burst
    output wire                    last,
    // the data to be streamed
    output wire [  DATA_WIDTH-1:0] data,
    // AXI master (output wire) Interface, will forward the AXIS transaction to destination
    output wire [    ID_WIDTH-1:0] AXIM_wid,
    output wire [  DATA_WIDTH-1:0] AXIM_wdata,
    output wire [DATA_WIDTH/8-1:0] AXIM_wstrb,
    output wire                    AXIM_wlast,
    output wire [  USER_WIDTH-1:0] AXIM_wuser,
    output wire                    AXIM_wvalid,
    input  wire                    AXIM_wready,
    // AXI Slave (input wire) interface
    input  wire [    ID_WIDTH-1:0] AXIS_wid,
    input  wire [  DATA_WIDTH-1:0] AXIS_wdata,
    input  wire [DATA_WIDTH/8-1:0] AXIS_wstrb,
    input  wire                    AXIS_wlast,
    input  wire [  USER_WIDTH-1:0] AXIS_wuser,
    input  wire                    AXIS_wvalid,
    output wire                    AXIS_wready
);
  //we need to keep track of the internal state of the module, since the write transaction will be
  // the following:
  // 1. send metadata
  // 2. send data (all bursts)
  // 3. send packed strobes
  enum reg [1:0] {
    METADATA,  //sending metadata
    DATA,  // sending data
    STROBE  // sending strobe
  } state;
  // the register that will hold all burst strobes
  reg [BURST_SIZE*(DATA_WIDTH/8)-1:0] strobes;
  assign last = (state == STROBE);
  assign AXIM_wid = AXIS_wid;
  assign AXIM_wdata = AXIS_wdata;
  assign AXIM_wstrb = AXIS_wstrb;
  assign AXIM_wlast = AXIS_wlast;
  assign AXIM_wuser = AXIS_wuser;
  //we mask the ready and valid signals with our conditions, to make sure we stall the transaction so we can follow it
  //NOTE: here we stall the transaction so we can send metadata at the beginning and then we just follow the transaction
  assign AXIM_wvalid = AXIS_wvalid && (~resetn || ready && (state == DATA));
  assign AXIS_wready = AXIM_wready && (~resetn || ready && (state == DATA));

  // we do not have valid data if we are in reset
  // NOTE: Here we are using the signals that come from the top level modules not the masked ones!
  assign valid = resetn && AXIS_wvalid && AXIM_wready;

  assign in_progress = (state > METADATA);

  //the sending register will determine if we are sending data or metadata
  assign data =  //do we have valid data?
      (ready && valid) ?
      // are sending metadata?
      (state == METADATA) ?
      //yes
      {STREAM_TYPE, {DATA_WIDTH - STREAM_TYPE_WIDTH - ID_WIDTH{1'b0}}, AXIM_wid} :
      // are we streaming data?
      (state == DATA) ?
      // if all the checks are true we send the data
      AXIS_wdata :
      // we failed the error check, send the error as metadata
      {STREAM_TYPE, {DATA_WIDTH - STREAM_TYPE_WIDTH - (BURST_SIZE * (DATA_WIDTH / 8)) {1'b0}}, strobes} :
      //no handshake, we send noting
      0;

  always @(posedge clk) begin
    if (resetn) begin
      if (ready && valid) begin
        if (state == METADATA) begin
          state   <= DATA;
          strobes <= 0;
        end else if (state == DATA) begin
          //we accumulate strobes in the strobes register
          strobes <= {strobes[(BURST_SIZE-1)*DATA_WIDTH/8-1:0], AXIS_wstrb};
          if (AXIS_wlast) begin
            state <= STROBE;
          end
        end else if (state == STROBE) begin
          state   <= METADATA;
          strobes <= 0;
        end else begin
          state   <= state;
          strobes <= strobes;
        end
      end else begin
        state   <= state;
        strobes <= strobes;
      end
    end else begin
      state   <= METADATA;
      strobes <= 0;
    end
  end

endmodule
