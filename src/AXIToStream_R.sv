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


module AXIToStream_R#(
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
    input  wire                  clk,
    input  wire                  resetn,
    input  wire                  can_forwardR,
    //module output pins
    output reg                  output_valid,
    output reg [DATA_WIDTH-1:0] output_data,
    // AXI Slave (input wire) interface, will AXIS a transaction
    output wire [    ID_WIDTH-1:0] AXIS_rid,
    output wire [  DATA_WIDTH-1:0] AXIS_rdata,
    output wire [             1:0] AXIS_rresp,
    output wire                    AXIS_rlast,
    output wire [  USER_WIDTH-1:0] AXIS_ruser,
    output wire                    AXIS_rvalid,
    input  wire                    AXIS_rready,
    // AXI master (output wire) Interface, will forward the AXISed transaction to destination
    input  wire [    ID_WIDTH-1:0] AXIM_rid,
    input  wire [  DATA_WIDTH-1:0] AXIM_rdata,
    input  wire [             1:0] AXIM_rresp,
    input  wire                    AXIM_rlast,
    input  wire [  USER_WIDTH-1:0] AXIM_ruser,
    input  wire                    AXIM_rvalid,
    output wire                    AXIM_rready
);
//send data then resp or send data
//top level manager has to keep in mind that the Read will need 2 cycles to complete 1 read transaction

  //keep track of what was sent last to alternate in between data and response
  reg sent_rdata;
  
  //save the response data for the next clock cycle (since it is on the same channel as R)
  reg [3:0] response;
  //save the RID of the processor that requested this data to send in metadata packet
  reg [ID_WIDTH-1:0] ReaderID;
  
  assign AXIS_rid = AXIM_rid;
  assign AXIS_rdata = AXIM_rdata;
  assign AXIS_rresp = AXIM_rresp;
  assign AXIS_rlast = AXIM_rlast;
  assign AXIS_ruser = AXIM_ruser;

  //todo: include logic to always allow for handshaking to happen when this module is stuck in reset 
  //i.e change everything below
  assign AXIS_rvalid = AXIM_rvalid && can_forwardR && !sent_rdata;
  assign AXIM_rready = AXIS_rready && can_forwardR && !sent_rdata;
  
  assign _RH= AXIS_rvalid && AXIM_rready;
  
  always @(posedge clk) begin   
    
  end
  

  
  
  


endmodule
