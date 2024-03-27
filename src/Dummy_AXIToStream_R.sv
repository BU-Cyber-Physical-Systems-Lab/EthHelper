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
    
    // AXI master (output wire) Interface, will forward the AXIS transaction to destination
    input  wire [    ID_WIDTH-1:0] AXIM_rid,
    input  wire [  DATA_WIDTH-1:0] AXIM_rdata,
    input  wire [             1:0] AXIM_rresp,
    input  wire                    AXIM_rlast,
    input  wire [  USER_WIDTH-1:0] AXIM_ruser,
    input  wire                    AXIM_rvalid,
    output wire                    AXIM_rready,
    // AXI Slave (input wire) interface
    output  wire [    ID_WIDTH-1:0] AXIS_rid,
    output  wire [  DATA_WIDTH-1:0] AXIS_rdata,
    output  wire [             1:0] AXIS_rresp,
    output  wire                    AXIS_rlast,
    output  wire [  USER_WIDTH-1:0] AXIS_ruser,
    output  wire                    AXIS_rvalid,
    input wire                    AXIS_rready
);
  
  assign AXIS_rid = AXIM_rid;
  assign AXIS_rdata = AXIM_rdata;
  assign AXIS_rlast = AXIM_rlast;
  assign AXIS_rresp = AXIM_rresp;
  assign AXIS_ruser = AXIM_ruser;
  assign AXIS_rvalid = AXIM_rvalid;
  assign AXIM_rready = AXIS_rready;
  

endmodule
