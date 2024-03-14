`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2024 04:36:04 PM
// Design Name: 
// Module Name: Dummy_AXIToStream_B
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

module Dummy_AXIToStream_B # (
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
    output wire [    ID_WIDTH-1:0] AXIM_bid,
    output wire [             1:0] AXIM_bresp,
    output wire [  USER_WIDTH-1:0] AXIM_buser,
    output wire                    AXIM_bvalid,
    input  wire                    AXIM_bready,
    // AXI Slave (input wire) interface
    input  wire [    ID_WIDTH-1:0] AXIS_bid,
    input  wire [             1:0] AXIS_bresp,
    input  wire [  USER_WIDTH-1:0] AXIS_buser,
    input  wire                    AXIS_bvalid,
    output wire                    AXIS_bready
);


assign AXIM_bid = AXIS_bid;
assign AXIM_bresp = AXIS_bresp;
assign AXIM_buser = AXIS_buser;
assign AXIM_bvalid = AXIS_bvalid;
assign AXIM_bready = AXIS_bready;

endmodule