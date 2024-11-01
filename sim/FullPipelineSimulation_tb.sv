`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/25/2024 02:44:04 PM
// Design Name:
// Module Name: AXIToStream_tb
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
import axi_vip_pkg::*;
import FullPipelineSimulation_axi_vip_0_0_pkg::*;

module FullPipelineSimulation_tb ();

  bit clk, resetn;
  bit [6:0] Sub_Resets;
  bit [47:0]Destination_Address;
  bit [15:0]Link_Type;
  bit [13:0]Packet_Size;
  bit [47:0]Source_Address;
  bit [15:0] SyncWord, ResetAfter, ResetWidth;
  bit [2:0]rxoutclksel_in;
  bit [2:0]txoutclksel_in;
  //bit tx_reset;

  //Instantiate the laock design wrapper and connect external pins
  FullPipelineSimulation_wrapper #() FullPipelineSimulation_test (
        .Destination_Address_0(Destination_Address),
        .Link_Type_0(Link_Type),
        .Packet_Size_0(Packet_Size),
        .Source_Address_0(Source_Address),
        .SyncWord_0(SyncWord),
        .rxoutclksel_in_0_0(rxoutclksel_in),
        .txoutclksel_in_0_0(txoutclksel_in),
        .submodule_resets_0(Sub_Resets),
        .ResetAfter_0(ResetAfter),
        .ResetWidth_0(ResetWidth)
        
  );

  assign Destination_Address='hdeadbeefcafe;
  assign Source_Address='hcafebabe2024;
  assign Link_Type='h1337;
  assign Packet_Size=23;
  assign SyncWord='hb00b;
  assign rxoutclksel_in='b101;
  assign txoutclksel_in='b101;
  
  
  assign ResetWidth=5;
  assign ResetAfter='h100;


  FullPipelineSimulation_axi_vip_0_0_mst_t master_agent;

  //Declare the transaction and ready objects
  axi_transaction wr_transaction, rd_transaction;
  
  xil_axi_size_t bus_size = XIL_AXI_SIZE_16BYTE;//3'b111;
  xil_axi_size_t reg_size_4 = XIL_AXI_SIZE_4BYTE;//3'b111;
  xil_axi_size_t reg_size_8 = XIL_AXI_SIZE_8BYTE;//3'b111;
  xil_axi_burst_t burst = XIL_AXI_BURST_TYPE_FIXED;//2'b01;
  xil_axi_lock_t lock = XIL_AXI_ALOCK_NOLOCK;//2'b00;
  xil_axi_data_beat ruser;
  xil_axi_prot_t  prot = 0;
  xil_axi_resp_t 	[255:0] resp;
  bit   [1 : 0]   bus_size_len = 0;
  xil_axi_len_t burstLength=0;
  xil_axi_uint inflight=16;

  xil_axi_ulong bram_addr= 32'h20000000;
  int loop=0;

  // Generate a clock signal
  always #5ns clk <= ~clk;

  // start the simulation
  initial begin
    Sub_Resets<='b000111;

    // Reset all modules
    resetn <= 1;
    //tx_reset=0;
    // @bug vivado 2019.2 complains the reset signal is asserted after 20ns
    #10ns;
    
    resetn <= 0;

    

    // Create the agents
    master_agent = new("AXI master agent", FullPipelineSimulation_test.FullPipelineSimulation_i.axi_vip_0.inst.IF);

    // We wantthe agents to have a unique number and to be pedantic in the console, so we know if we violate the protocol
    master_agent.set_agent_tag("AXI master");
    master_agent.set_verbosity(400);
    master_agent.set_nobackpressure_readies();
    master_agent.set_wr_transaction_depth(inflight);
    #7us;
    //tx_reset=1;
    //#25.6ns;
    //tx_reset=0;

    // Now that all objects have been created and configured we need to start the agents.
    master_agent.start_master();
    master_agent.wait_drivers_idle();
  
    // The master creates a random write transaction
    wr_transaction = new("write Bram transaction",0,64,128);
    //master_agent.AXI4_WRITE_BURST('h1,'h00000000,'h0,XIL_AXI_SIZE_16BYTE,0,XIL_AXI_ALOCK_NOLOCK,0,0,0,0,'hb00bcafe,0,XIL_AXI_RESP_OKAY);
    master_agent.AXI4_WRITE_BURST(1,bram_addr,burstLength,reg_size_4,burst,lock,4'h0,prot, 4'h0, 4'h0, 1'h0,128'hb00bcafe,1,resp);
    
    
// Before endind the simulation, we need to make sure that the transactions are executed so we explictily wait until all the drivers in the master vip are idling
    for(loop=0; loop<10;loop++)begin
        //master_agent.wait_drivers_idle();
        master_agent.AXI4_WRITE_BURST(1,bram_addr,bus_size_len,reg_size_4,burst,lock,4'h0,prot, 4'h0, 4'h0, 1'h0,128'hdeadbeef1337,1,resp);
    end
    // //$finish;
  end

endmodule
