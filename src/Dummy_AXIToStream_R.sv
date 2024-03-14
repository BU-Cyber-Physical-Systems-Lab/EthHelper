`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2024 04:36:04 PM
// Design Name: 
// Module Name: Dummy_AXIToStream_R
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


module Dummy_AXIToStream_R # (
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 32,
    parameter BURST_LEN = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64
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
    // the data to be streamed
    output wire [DATA_WIDTH-1:0] data,
    // AXI master (output wire) Interface, will forward the AXIS transaction to destination
    output wire [    ID_WIDTH-1:0] AXIM_rid,
    output wire [  DATA_WIDTH-1:0] AXIM_rdata,
    output wire [             1:0] AXIM_rresp,
    output wire                    AXIM_rlast,
    output wire [  USER_WIDTH-1:0] AXIM_ruser,
    output wire                    AXIM_rvalid,
    input  wire                    AXIM_rready,
    // AXI Slave (input wire) interface
    input  wire [    ID_WIDTH-1:0] AXIS_rid,
    input  wire [  DATA_WIDTH-1:0] AXIS_rdata,
    input  wire [             1:0] AXIS_rresp,
    input  wire                    AXIS_rlast,
    input  wire [  USER_WIDTH-1:0] AXIS_ruser,
    input  wire                    AXIS_rvalid,
    output wire                    AXIS_rready
);
//send data then resp or send data
//top level manager has to keep in mind that the Read will need 2 cycles to complete 1 read transaction

  //keep track of what was sent last to alternate in between data and response

  
  //save the response data for the next clock cycle (since it is on the same channel as R)

  //save the RID of the processor that requested this data to send in metadata packet
  
  assign AXIM_rid = AXIS_rid;
  assign AXIM_rdata = AXIS_rdata;
  assign AXIM_rresp = AXIS_rlast;
  assign AXIM_ruser = AXIS_ruser;

  //todo: include logic to always allow for handshaking to happen when this module is stuck in reset 
  //i.e change everything below
  assign AXIM_rvalid = resetn && AXIS_rvalid;
  assign AXIS_rready = resetn && AXIM_rready;

endmodule
