`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2023 04:29:06 PM
// Design Name: 
// Module Name: SinglePacketEthHelper_wrapper
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


module SinglePacketEthHelper_wrapper#(
    parameter integer MAX_INTERNAL_SPACE = 64,
    parameter integer OUTPUT_WIDTH = 64,
    parameter integer INPUT_WIDTH = 64 
)(
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_CLKEN ARESETN,  ASSOCIATED_BUSIF S_AXIS:M_AXIS" *)
    input wire ACLK,
    input wire ARESETN,
    
    //subordinate
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS tdata" *)
    input wire [INPUT_WIDTH-1:0] S_AXIS_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS tready" *)
    output wire S_AXIS_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS tkeep" *)
    input wire [7:0] S_AXIS_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS tvalid" *)
    input wire S_AXIS_tvalid,
    
    //manager
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS tdata" *)
    output wire [OUTPUT_WIDTH-1:0] M_AXIS_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS tready" *)
    input wire M_AXIS_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS tkeep" *)
    output wire [7:0] M_AXIS_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS tvalid" *)
    output wire M_AXIS_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS tlast" *)
    output wire M_AXIS_tlast,
    
    //specific helper values
    input wire [47:0] Destination_Address,
    input wire [47:0] Source_Address,
    input wire [15:0] Link_Type,
    input wire [15:0] SyncWord
    );
    

    
    SinglePacketEthHelper # (
    .MAX_INTERNAL_SPACE(MAX_INTERNAL_SPACE),
    .OUTPUT_WIDTH(OUTPUT_WIDTH),
    .INPUT_WIDTH(INPUT_WIDTH)
    ) speh (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .S_AXIS_tdata(S_AXIS_tdata),
    .S_AXIS_tready(S_AXIS_tready),
    .S_AXIS_tkeep(S_AXIS_tkeep),
    .S_AXIS_tvalid(S_AXIS_tvalid),
    .Destination_Addr(Destination_Address),
    .Source_Addr(Source_Address),
    .Link_Type(Link_Type),
    .SyncWord(SyncWord),
    .M_AXIS_tdata(M_AXIS_tdata),
    .M_AXIS_tready(M_AXIS_tready),
    .M_AXIS_tkeep(M_AXIS_tkeep),
    .M_AXIS_tvalid(M_AXIS_tvalid),
    .M_AXIS_tlast(M_AXIS_tlast)
    );
    
    
    
    
endmodule
