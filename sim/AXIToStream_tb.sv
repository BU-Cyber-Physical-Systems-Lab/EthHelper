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

import axi4stream_vip_pkg::*;
import axi_vip_pkg::*;
import AXIToStream_test_axi4stream_vip_0_0_pkg::*;
import AXIToStream_test_axi_vip_0_0_pkg::*;
import AXIToStream_test_axi_vip_1_0_pkg::*;

module AXIToStream_tb ();

  bit clk, resetn;

  //Instantiate the laock design wrapper and connect external pins
  AXIToStream_test_wrapper #() ats_test (
      .aclk_0(clk),
      .aresetn_0(resetn)

  );

  // Declare AXI agents
  AXIToStream_test_axi4stream_vip_0_0_slv_t stream_slave_agent;
  AXIToStream_test_axi_vip_0_0_slv_mem_t slave_agent;
  AXIToStream_test_axi_vip_1_0_mst_t master_agent;

  //Declare the transaction and ready objects
  axi_transaction wr_transaction, rd_transaction;
  axi4stream_ready_gen ready_gen;

  // Generate a clock signal
  always #5ns clk <= ~clk;

  // start the simulation
  initial begin
    // Reset all modules
    resetn <= 0;
    // @bug vivado 2019.2 complains the reset signal is asserted after 20ns
    #10ns;
    resetn <= 1;

    // Create the agents
    stream_slave_agent =
        new("AXI4Stream slave agent", ats_test.AXIToStream_test_i.axi4stream_vip_0.inst.IF);
    slave_agent = new("AXI slave agent", ats_test.AXIToStream_test_i.axi_vip_0.inst.IF);
    master_agent = new("AXI master agent", ats_test.AXIToStream_test_i.axi_vip_1.inst.IF);

    // We wantthe agents to have a unique number and to be pedantic in the console, so we know if we violate the protocol
    master_agent.set_agent_tag("AXI master");
    master_agent.set_verbosity(400);
    slave_agent.set_agent_tag("AXI slave");
    slave_agent.set_verbosity(400);
    stream_slave_agent.set_agent_tag("AXI stream slave");
    stream_slave_agent.set_verbosity(400);

    // The stream slave needs a policy to generate the ready signal
    ready_gen = stream_slave_agent.driver.create_ready("stream ready gen");
    // This policy generates a read per transaction for a confgiurable high and low times.
    // More policies are available in the VIP class hierarchy documentation
    ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_SINGLE);
    ready_gen.set_low_time(5);
    ready_gen.set_high_time(5);


    // Now that all objects have been created and configured we need to start the agents.
    master_agent.start_master();
    slave_agent.start_slave();
    stream_slave_agent.start_slave();

    // The master creates a random write transaction
    wr_transaction = master_agent.wr_driver.create_transaction("write transaction");
    assert (wr_transaction.randomize());

    // The master creates a random read transaction
    rd_transaction = master_agent.rd_driver.create_transaction("read transaction");
    assert (rd_transaction.randomize());

    // We send the read transaction
    master_agent.rd_driver.send(rd_transaction);
    // The stream slave generates a ready signal otherwise we will be stuck forever
    stream_slave_agent.driver.send_tready(ready_gen);
    // We send the write transaction
    // master_agent.wr_driver.send(wr_transaction);
    // And like before, we make the slave accept the transaction
    //stream_slave_agent.driver.send_tready(ready_gen);

    // Before endind the simulation, we need to make sure that the transactions are executed so we explictily wait until all the drivers in the master vip are idling
    master_agent.wait_drivers_idle();
    //@todo: reset only the streaming module and check if transactions still go trough
    master_agent.wr_driver.send(wr_transaction);
    
    stream_slave_agent.driver.send_tready(ready_gen);
    
    assert (rd_transaction.randomize());

    // We send the read transaction
    master_agent.rd_driver.send(rd_transaction);
    
    master_agent.wait_drivers_idle();
    //$finish;
  end

endmodule
