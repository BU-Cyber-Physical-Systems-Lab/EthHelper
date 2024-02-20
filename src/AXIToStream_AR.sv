`timescale 1ns / 1ps
/** @file AXIToStream_AR.sv
 * @brief Snoop AXI4 AR transaction and send a copy of their data from the
 *  AXIStream port.
 * @author Mattia Nicolella
 */

/** @brief Snoop AXI4 AR transaction and send a copy of their data from the
 *  AXIStream port.
 * @details This module acts as a passtrough between an AXI4 master/slave,
 * while creating an equivalent transaction from the AXIStream master.
 */
module AXIToStream_AR #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 32,
    parameter BURST_LEN = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64,
    parameter STREAM_TYPE = 3'b0,
    parameter STREAM_TYPE_WIDTH = 3
) (
    //module inputs pins
    input  wire                  clk,
    input  wire                  resetn,
    input  wire                  can_forwardAR,
    //module output pins
    output wire                  output_valid,
    output wire [DATA_WIDTH-1:0] output_data,
    // AXI Slave (input wire) interface, will snoop a transaction
    input  wire [  ID_WIDTH-1:0] snoop_arid,
    input  wire [ADDR_WIDTH-1:0] snoop_araddr,
    input  wire [ BURST_LEN-1:0] snoop_arlen,
    input  wire [           2:0] snoop_arsize,
    input  wire [           1:0] snoop_arburst,
    input  wire [LOCK_WIDTH-1:0] snoop_arlock,
    input  wire [           3:0] snoop_arcache,
    input  wire [           2:0] snoop_arprot,
    input  wire [           3:0] snoop_arregion,
    input  wire [           3:0] snoop_arqos,
    input  wire [USER_WIDTH-1:0] snoop_aruser,
    input  wire                  snoop_arvalid,
    output wire                  snoop_arready,
    // AXI master (output wire) Interface, will forward the snooped transaction to destination
    output wire [  ID_WIDTH-1:0] forward_arid,
    output wire [ADDR_WIDTH-1:0] forward_araddr,
    output wire [ BURST_LEN-1:0] forward_arlen,
    output wire [           2:0] forward_arsize,
    output wire [           1:0] forward_arburst,
    output wire [LOCK_WIDTH-1:0] forward_arlock,
    output wire [           3:0] forward_arcache,
    output wire [           2:0] forward_arprot,
    output wire [           3:0] forward_arregion,
    output wire [           3:0] forward_arqos,
    output wire [USER_WIDTH-1:0] forward_aruser,
    output wire                  forward_arvalid,
    input  wire                  forward_arready
);
  assign forward_arid = snoop_arid;
  assign forward_araddr = snoop_araddr;
  assign forward_arlen = snoop_arlen;
  assign forward_arsize = snoop_arsize;
  assign forward_arburst = snoop_arburst;
  assign forward_arlock = snoop_arlock;
  assign forward_arcache = snoop_arcache;
  assign forward_arprot = snoop_arprot;
  assign forward_arregion = snoop_arregion;
  assign forward_arqos = snoop_arqos;
  assign forward_aruser = snoop_aruser;
  assign forward_arvalid = snoop_arvalid && can_forwardAR;
  assign snoop_arready = forward_arready && can_forwardAR;
	//out data is valid only when there is a handshake and we are not in reset state
	assign output_valid = resetn && snoop_arvalid && forward_arready;
	// the output data is composed as follows
	assign output_data = {STREAM_TYPE, snoop_arid, snoop_arlen, {DATA_WIDTH-STREAM_TYPE_WIDTH-ID_WIDTH-BURST_LEN-ADDR_WIDTH{1'b0}},snoop_araddr};
endmodule
