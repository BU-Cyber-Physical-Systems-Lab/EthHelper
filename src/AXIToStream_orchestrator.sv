`timescale 1ns / 1ps
/** @file AXIToStream_orchestrator.sv
 * @brief 
 * @author 
 */

/** @brief orchestrator top module Axi to axistream translation
 * @details 
 *
 * 
 */

//todo


module AXIToStream_orchestrator #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 32,
    parameter BURST_LEN = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64,
    parameter DEST_WIDTH = 32,
    parameter STREAM_TYPE_WIDTH = 3,
    // how many channels this module supports
    localparam channels = 5
    //the bit needed to represent this channels in binary
    localparam channels_bits = $clog(channels)

) (
    input  wire                    clk,
    input  wire                    resetn,
    // AXI Slave (input wire) interface, will AXIS a transaction
    input  wire [    ID_WIDTH-1:0] AXIS_awid,
    input  wire [  ADDR_WIDTH-1:0] AXIS_awaddr,
    input  wire [   BURST_LEN-1:0] AXIS_awlen,
    input  wire [             2:0] AXIS_awsize,
    input  wire [             1:0] AXIS_awburst,
    input  wire [  LOCK_WIDTH-1:0] AXIS_awlock,
    input  wire [             3:0] AXIS_awcache,
    input  wire [             2:0] AXIS_awprot,
    input  wire [             3:0] AXIS_awregion,
    input  wire [             3:0] AXIS_awqos,
    input  wire [  USER_WIDTH-1:0] AXIS_awuser,
    input  wire                    AXIS_awvalid,
    output wire                    AXIS_awready,
    input  wire [    ID_WIDTH-1:0] AXIS_wid,
    input  wire [  DATA_WIDTH-1:0] AXIS_wdata,
    input  wire [DATA_WIDTH/8-1:0] AXIS_wstrb,
    input  wire                    AXIS_wlast,
    input  wire [  USER_WIDTH-1:0] AXIS_wuser,
    input  wire                    AXIS_wvalid,
    output wire                    AXIS_wready,
    output wire [    ID_WIDTH-1:0] AXIS_bid,
    output wire [             1:0] AXIS_bresp,
    output wire [  USER_WIDTH-1:0] AXIS_buser,
    output wire                    AXIS_bvalid,
    input  wire                    AXIS_bready,
    input  wire [    ID_WIDTH-1:0] AXIS_arid,
    input  wire [  ADDR_WIDTH-1:0] AXIS_araddr,
    input  wire [   BURST_LEN-1:0] AXIS_arlen,
    input  wire [             2:0] AXIS_arsize,
    input  wire [             1:0] AXIS_arburst,
    input  wire [  LOCK_WIDTH-1:0] AXIS_arlock,
    input  wire [             3:0] AXIS_arcache,
    input  wire [             2:0] AXIS_arprot,
    input  wire [             3:0] AXIS_arregion,
    input  wire [             3:0] AXIS_arqos,
    input  wire [  USER_WIDTH-1:0] AXIS_aruser,
    input  wire                    AXIS_arvalid,
    output wire                    AXIS_arready,
    output wire [    ID_WIDTH-1:0] AXIS_rid,
    output wire [  DATA_WIDTH-1:0] AXIS_rdata,
    output wire [             1:0] AXIS_rresp,
    output wire                    AXIS_rlast,
    output wire [  USER_WIDTH-1:0] AXIS_ruser,
    output wire                    AXIS_rvalid,
    input  wire                    AXIS_rready,
    // AXI master (output wire) Interface, will AXIM the AXISed transaction to destination
    output wire [    ID_WIDTH-1:0] AXIM_awid,
    output wire [  ADDR_WIDTH-1:0] AXIM_awaddr,
    output wire [   BURST_LEN-1:0] AXIM_awlen,
    output wire [             2:0] AXIM_awsize,
    output wire [             1:0] AXIM_awburst,
    output wire [  LOCK_WIDTH-1:0] AXIM_awlock,
    output wire [             3:0] AXIM_awcache,
    output wire [             2:0] AXIM_awprot,
    output wire [             3:0] AXIM_awregion,
    output wire [             3:0] AXIM_awqos,
    output wire [  USER_WIDTH-1:0] AXIM_awuser,
    output wire                    AXIM_awvalid,
    input  wire                    AXIM_awready,
    output wire [    ID_WIDTH-1:0] AXIM_wid,
    output wire [  DATA_WIDTH-1:0] AXIM_wdata,
    output wire [DATA_WIDTH/8-1:0] AXIM_wstrb,
    output wire                    AXIM_wlast,
    output wire [  USER_WIDTH-1:0] AXIM_wuser,
    output wire                    AXIM_wvalid,
    input  wire                    AXIM_wready,
    input  wire [    ID_WIDTH-1:0] AXIM_bid,
    input  wire [             1:0] AXIM_bresp,
    input  wire [  USER_WIDTH-1:0] AXIM_buser,
    input  wire                    AXIM_bvalid,
    output wire                    AXIM_bready,
    output wire [    ID_WIDTH-1:0] AXIM_arid,
    output wire [  ADDR_WIDTH-1:0] AXIM_araddr,
    output wire [   BURST_LEN-1:0] AXIM_arlen,
    output wire [             2:0] AXIM_arsize,
    output wire [             1:0] AXIM_arburst,
    output wire [  LOCK_WIDTH-1:0] AXIM_arlock,
    output wire [             3:0] AXIM_arcache,
    output wire [             2:0] AXIM_arprot,
    output wire [             3:0] AXIM_arregion,
    output wire [             3:0] AXIM_arqos,
    output wire [  USER_WIDTH-1:0] AXIM_aruser,
    output wire                    AXIM_arvalid,
    input  wire                    AXIM_arready,
    input  wire [    ID_WIDTH-1:0] AXIM_rid,
    input  wire [  DATA_WIDTH-1:0] AXIM_rdata,
    input  wire [             1:0] AXIM_rresp,
    input  wire                    AXIM_rlast,
    input  wire [  USER_WIDTH-1:0] AXIM_ruser,
    input  wire                    AXIM_rvalid,
    output wire                    AXIM_rready,
    // AXI stream Master (stream output wire) interface
    output wire [    ID_WIDTH-1:0] stream_tid,
    output wire [  DEST_WIDTH-1:0] stream_tdest,
    output wire [  DATA_WIDTH-1:0] stream_tdata,
    output wire [DATA_WIDTH/8-1:0] stream_tstrb,
    output wire [DATA_WIDTH/8-1:0] stream_tkeep,
    output wire                    stream_tlast,
    output wire [  USER_WIDTH-1:0] stream_tuser,
    output wire                    stream_tvalid,
    input  wire                    stream_tready,

    
);

//send reset to individual submodules (and keep unwanted submodules in reset)
reg resets[channels-1:0];

// how the top module signals a specific sumodule that the transaction can proceed
wire [channels-1:0] ready;

// how the submodules will signa to the top module that they have valid data (after having detected a handshake between the two orginal axi interfaces), or a multi-clock cycle transaction is still in progress (e.g. R/w).
wire [channels-1:0] valid, in_progress;

enum {NONE_HOT= 5b'00000, AR_HOT=5'b00001,AW_HOT=5'b00010} hot;

// since everything is relative to last_index we need also the one-hot encodings for the ready to be realtive to last_index
reg [channels-1:0][channels-1:0] encodings;

//finally also the data that we send to the AXI4stream has to be relative to last_index
wire [channels-1:0][channels-1:0] submodule_data;

//to implement round robin we need a register that will cycle between all the possible channels (when they are valid)
enum reg [channels_bits-1:0] {AR=0,AW=1,R=2,W=3,B=4} last_index;





AXIToStream_Ax # (
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .BURST_LEN(BURST_LEN),
    .LOCK_WIDTH(LOCK_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .STREAM_TYPE_WIDTH(STREAM_TYPE_WIDTH = 3)
) AR (
    .clk(clk),
    .resetn(resetn[0]),
    .ready(ready[0]),
    .valid(valid[0]),
    .data(submodule_data[0]),
    .in_progress(in_progress[0]),

    //subordinate 
    .AXIS_arid(AXIS_arid),
    .AXIS_araddr(AXIS_araddr),
    .AXIS_arlen(AXIS_arlen),
    .AXIS_arsize(AXIS_arsize),
    .AXIS_arburst(AXIS_arburst),
    .AXIS_arlock(AXIS_arlock),
    .AXIS_arcache(AXIS_arcache),
    .AXIS_arprot(AXIS_arprot),
    .AXIS_arregion(AXIS_arregion),
    .AXIS_arqos(AXIS_arqos),
    .AXIS_aruser(AXIS_aruser),
    .AXIS_arread(AXIS_arready),

    //manager
    .AXIM_arid(AXIM_arid),
    .AXIM_araddr(AXIM_araddr),
    .AXIM_arlen(AXIM_arlen),
    .AXIM_arsize(AXIM_arsize),
    .AXIM_arburst(AXIM_arburst),
    .AXIM_arlock(AXIM_arlock),
    .AXIM_arcache(AXIM_arcache),
    .AXIM_arprot(AXIM_arprot),
    .AXIM_arregion(AXIM_arregion),
    .AXIM_arqos(AXIM_arqos),
    .AXIM_aruser(AXIM_aruser),
    .AXIM_arread(AXIM_arready)
);

AXIToStream_Ax # (
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .ID_WIDTH(ID_WIDTH),
    .BURST_LEN(BURST_LEN),
    .LOCK_WIDTH(LOCK_WIDTH),
    .USER_WIDTH(USER_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .STREAM_TYPE_WIDTH(STREAM_TYPE_WIDTH = 3)
) AW (
    .clk(clk),
    .resetn(resetn[1]),
    .ready(ready[1]),
    .valid(valid[1]),
    .data(submodule_data[1]),
    .in_progress(in_progress[1]),
    
    //subordinate
    .AXIS_awid(AXIS_awid),
    .AXIS_awaddr(AXIS_awaddr),
    .AXIS_awlen(AXIS_awlen),
    .AXIS_awsize(AXIS_awsize),
    .AXIS_awburst(AXIS_awburst),
    .AXIS_awlock(AXIS_awlock),
    .AXIS_awcache(AXIS_awcache),
    .AXIS_awprot(AXIS_awprot),
    .AXIS_awregion(AXIS_awregion),
    .AXIS_awqos(AXIS_awqos),
    .AXIS_awuser(AXIS_awuser),
    .AXIS_awread(AXIS_awready),

    //manager
    .AXIM_awid(AXIM_awid),
    .AXIM_awaddr(AXIM_awaddr),
    .AXIM_awlen(AXIM_awlen),
    .AXIM_awsize(AXIM_awsize),
    .AXIM_awburst(AXIM_arwburst),
    .AXIM_awlock(AXIM_awlock),
    .AXIM_awcache(AXIM_awcache),
    .AXIM_awprot(AXIM_awprot),
    .AXIM_awregion(AXIM_awregion),
    .AXIM_awqos(AXIM_awqos),
    .AXIM_awuser(AXIM_awuser),
    .AXIM_awread(AXIM_awready)
);



//have the encoding maps always be refreshed in this always block
//helps separate somewhat static code with the actual logic
always @(posedge clk)begin 

end


//always block with the for loop with break
//Here we need to check all channels starting from last_index and accept the first valid channel (meaning that this for should unroll in a cascading if-else for all the entries encoded by the channels bit.)
always @(posedge clk)begin 

end




endmodule