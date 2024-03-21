`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2024 04:36:04 PM
// Design Name: 
// Module Name: Dummy_AXIToStream_W
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

module Dummy_AXIToStream_W # (
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
    output wire [    ID_WIDTH-1:0] AXIM_wid,
    output wire [DATA_WIDTH-1:0] AXIM_wdata,
    output wire [DATA_WIDTH/8-1:0] AXIM_wstrb,
    output wire                    AXIM_wlast,
    output wire [  USER_WIDTH-1:0] AXIM_wuser,
    output wire                    AXIM_wvalid,
    input  wire                  AXIM_wready,
    // AXI Slave (input wire) interface
    input wire [    ID_WIDTH-1:0] AXIS_wid,
    input wire [DATA_WIDTH-1:0] AXIS_wdata,
    input wire [DATA_WIDTH/8-1:0] AXIS_wstrb,
    input wire                    AXIS_wlast,
    input wire [  USER_WIDTH-1:0] AXIS_wuser,
    input wire                    AXIS_wvalid,
    output  wire                  AXIS_wready
);


assign AXIM_wid = AXIS_wid;
assign AXIM_wdata = AXIS_wdata;
assign AXIM_wuser = AXIS_wuser;
assign AXIM_wlast = AXIS_wlast;
assign AXIM_wstrb = AXIS_wstrb;
assign AXIM_wvalid = AXIS_wvalid;
assign AXIS_wready = AXIM_wready;


endmodule