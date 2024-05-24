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

module OneShotEthReset_wrapper # (
    parameter TIMER_MAX_WIDTH=14,
    parameter RESET_MAX_WIDTH=14,
    parameter RESETLOGIC=0
) (
    input wire                              clk,
    input wire                          aresetn,
    input wire [TIMER_MAX_WIDTH-1:0] ResetAfter,
    input wire [RESET_MAX_WIDTH-1:0] ResetWidth,
    input wire                     ResetTrigger,
    output wire                    OneShotReset
);

OneShotEthReset # (
    .TIMER_MAX_WIDTH(TIMER_MAX_WIDTH),
    .RESET_MAX_WIDTH(RESET_MAX_WIDTH),
    .RESETLOGIC(RESETLOGIC)
) osr (
    .clk(clk),
    .aresetn(aresetn),
    .ResetAfter(ResetAfter),
    .ResetWidth(ResetWidth),
    .ResetTrigger(ResetTrigger),
    .OneShotReset(OneShotReset)
);


endmodule


