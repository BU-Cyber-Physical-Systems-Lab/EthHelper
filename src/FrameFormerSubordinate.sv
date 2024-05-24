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
    input reg [INPUT_WIDTH-1:0] S_AXIS_tdata,
    input wire [7:0] S_AXIS_tkeep,
    input wire S_AXIS_tvalid,
    input wire S_AXIS_tlast,
    input wire S_AXIS_tready,
    input wire FramerReady,
    input wire FramerTready,
    output wire empty,
    output wire full,
    output wire [OUTPUT_WIDTH-1:0] tempOut,
    
    //for debug
    output wire [$clog2(MAX_INTERNAL_SPACE):0] FFSTail
    );
    

    
    
    
    //make register to buffer in case of slower downstream
    reg [INPUT_WIDTH-1:0] tempReg [MAX_INTERNAL_SPACE-1:0];
    reg[$clog2(MAX_INTERNAL_SPACE):0] i;
    
    //impliment shifting register
    reg[$clog2(MAX_INTERNAL_SPACE):0] tail;
    
    wire is_full = tail == MAX_INTERNAL_SPACE-1;
    
    wire InputCondition = !is_full & S_AXIS_tvalid;

    //reg FFMreadyReg;

    wire  OutputCondition = FramerReady;
    
    
       
    
    assign FFSTail=tail;
    
    assign empty = tail == 0;//framer will start the packet when not empty and then fetch if still not empty
    
    assign full = is_full;
    
    assign S_AXIS_tready = !is_full;//if the shifting reg is not full keep accepting //is this blocking or non blocking?

    assign tempOut=tempReg[0];

    function void shiftandOutput();
        //shift ALL the register values to the left and change the last register to be 0 unless that 
        //register is the tail register then it can be stale data (with the intention of being overwritten)
        for(i=0;i<=MAX_INTERNAL_SPACE-1;i=i+1)begin
            if(i != tail)begin 
                if(i==MAX_INTERNAL_SPACE-1)begin
                    tempReg[i]<= {((OUTPUT_WIDTH)){1'b0}};
                    break;
                end
                tempReg[i]<=tempReg[i+1];
            end
            else if(tail==0 & !InputCondition) begin
                tempReg[i]<=0;
            end
        end
       
    endfunction


    always @ (posedge ACLK)begin
        //reset condition
        //reset where the next available place for incoming data to the 0th spot
        //fill in the buffer to all 0 to prevent unwanted consequences of floating/uninitiated registers
        if(!ARESETN)begin
            tail <= 0;
            //FFMreadyReg<=0;
            for(i=0;i<MAX_INTERNAL_SPACE;i=i+1)begin //make every register 0 to avoid a floating register
                tempReg[i]<={((OUTPUT_WIDTH)){1'b0}};
            end

        end
        //if not in reset mode continue
        else begin
            //FFMreadyReg<=FramerReady;
            
            //if the buffer is not full and there is a valid, accept and put into buffer
            if (InputCondition & !OutputCondition)begin
                tempReg[tail] <= S_AXIS_tdata;
            end
            else begin
                tempReg[tail-1] <= S_AXIS_tdata;
            end
            
            //if the FFM (and whatever is downstream of the FFM) is ready to recieve then shift register
            //so that the output data wire can read the next value
            if(OutputCondition)begin
                shiftandOutput();
            end
            
            
            
            //update value based on the actions taken (which can happen in parallel)
            //However, before decrementing tail be sure that it is not in the 0th place
            tail <= tail + (InputCondition ? 1 : 0) - (OutputCondition && tail!=0 ? 1 : 0);
            
            
            //refresh the registers to prevent latching problems
            //if OutputCondition was asserted then do not refresh the buffer as the shifting will do that
            //if InputCondtion was asserted then refresh every register but not the tail register 
            //if InputCondition was not asserted then refresh every register 
            for(i=0; i<MAX_INTERNAL_SPACE-1 && !OutputCondition & !InputCondition; i=i+1)begin //may not be space optimized
                if(InputCondition && i!=tail)
                    tempReg[i]<=tempReg[i];
                else if(!InputCondition)
                    tempReg[i]<=tempReg[i];
            end
            //***NOTE*** there will never be two inputs in the buffer in one clock cycle
            //meaning that if input condition is met then do not refresh tail register
            //if input condition is not met then refresh every register
        end 
    end    
    
endmodule
