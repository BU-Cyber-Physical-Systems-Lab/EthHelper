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

module FrameFormerSubordinate # (
    parameter integer MAX_INTERNAL_SPACE = 64,
    parameter integer OUTPUT_WIDTH = 64,
    parameter integer INPUT_WIDTH = 64 
    )(
    input wire ACLK,
    input wire ARESETN,
    
    //subordinate
    input wire [INPUT_WIDTH-1:0] S_AXIS_tdata,
    input wire [7:0] S_AXIS_tkeep,
    input wire S_AXIS_tvalid,
    input wire S_AXIS_tlast,
    input wire S_AXIS_tready,
    input wire FramerReady,
    input wire FramerTready,
    output wire empty,
    output wire full,
    output wire [OUTPUT_WIDTH-1:0] tempOut,
    output wire [OUTPUT_WIDTH-1:0] Delayed_Data_Transfer,
    
    //for debug
    output wire [$clog2(MAX_INTERNAL_SPACE):0] FFSTail
    );
    

    

    
    //make register to buffer in case of slower downstream
    reg [INPUT_WIDTH-1:0] tempReg [MAX_INTERNAL_SPACE-1:0];
    reg[$clog2(MAX_INTERNAL_SPACE):0] i;
    
    //impliment shifting register
    reg[$clog2(MAX_INTERNAL_SPACE):0] tail;
    
    //reg FramerDelayedReady;
   
    
    assign S_AXIS_tready = !full;//if the shifting reg is not full keep accepting //is this blocking or non blocking?

    
    wire InputCondition = S_AXIS_tready & S_AXIS_tvalid;
    
    wire  OutputCondition = FramerReady;
    
    reg[OUTPUT_WIDTH-1:0] delayedOut;

    assign Delayed_Data_Transfer = delayedOut; 
       
    
    assign FFSTail=tail;
    
    assign empty = tail == 0;//framer will start the packet when not empty and then fetch if still not empty
    
    assign full =  tail == MAX_INTERNAL_SPACE;
    
    assign tempOut=tempReg[0];

    function void shiftandOutput();
        for (i=0; i<MAX_INTERNAL_SPACE; i++)begin
            if (i==MAX_INTERNAL_SPACE-1) begin
              //fill it with 0
              tempReg[i]<= {((OUTPUT_WIDTH)){1'b0}};
            end
            else begin
                tempReg[i]=tempReg[i+1];
            end
        end
    endfunction

    function void shiftOutputInsert();
        for (i=0; i<MAX_INTERNAL_SPACE; i++)begin
            if (i==(tail==0 ? 0:tail-1)) begin
              tempReg[i]<=S_AXIS_tdata;
            end
            else if (i==MAX_INTERNAL_SPACE-1 & tail!=MAX_INTERNAL_SPACE-1) begin
              //fill it with 0
              tempReg[i]<= {((OUTPUT_WIDTH)){1'b0}};
            end
            else if (i!=MAX_INTERNAL_SPACE-1) begin
              tempReg[i]<=tempReg[i+1];
            end
        end
    endfunction

//tail <= tail + (InputCondition ? 1 : 0) - (OutputCondition & tail!=0 ? 1 : 0);

    always @ (posedge ACLK)begin
        //reset condition
        //reset where the next available place for incoming data to the 0th spot
        //fill in the buffer to all 0 to prevent unwanted consequences of floating/uninitiated registers
        if(!ARESETN)begin
            tail <= 0;
            //FramerDelayedReady<=0;
            for(i=0;i<MAX_INTERNAL_SPACE;i=i+1)begin //make every register 0 to avoid a floating register
                tempReg[i]<={((OUTPUT_WIDTH)){1'b0}};
            end
            delayedOut<=0;

        end
        else begin

            if(InputCondition & !OutputCondition)begin
                tempReg[tail]<=S_AXIS_tdata;
                tail<=tail+1;
            end
            else if(OutputCondition & !InputCondition)begin
                shiftandOutput();
                if (tail!=0)
                    tail<=tail-1;
                delayedOut<=tempOut;
            end
            else if(OutputCondition & InputCondition)begin
                shiftOutputInsert();
                if(empty)
                    tail<=tail+1;
                else
                    tail<=tail;
                delayedOut<=tempOut;
            end
            else begin
                for(i=0;i<MAX_INTERNAL_SPACE;i=i+1)begin //make every register 0 to avoid a floating register
                    tempReg[i]<=tempReg[i];
                end
            end
        end 
        
    end    
    
endmodule
