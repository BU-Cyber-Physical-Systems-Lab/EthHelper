`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 11:58:38 AM
// Design Name: 
// Module Name: FrameFormer_wrapper
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


module FrameFormer_wrapper #(
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
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS tlast" *)
    input wire S_AXIS_tlast,
//    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, HAS_TLAST 1" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS tuser" *)
    input wire [7:0] S_AXIS_tuser,
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
    //i can write something silly at a somewhat comfortable speed on the opi5plus
    //specific helper values
    input wire [47:0] Destination_Address,
    input wire [47:0] Source_Address,
    input wire [15:0] Link_Type,
    input wire [15:0] SyncWord,
    input wire [13:0] Packet_Size,
    
    //debug wires
    output wire FFMisReady,
    output wire [13:0] FFMState,
    output wire FFSisFull,
    output wire FFSisEmpty,
    output wire [$clog2(MAX_INTERNAL_SPACE):0] FFSTail,
    output wire [INPUT_WIDTH-1:0] FFSFFM_Data_Transfer,
    output wire [INPUT_WIDTH-1:0] FFSFFM_delayed_Transfer,
    output wire counterPulseOutFFS,
    output wire counterPulseOutFFM
    );
    
    FrameFormer #(
    .MAX_INTERNAL_SPACE(MAX_INTERNAL_SPACE),
    .OUTPUT_WIDTH(OUTPUT_WIDTH),
    .INPUT_WIDTH(INPUT_WIDTH)
    ) FF(
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXIS_tdata(S_AXIS_tdata),
        .S_AXIS_tready(S_AXIS_tready),
        .S_AXIS_tkeep(S_AXIS_tkeep),
        .S_AXIS_tvalid(S_AXIS_tvalid),
        .S_AXIS_tlast(S_AXIS_tlast),
        .M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tready(M_AXIS_tready),
        .M_AXIS_tkeep(M_AXIS_tkeep),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .M_AXIS_tlast(M_AXIS_tlast),
        .Destination_Address(Destination_Address),
        .Source_Address(Source_Address),
        .Link_Type(Link_Type),
        .SyncWord(SyncWord),
        .Packet_Size(Packet_Size),
        .FFSTail(FFSTail),
        .FFSFFM_Data_Transfer(FFSFFM_Data_Transfer),
        .FFMState(FFMState),
        .FFSisFull(FFSisFull),
        .FFSisEmpty(FFSisEmpty),
        .FFMisReady(FFMisReady),
        .FFSFFM_delayed_Transfer(FFSFFM_delayed_Transfer),
        .counterPulseOutFFS(counterPulseOutFFS),
        .counterPulseOutFFM(counterPulseOutFFM)
    );
    
endmodule
