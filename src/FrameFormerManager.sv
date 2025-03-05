`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2023 03:25:55 PM
// Design Name: 
// Module Name: FrameFormerManager
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
//todo use ILA advanced trigger to count the amount of packets

module FrameFormerManager # (
    parameter integer OUTPUT_WIDTH = 64
    )(
    input wire ACLK,
    input wire ARESETN,
    
    //"subordinate" interface
    input wire is_empty,
    input wire is_full,
    output wire FFMready,
    input wire [63:0] Input_Data,//reg or wire???    
    
    //manager
    output reg [OUTPUT_WIDTH-1:0] M_AXIS_tdata,
    input wire M_AXIS_tready,
    output reg [7:0] M_AXIS_tkeep,
    output reg M_AXIS_tvalid,
    output reg M_AXIS_tlast,
    
    //specific helper values
    input wire [47:0] Destination_Address,
    input wire [47:0] Source_Address,
    input wire [15:0] Link_Type,
    input wire [15:0] SyncWord,
    input wire [13:0] Packet_Size,
    
    //wires for debugging
    output wire [13:0] FFMState,
    output wire counterPulseOut
    );
    

    reg counterPulseOutReg;
    assign counterPulseOut=counterPulseOutReg;
    
    reg[13:0] state;
    
    
    
    assign FFMState=state;    
    assign FFMready = (state>1 && state<Packet_Size) && M_AXIS_tready;
    
    //reg delayedFFMready;

    //reg [OUTPUT_WIDTH-1:0] store;
    
    function void init();
        state<=0;
        M_AXIS_tlast<=0;
        M_AXIS_tvalid<=0;
        //delayedFFMready<=0;
    endfunction
    
    function void DataInit();
        M_AXIS_tdata<=0;
        M_AXIS_tkeep<=0;
        //store<=0; 
        //FFMready<=0;
        //Input_Data<=0;
    endfunction
    
    
    
   always @ (posedge ACLK)begin
        if(!ARESETN)begin
            init();
        end
        else if(M_AXIS_tready || state==0)begin
            if(state==Packet_Size)begin//last
                M_AXIS_tlast<=1;
                state<=state+1;
            end
            else if (state>Packet_Size) begin
                M_AXIS_tvalid<=0;
                M_AXIS_tlast<=0;
                state<=0;
            end
            else if (state!=0 )begin//middle
                //if recieved packet and subordinate is ready to accept incriment
                M_AXIS_tvalid<=1;
                state<=state+1;
            end
            else if (state==0 & !is_empty)begin//start
                state<=state+1;
                M_AXIS_tvalid<=1;
            end
        end
        else//else
            state <= state;

        //delayedFFMready<=FFMready;
   end
   
   always @ (posedge ACLK) begin
        if(!ARESETN)begin
            DataInit();
            counterPulseOutReg<=0;
        end
        else if(M_AXIS_tready || state==0)begin
            if(state==Packet_Size)begin 
                M_AXIS_tdata <= 64'h5704;
                M_AXIS_tkeep <= 8'h07;
                counterPulseOutReg<=0;
                //is_ready<=0;
            end            
            else if (state==0 || state>Packet_Size)begin
                //if recieved packet and subordinate is ready to accept incriment
                M_AXIS_tdata[63:48] <= Source_Address[15:0];
                M_AXIS_tdata[47:0] <= Destination_Address;
                M_AXIS_tkeep <= 8'hFF;
                counterPulseOutReg<=0;
                //is_ready<=0;
                end
            else if (state==1)begin
                //if recieved packet and subordinate is ready to accept incriment
                M_AXIS_tdata[63:48] <= SyncWord;
                M_AXIS_tdata[47:32] <= Link_Type;
                M_AXIS_tdata[31:0] <= Source_Address[47:16];
                M_AXIS_tkeep <= 8'hFF;
                counterPulseOutReg<=0;
                //is_ready<=1;//set ready to prepare data for the next cycle
                end
            else if (state>1 & state<Packet_Size)begin
                //if recieved packet and subordinate is ready to accept incriment
                //assuming that the queue in the subordinate will always contain an array of 0 no matter the amount of shifts
                
                //todo some catching system to catch an ongoing transfer when downstream is just recently paused

                M_AXIS_tdata <= Input_Data;
                M_AXIS_tkeep <= 8'hFF;
                
                // if(Input_Data!=64'h0000000000000000)begin
                //     counterPulseOutReg<=1;
                // end
                counterPulseOutReg<=1;

            end

        end
        else begin
            //store<=Input_Data;
            M_AXIS_tdata <= M_AXIS_tdata;// latching possible
            counterPulseOutReg<=0;
            
        end
        //FFMready <= (state>1 && state<Packet_Size) && M_AXIS_tready && !FFMready;//this last part is a bandaid to the problem that is caused by making FFMready a register
    end
endmodule
