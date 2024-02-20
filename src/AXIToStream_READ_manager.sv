`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2024 05:29:35 PM
// Design Name: 
// Module Name: AXIToStream_READ_manager
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


module AXIToStream_READ_manager#(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 32,
    parameter BURST_LEN = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64,
    parameter DEST_WIDTH = 32,
    parameter STREAM_TYPE_WIDTH = 3,
    localparam STREAM_DATA_WIDTH = DATA_WIDTH + STREAM_TYPE_WIDTH + ADDR_WIDTH + (DATA_WIDTH / 8)
) (
    input  wire                    clk,
    input  wire                    resetn,
    // AXI Slave (input wire) interface, will Fake_Sub a transaction
    input  wire [    ID_WIDTH-1:0] Fake_Sub_awid,
    input  wire [  ADDR_WIDTH-1:0] Fake_Sub_awaddr,
    input  wire [   BURST_LEN-1:0] Fake_Sub_awlen,
    input  wire [             2:0] Fake_Sub_awsize,
    input  wire [             1:0] Fake_Sub_awburst,
    input  wire [  LOCK_WIDTH-1:0] Fake_Sub_awlock,
    input  wire [             3:0] Fake_Sub_awcache,
    input  wire [             2:0] Fake_Sub_awprot,
    input  wire [             3:0] Fake_Sub_awregion,
    input  wire [             3:0] Fake_Sub_awqos,
    input  wire [  USER_WIDTH-1:0] Fake_Sub_awuser,
    input  wire                    Fake_Sub_awvalid,
    output wire                    Fake_Sub_awready,
    input  wire [    ID_WIDTH-1:0] Fake_Sub_wid,
    input  wire [  DATA_WIDTH-1:0] Fake_Sub_wdata,
    input  wire [DATA_WIDTH/8-1:0] Fake_Sub_wstrb,
    input  wire                    Fake_Sub_wlast,
    input  wire [  USER_WIDTH-1:0] Fake_Sub_wuser,
    input  wire                    Fake_Sub_wvalid,
    output wire                    Fake_Sub_wready,
    output wire [    ID_WIDTH-1:0] Fake_Sub_bid,
    output wire [             1:0] Fake_Sub_bresp,
    output wire [  USER_WIDTH-1:0] Fake_Sub_buser,
    output wire                    Fake_Sub_bvalid,
    input  wire                    Fake_Sub_bready,
    input  wire [    ID_WIDTH-1:0] Fake_Sub_arid,
    input  wire [  ADDR_WIDTH-1:0] Fake_Sub_araddr,
    input  wire [   BURST_LEN-1:0] Fake_Sub_arlen,
    input  wire [             2:0] Fake_Sub_arsize,
    input  wire [             1:0] Fake_Sub_arburst,
    input  wire [  LOCK_WIDTH-1:0] Fake_Sub_arlock,
    input  wire [             3:0] Fake_Sub_arcache,
    input  wire [             2:0] Fake_Sub_arprot,
    input  wire [             3:0] Fake_Sub_arregion,
    input  wire [             3:0] Fake_Sub_arqos,
    input  wire [  USER_WIDTH-1:0] Fake_Sub_aruser,
    input  wire                    Fake_Sub_arvalid,
    output wire                    Fake_Sub_arready,
    output wire [    ID_WIDTH-1:0] Fake_Sub_rid,
    output wire [  DATA_WIDTH-1:0] Fake_Sub_rdata,
    output wire [             1:0] Fake_Sub_rresp,
    output wire                    Fake_Sub_rlast,
    output wire [  USER_WIDTH-1:0] Fake_Sub_ruser,
    output wire                    Fake_Sub_rvalid,
    input  wire                    Fake_Sub_rready,
    // AXI master (output wire) Interface, will Real_Sub the Fake_Subed transaction to destination
    output wire [    ID_WIDTH-1:0] Real_Sub_awid,
    output wire [  ADDR_WIDTH-1:0] Real_Sub_awaddr,
    output wire [   BURST_LEN-1:0] Real_Sub_awlen,
    output wire [             2:0] Real_Sub_awsize,
    output wire [             1:0] Real_Sub_awburst,
    output wire [  LOCK_WIDTH-1:0] Real_Sub_awlock,
    output wire [             3:0] Real_Sub_awcache,
    output wire [             2:0] Real_Sub_awprot,
    output wire [             3:0] Real_Sub_awregion,
    output wire [             3:0] Real_Sub_awqos,
    output wire [  USER_WIDTH-1:0] Real_Sub_awuser,
    output wire                    Real_Sub_awvalid,
    input  wire                    Real_Sub_awready,
    output wire [    ID_WIDTH-1:0] Real_Sub_wid,
    output wire [  DATA_WIDTH-1:0] Real_Sub_wdata,
    output wire [DATA_WIDTH/8-1:0] Real_Sub_wstrb,
    output wire                    Real_Sub_wlast,
    output wire [  USER_WIDTH-1:0] Real_Sub_wuser,
    output wire                    Real_Sub_wvalid,
    input  wire                    Real_Sub_wready,
    input  wire [    ID_WIDTH-1:0] Real_Sub_bid,
    input  wire [             1:0] Real_Sub_bresp,
    input  wire [  USER_WIDTH-1:0] Real_Sub_buser,
    input  wire                    Real_Sub_bvalid,
    output wire                    Real_Sub_bready,
    output wire [    ID_WIDTH-1:0] Real_Sub_arid,
    output wire [  ADDR_WIDTH-1:0] Real_Sub_araddr,
    output wire [   BURST_LEN-1:0] Real_Sub_arlen,
    output wire [             2:0] Real_Sub_arsize,
    output wire [             1:0] Real_Sub_arburst,
    output wire [  LOCK_WIDTH-1:0] Real_Sub_arlock,
    output wire [             3:0] Real_Sub_arcache,
    output wire [             2:0] Real_Sub_arprot,
    output wire [             3:0] Real_Sub_arregion,
    output wire [             3:0] Real_Sub_arqos,
    output wire [  USER_WIDTH-1:0] Real_Sub_aruser,
    output wire                    Real_Sub_arvalid,
    input  wire                    Real_Sub_arready,
    input  wire [    ID_WIDTH-1:0] Real_Sub_rid,
    input  wire [  DATA_WIDTH-1:0] Real_Sub_rdata,
    input  wire [             1:0] Real_Sub_rresp,
    input  wire                    Real_Sub_rlast,
    input  wire [  USER_WIDTH-1:0] Real_Sub_ruser,
    input  wire                    Real_Sub_rvalid,
    output wire                    Real_Sub_rready,
    // AXI stream Master (stream output wire) interface
    output wire [    ID_WIDTH-1:0] stream_tid,
    output wire [  DEST_WIDTH-1:0] stream_tdest,
    output wire [  DATA_WIDTH-1:0] stream_tdata,
    output wire [DATA_WIDTH/8-1:0] stream_tstrb,
    output wire [DATA_WIDTH/8-1:0] stream_tkeep,
    output wire                    stream_tlast,
    output wire [  USER_WIDTH-1:0] stream_tuser,
    output wire                    stream_tvalid,
    input  wire                    stream_tready
    );
    
    reg [DATA_WIDTH-1:0] tempData;
    reg can_forwardAR;
    wire AR_valid;
    
  AXIToStream_AR #(
    DATA_WIDTH,
    ADDR_WIDTH,
    ID_WIDTH,
    BURST_LEN,
    LOCK_WIDTH,
    USER_WIDTH,
    DEST_WIDTH,
    STREAM_TYPE_WIDTH,
    ) Address_Reader (
    .clk(clk),
    .resetn(resetn),
    .can_forwardAR(can_forwardAR),
    .output_valid(AR_Valid),
    .output_data(tempData),
    .snoop_arid(Fake_Sub_arid),
    .snoop_araddr(Fake_Sub_araddr),
    .snoop_arlen(Fake_Sub_arlen),
    .snoop_arsize(Fake_Sub_arsize),
    .snoop_arburst(Fake_Sub_arburst),
    .snoop_arlock(Fake_Sub_arlock),
    .snoop_arcache(Fake_Sub_arcache),
    .snoop_arprot(Fake_Sub_arprot),
    .snoop_arregion(Fake_Sub_arregion),
    .snoop_arqos(Fake_Sub_arqos),
    .snoop_aruser(Fake_Sub_aruser),
    .snoop_arread(Fake_Sub_arready)
    );
    
    
    AXIToStream_R #(
    DATA_WIDTH,
    ADDR_WIDTH,
    ID_WIDTH,
    BURST_LEN,
    LOCK_WIDTH,
    USER_WIDTH,
    DEST_WIDTH,
    STREAM_TYPE_WIDTH,
    )
    
endmodule
