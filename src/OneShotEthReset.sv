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

module OneShotEthReset # (
    parameter TIMER_MAX_WIDTH=14,
    parameter RESET_MAX_WIDTH=14,
    parameter RESETLOGIC=0
) (
    input wire clk,
    input wire aresetn,
    input wire [TIMER_MAX_WIDTH-1:0] ResetAfter,
    input wire [RESET_MAX_WIDTH-1:0] ResetWidth,
    input wire ResetTrigger,
    output reg OneShotReset
);


reg [TIMER_MAX_WIDTH+RESET_MAX_WIDTH-1:0] LogicalClock;
reg shot;


always @(posedge clk) begin
    if(!aresetn)begin
        LogicalClock<=0;
        shot<=0;
        OneShotReset<=0;
    end
    else begin
        if(ResetTrigger==RESETLOGIC & !shot)begin
            LogicalClock<=LogicalClock+1;
            shot<=1;
        end
        else if(LogicalClock!=0)begin
            if(LogicalClock>=ResetAfter & LogicalClock<ResetAfter+ResetWidth)begin
                OneShotReset<=1;                
            end
            else begin
                OneShotReset<=0;
            end
            LogicalClock<=LogicalClock+1;
        end
        else begin
            LogicalClock<=LogicalClock;
            shot<=shot;
            OneShotReset<=OneShotReset;
        end
    end
end

endmodule



