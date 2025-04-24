`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2023 12:29:25 PM
// Design Name: 
// Module Name: FrameFormer
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


module FrameFormer_Delay # (
    parameter integer MAX_INTERNAL_SPACE = 64,
    parameter integer OUTPUT_WIDTH = 64,
    parameter integer INPUT_WIDTH = 64 
    )
   (
    input wire ACLK,
    input wire ARESETN,
    
    //subordinate
    input wire [INPUT_WIDTH-1:0] S_AXIS_tdata,
    output wire S_AXIS_tready,
    input wire [7:0] S_AXIS_tkeep,
    input wire S_AXIS_tvalid,
    input wire S_AXIS_tlast,
    
    //manager
    output wire [OUTPUT_WIDTH-1:0] M_AXIS_tdata,
    input wire M_AXIS_tready,
    output wire [7:0] M_AXIS_tkeep,
    output wire M_AXIS_tvalid,
    output wire M_AXIS_tlast,
    
    //specific helper values
    input wire [47:0] Destination_Address,
    input wire [47:0] Source_Address,
    input wire [15:0] Link_Type,
    input wire [15:0] SyncWord,
    input wire [13:0] Packet_Size,


    //backpressure related
    input wire [$clog2(MAX_INTERNAL_SPACE):0] Delay,
    
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
    


    wire Framer_Ready;
    wire Input_Buffer_Full;
    wire Input_Buffer_Empty;
    wire [63:0] Data_Transfer;
    wire [63:0] Delayed_Data_Transfer;
    

    assign FFMisReady = Framer_Ready;
    assign FFSisFull = Input_Buffer_Full;    
    assign FFSisEmpty = Input_Buffer_Empty;
    assign FFSFFM_Data_Transfer = Data_Transfer;
    assign FFSFFM_delayed_Transfer = Delayed_Data_Transfer;

    wire FFM_tvalid;
    wire FFM_tlast;
    
    
    wire Delay_ready;
    wire Delay_valid;

    FFM_BackPressure # (
        .MAX_INTERNAL_SPACE(MAX_INTERNAL_SPACE)
    ) FFM_BP(
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        //inputs
        .Delay(Delay),
        .S_AXIS_tlast(M_AXIS_tlast),
        .S_AXIS_tvalid(Delay_valid),
        .M_AXIS_tready(M_AXIS_tready),
        .FFSTail(FFSTail),
        //outputs
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .S_AXIS_tready(Delay_ready)

    );
    
    FrameFormerSubordinate # (
    .INPUT_WIDTH(INPUT_WIDTH),
    .MAX_INTERNAL_SPACE(MAX_INTERNAL_SPACE),
    .OUTPUT_WIDTH(OUTPUT_WIDTH)
    )FFS(
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXIS_tdata(S_AXIS_tdata),
        .S_AXIS_tready(S_AXIS_tready),
        .S_AXIS_tkeep(S_AXIS_tkeep),
        .S_AXIS_tvalid(S_AXIS_tvalid),
        .S_AXIS_tlast(S_AXIS_tlast),
        .FramerReady(Framer_Ready),
        .empty(Input_Buffer_Empty),
        .full(Input_Buffer_Full),
        .tempOut(Data_Transfer),
        .FramerTready(M_AXIS_tready),
        .FFSTail(FFSTail),
        .Delayed_Data_Transfer(Delayed_Data_Transfer),
        .counterPulseOut(counterPulseOutFFS)
    );
    
    FrameFormerManager #(
    .OUTPUT_WIDTH(OUTPUT_WIDTH)
    ) FFM(
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tready(Delay_ready),
        .M_AXIS_tkeep(M_AXIS_tkeep),
        .M_AXIS_tvalid(Delay_valid),
        .M_AXIS_tlast(M_AXIS_tlast),
        .FFMready(Framer_Ready),
        .is_empty(Input_Buffer_Empty),
        .is_full(Input_Buffer_Full),
        .Packet_Size(Packet_Size),
        .Destination_Address(Destination_Address),
        .Source_Address(Source_Address),
        .Link_Type(Link_Type),
        .SyncWord(SyncWord),
        .Input_Data(Data_Transfer),
        .FFMState(FFMState),
        .counterPulseOut(counterPulseOutFFM)
    );
    
    
endmodule
