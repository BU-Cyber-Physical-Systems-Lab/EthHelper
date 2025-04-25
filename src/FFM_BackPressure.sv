`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2023 01:45:03 PM
// Design Name: 
// Module Name: FrameFormerSubordinate
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

module FFM_BackPressure # (
    parameter integer MAX_INTERNAL_SPACE = 64
    )(
    input wire ACLK,
    input wire ARESETN,

    input wire [$clog2(MAX_INTERNAL_SPACE):0] Delay,
    input wire [8:0] TimerInit,
    input wire [8:0] GapInit,
    
    input wire S_AXIS_tvalid,
    input wire S_AXIS_tlast,
    input wire M_AXIS_tready,

    output wire M_AXIS_tvalid,
    output wire S_AXIS_tready,
    
    input wire [$clog2(MAX_INTERNAL_SPACE):0] FFSTail
    
    );
    //Logic is that you wait for the Delay and the FFSTail match
    //once matched (or greater) then only reinitiate the delay once tlast is asserted
    //keep it simple?

    //add an emmission timer logic to flush the buffer 
    
    reg blocked;
    reg [8:0] TimerReg;
    reg [8:0] GapReg;

    assign M_AXIS_tvalid=S_AXIS_tvalid & !blocked;
    assign S_AXIS_tready=M_AXIS_tready & !blocked;


    always @ (posedge ACLK)begin
        if(!ARESETN)begin
            blocked<=1;
            TimerReg<=TimerInit;
            GapReg<=GapInit;
        end
        else begin
            //there is technically a latch but fix later
            if(!blocked)begin
                if(S_AXIS_tlast)begin
                    blocked<=!blocked;
                    TimerReg<=TimerInit;
                    GapReg<=GapInit;
                end
            end
            else begin
                if(|TimerReg)begin 
                    blocked <= !((FFSTail>=(Delay-1)) & !(|GapReg));
                    GapReg<=((|GapReg)?(GapReg-1):(0));
                    TimerReg<=((|TimerReg)?(TimerReg-1):(0));
                end
                else begin
                    blocked<=!blocked;
                end
            end 
        end
    end

    
endmodule
