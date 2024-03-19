`timescale 1ns / 1ps
/** @file AXIToStream_Ax.sv
 * @brief Snoop AXI4 AR/AW transaction and send a copy of their data from the
 *  AXIStream port.
 * @author Mattia Nicolella
 */

/** @brief Snoop AXI4 AR/AW transaction and send a copy of their data from the
 *  AXIStream port.
 * @details This module acts as a passtrough between an AXI4 master/slave,
 * while creating an equivalent transaction from the AXIStream master.
 */
module AXIToStream_Ax #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 32,
    parameter BURST_LEN = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64,
    parameter STREAM_TYPE = 3'b0,
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
    input  wire [  ID_WIDTH-1:0] AXIS_axid,
    input  wire [ADDR_WIDTH-1:0] AXIS_axaddr,
    input  wire [ BURST_LEN-1:0] AXIS_axlen,
    input  wire [           2:0] AXIS_axsize,
    input  wire [           1:0] AXIS_axburst,
    input  wire [LOCK_WIDTH-1:0] AXIS_axlock,
    input  wire [           3:0] AXIS_axcache,
    input  wire [           2:0] AXIS_axprot,
    input  wire [           3:0] AXIS_axregion,
    input  wire [           3:0] AXIS_axqos,
    input  wire [USER_WIDTH-1:0] AXIS_axuser,
    input  wire                  AXIS_axvalid,
    output wire                  AXIS_axready,
    // AXI master (output wire) Interface, will forward the snooped transaction to destination
    output wire [  ID_WIDTH-1:0] AXIM_axid,
    output wire [ADDR_WIDTH-1:0] AXIM_axaddr,
    output wire [ BURST_LEN-1:0] AXIM_axlen,
    output wire [           2:0] AXIM_axsize,
    output wire [           1:0] AXIM_axburst,
    output wire [LOCK_WIDTH-1:0] AXIM_axlock,
    output wire [           3:0] AXIM_axcache,
    output wire [           2:0] AXIM_axprot,
    output wire [           3:0] AXIM_axregion,
    output wire [           3:0] AXIM_axqos,
    output wire [USER_WIDTH-1:0] AXIM_axuser,
    output wire                  AXIM_axvalid,
    input  wire                  AXIM_axready
);
  assign AXIM_axid = AXIS_axid;
  assign AXIM_axaddr = AXIS_axaddr;
  assign AXIM_axlen = AXIS_axlen;
  assign AXIM_axsize = AXIS_axsize;
  assign AXIM_axburst = AXIS_axburst;
  assign AXIM_axlock = AXIS_axlock;
  assign AXIM_axcache = AXIS_axcache;
  assign AXIM_axprot = AXIS_axprot;
  assign AXIM_axregion = AXIS_axregion;
  assign AXIM_axqos = AXIS_axqos;
  assign AXIM_axuser = AXIS_axuser;
  // mask the handshake of the full AXI interfaces to start the transaction only when we are ready to stream the output
  // or when we are in reset state
  assign AXIM_axvalid = AXIS_axvalid && (~resetn || ready);
  assign AXIS_axready = AXIM_axready && (~resetn || ready);
  //out data is valid only when there is a handshake and we are not in reset state
  assign valid = resetn && AXIS_axvalid && AXIM_axready;
  // these transaction need only one clock cycle to be completed, so we are in progress only when the input is valid
  assign in_progress = valid;
  assign last = ready && valid;
  // the output data is composed as follows
  assign data = {
    STREAM_TYPE,
    AXIM_axid,
    AXIM_axlen,
    {DATA_WIDTH - STREAM_TYPE_WIDTH - ID_WIDTH - BURST_LEN - ADDR_WIDTH{1'b0}},
    AXIM_axaddr
  };
endmodule
