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
    // AXI Slave (input wire) interface, will Fake_Sub a transaction
    output wire [    ID_WIDTH-1:0] Fake_Sub_rid,
    output wire [  DATA_WIDTH-1:0] Fake_Sub_rdata,
    output wire [             1:0] Fake_Sub_rresp,
    output wire                    Fake_Sub_rlast,
    output wire [  USER_WIDTH-1:0] Fake_Sub_ruser,
    output wire                    Fake_Sub_rvalid,
    input  wire                    Fake_Sub_rready,
    // AXI master (output wire) Interface, will forward the Fake_Subed transaction to destination
    input  wire [    ID_WIDTH-1:0] Real_Sub_rid,
    input  wire [  DATA_WIDTH-1:0] Real_Sub_rdata,
    input  wire [             1:0] Real_Sub_rresp,
    input  wire                    Real_Sub_rlast,
    input  wire [  USER_WIDTH-1:0] Real_Sub_ruser,
    input  wire                    Real_Sub_rvalid,
    output wire                    Real_Sub_rready
);
//send data then resp or send data (if thesis will be used as a debugger)
//top level manager has to keep in mind that the Read will need 2 cycles to complete 1 read transaction

  reg sent_rdata;
  reg [3:0] response;
  reg [ID_WIDTH-1:0] ReaderID;
  
  assign Fake_Sub_rid = Real_Sub_rid;
  assign Fake_Sub_rdata = Real_Sub_rdata;
  assign Fake_Sub_rresp = Real_Sub_rresp;
  assign Fake_Sub_rlast = Real_Sub_rlast;
  assign Fake_Sub_ruser = Real_Sub_ruser;
  assign Fake_Sub_rvalid = Real_Sub_rvalid && can_forwardR && !sent_rdata;
  assign Real_Sub_rready = Fake_Sub_rready && can_forwardR && !sent_rdata;
  
  assign _RH=Fake_Sub_rvalid && Real_Sub_rready;
  
  always @(posedge clk) begin
    if(!resetn)begin 
        output_valid<=0;
        output_data<=0;
        sent_rdata<=0;
        response<=0;
        ReaderID<=0;
    
    end
    else if (_RH && !sent_rdata)begin  
        sent_rdata<=1;
        output_valid<=1;
        output_data<=Real_Sub_rdata;
        response<=Real_Sub_rresp;
        ReaderID<=Real_Sub_rid;
    end
    else if(sent_rdata && can_forwardR)begin
        output_data[127:95]<=ReaderID;
        output_data[3:0]<=response;
        output_valid <= output_valid;
    end
    else
        output_valid <= 0;
        output_data <= output_data;
    
  end
  

  
  
  


endmodule
