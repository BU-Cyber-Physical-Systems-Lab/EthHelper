`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2023 06:19:21 PM
// Design Name: 
// Module Name: SinglePacketEthHelper
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


module SinglePacketEthHelper# (
    parameter integer MAX_INTERNAL_SPACE = 64,
    parameter integer OUTPUT_WIDTH = 64,
    parameter integer INPUT_WIDTH = 64 
    )
   (ACLK,
    ARESETN,
    S_AXIS_tdata,
    S_AXIS_tready,
    S_AXIS_tkeep,
    S_AXIS_tvalid,
    Destination_Addr,
    Source_Addr,
    Link_Type,
    SyncWord,
    M_AXIS_tdata,
    M_AXIS_tready,
    M_AXIS_tkeep,
    M_AXIS_tvalid,
    M_AXIS_tlast
    );
    
    input wire ACLK;
    input wire ARESETN;
    
    //subordinate
    input reg [INPUT_WIDTH-1:0] S_AXIS_tdata;
    output reg S_AXIS_tready;
    input wire [7:0] S_AXIS_tkeep;
    input wire S_AXIS_tvalid;
    
    //manager
    output reg [OUTPUT_WIDTH-1:0] M_AXIS_tdata;
    input wire M_AXIS_tready;
    output reg [7:0] M_AXIS_tkeep;
    output reg M_AXIS_tvalid;
    output reg M_AXIS_tlast;
    
    //specific helper values
    input wire [47:0] Destination_Addr;
    input wire [47:0] Source_Addr;
    input wire [15:0] Link_Type;
    input wire [15:0] SyncWord;
    
    reg[63:0] state;
    reg [INPUT_WIDTH-1:0] tempReg;
    wire[63:0] tempWire;
    
    
    function void init();
        state<=0;
        M_AXIS_tlast<=0;
        M_AXIS_tvalid<=0;
        S_AXIS_tready<=0;
    endfunction
    
    function void DataInit();
        M_AXIS_tdata<=0;
        M_AXIS_tkeep<=0;
    endfunction
    
    
    
    always @ (posedge ACLK) begin
        if(!ARESETN)begin
            init();
            end
        else if(state==8 && M_AXIS_tready)begin
            M_AXIS_tlast<=1;
            state<=0;
            end
        else if (state!=0 && M_AXIS_tready)begin
            //if recieved packet and subordinate is ready to accept incriment
            state<=state+1;
            end
        else if (S_AXIS_tvalid && state==0)begin
            //accept only one packet of axi at a time 
            state <= state+1;
            S_AXIS_tready<=0;
            M_AXIS_tvalid<=1;
            end
        else if (state==0)begin
            M_AXIS_tvalid<=0;
            M_AXIS_tlast<=0;
            S_AXIS_tready<=1;
        end
        else
            state <= state;
     end
     

     
    always @ (posedge ACLK) begin
        if(!ARESETN)begin
            DataInit();
        end
        else if(state==8 && M_AXIS_tready)begin 
            M_AXIS_tdata <= 64'h1337;
            M_AXIS_tkeep <= 8'h07;
            state<=0;
        end         
        else if (state==1 && M_AXIS_tready)begin
            //if recieved packet and subordinate is ready to accept incriment
            M_AXIS_tdata[63:48] <= Source_Addr[15:0];
            //M_AXIS_tdata <= (M_AXIS_tdata << 48);
            M_AXIS_tdata[47:0] <= Destination_Addr;
            M_AXIS_tkeep <= 8'hFF;
            end
        else if (state==2 && M_AXIS_tready)begin
            //if recieved packet and subordinate is ready to accept incriment
            M_AXIS_tdata[63:48] <= SyncWord;
            M_AXIS_tdata[47:32] <= Link_Type;
            M_AXIS_tdata[31:0] <= Source_Addr[47:16];
            M_AXIS_tkeep <= 8'hFF;
            end            
        else if (state == 5 && M_AXIS_tready)begin
            //send data after start of frame and some padding
            M_AXIS_tdata <= tempReg;
            M_AXIS_tkeep <= 8'hFF;
            end
        else if (state!=0 && M_AXIS_tready)begin
            //if recieved packet and subordinate is ready to accept incriment
            M_AXIS_tdata <= {((OUTPUT_WIDTH)){1'b0}};
            M_AXIS_tkeep <= 8'hFF;
            end
        else if (S_AXIS_tvalid && state==0)begin
            //accept only one packet of axi at a time 
            tempReg<=S_AXIS_tdata;
            end
        else
            tempReg <= tempReg;// latching possible
      end 
    
endmodule
