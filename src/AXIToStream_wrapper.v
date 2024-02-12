`timescale 1ns / 1ps
/** @file AXIToStream_wrapper.v
 *  @brief Verilog wrapper for the ::AXIToStream.sv module.
 *  @author Mattia Nicolella
 */

module AXIToStream_wrapper #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH = 32,
    parameter BURST_LEN = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64,
    parameter DEST_WIDTH = 32,
    parameter STREAM_TYPE_WIDTH = 3
) (
    input  wire                    clk,
    input  wire                    resetn,
    // AXI Slave (input wire) interface, will snoop a transaction
    // Uncomment the following to set interface specific parameter on the bus interface.
    //  (* X_INTERFACE_PARAMETER = "CLK_DOMAIN <value>,PHASE <value>,MAX_BURST_LENGTH <value>,NUM_WRITE_OUTSTANDING <value>,NUM_READ_OUTSTANDING <value>,SUPPORTS_NARROW_BURST <value>,READ_WRITE_MODE <value>,BUSER_WIDTH <value>,RUSER_WIDTH <value>,WUSER_WIDTH <value>,ARUSER_WIDTH <value>,AWUSER_WIDTH <value>,ADDR_WIDTH <value>,ID_WIDTH <value>,FREQ_HZ <value>,PROTOCOL <value>,DATA_WIDTH <value>,HAS_BURST <value>,HAS_CACHE <value>,HAS_LOCK <value>,HAS_PROT <value>,HAS_QOS <value>,HAS_REGION <value>,HAS_WSTRB <value>,HAS_BRESP <value>,HAS_RRESP <value>" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWID" *)
    input  wire [    ID_WIDTH-1:0] snoop_awid,        // Write address ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWADDR" *)
    input  wire [  ADDR_WIDTH-1:0] snoop_awaddr,      // Write address
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWLEN" *)
    input  wire [   BURST_LEN-1:0] snoop_awlen,       // Burst length
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWSIZE" *)
    input  wire [             2:0] snoop_awsize,      // Burst size
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWBURST" *)
    input  wire [             1:0] snoop_awburst,     // Burst type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWLOCK" *)
    input  wire [  LOCK_WIDTH-1:0] snoop_awlock,      // Lock type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWCACHE" *)
    input  wire [             3:0] snoop_awcache,     // Cache type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWPROT" *)
    input  wire [             2:0] snoop_awprot,      // Protection type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWREGION" *)
    input  wire [             3:0] snoop_awregion,    // Write address slave region
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWQOS" *)
    input  wire [             3:0] snoop_awqos,       // Transaction Quality of Service token
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWUSER" *)
    input  wire [  USER_WIDTH-1:0] snoop_awuser,      // Write address user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWVALID" *)
    input  wire                    snoop_awvalid,     // Write address valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI AWREADY" *)
    output wire                    snoop_awready,     // Write address ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI WID" *)
    input  wire [    ID_WIDTH-1:0] snoop_wid,         // Write ID tag
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI WDATA" *)
    input  wire [  DATA_WIDTH-1:0] snoop_wdata,       // Write data
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI WSTRB" *)
    input  wire [DATA_WIDTH/8-1:0] snoop_wstrb,       // Write strobes
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI WLAST" *)
    input  wire                    snoop_wlast,       // Write last beat
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI WUSER" *)
    input  wire [  USER_WIDTH-1:0] snoop_wuser,       // Write data user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI WVALID" *)
    input  wire                    snoop_wvalid,      // Write valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI WREADY" *)
    output wire                    snoop_wready,      // Write ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI BID" *)
    output wire [    ID_WIDTH-1:0] snoop_bid,         // Response ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI BRESP" *)
    output wire [             1:0] snoop_bresp,       // Write response
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI BUSER" *)
    output wire [  USER_WIDTH-1:0] snoop_buser,       // Write response user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI BVALID" *)
    output wire                    snoop_bvalid,      // Write response valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI BREADY" *)
    input  wire                    snoop_bready,      // Write response ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARID" *)
    input  wire [    ID_WIDTH-1:0] snoop_arid,        // Read address ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARADDR" *)
    input  wire [  ADDR_WIDTH-1:0] snoop_araddr,      // Read address
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARLEN" *)
    input  wire [   BURST_LEN-1:0] snoop_arlen,       // Burst length
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARSIZE" *)
    input  wire [             2:0] snoop_arsize,      // Burst size
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARBURST" *)
    input  wire [             1:0] snoop_arburst,     // Burst type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARLOCK" *)
    input  wire [  LOCK_WIDTH-1:0] snoop_arlock,      // Lock type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARCACHE" *)
    input  wire [             3:0] snoop_arcache,     // Cache type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARPROT" *)
    input  wire [             2:0] snoop_arprot,      // Protection type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARREGION" *)
    input  wire [             3:0] snoop_arregion,    // Read address slave region
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARQOS" *)
    input  wire [             3:0] snoop_arqos,       // Quality of service token
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARUSER" *)
    input  wire [  USER_WIDTH-1:0] snoop_aruser,      // Read address user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARVALID" *)
    input  wire                    snoop_arvalid,     // Read address valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI ARREADY" *)
    output wire                    snoop_arready,     // Read address ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI RID" *)
    output wire [    ID_WIDTH-1:0] snoop_rid,         // Read ID tag
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI RDATA" *)
    output wire [  DATA_WIDTH-1:0] snoop_rdata,       // Read data
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI RRESP" *)
    output wire [             1:0] snoop_rresp,       // Read response
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI RLAST" *)
    output wire                    snoop_rlast,       // Read last beat
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI RUSER" *)
    output wire [  USER_WIDTH-1:0] snoop_ruser,       // Read user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI RVALID" *)
    output wire                    snoop_rvalid,      // Read valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 SNOOP_AXI RREADY" *)
    input  wire                    snoop_rready,      // Read ready
    // AXI master (output wire) Interface, will forward the snooped transaction to destination
    // Uncomment the following to set interface specific parameter on the bus interface.
    //  (* X_INTERFACE_PARAMETER = "CLK_DOMAIN <value>,PHASE <value>,MAX_BURST_LENGTH <value>,NUM_WRITE_OUTSTANDING <value>,NUM_READ_OUTSTANDING <value>,SUPPORTS_NARROW_BURST <value>,READ_WRITE_MODE <value>,BUSER_WIDTH <value>,RUSER_WIDTH <value>,WUSER_WIDTH <value>,ARUSER_WIDTH <value>,AWUSER_WIDTH <value>,ADDR_WIDTH <value>,ID_WIDTH <value>,FREQ_HZ <value>,PROTOCOL <value>,DATA_WIDTH <value>,HAS_BURST <value>,HAS_CACHE <value>,HAS_LOCK <value>,HAS_PROT <value>,HAS_QOS <value>,HAS_REGION <value>,HAS_WSTRB <value>,HAS_BRESP <value>,HAS_RRESP <value>" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWID" *)
    output wire [    ID_WIDTH-1:0] forward_awid,      // Write address ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWADDR" *)
    output wire [  ADDR_WIDTH-1:0] forward_awaddr,    // Write address
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWLEN" *)
    output wire [   BURST_LEN-1:0] forward_awlen,     // Burst length
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWSIZE" *)
    output wire [             2:0] forward_awsize,    // Burst size
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWBURST" *)
    output wire [             1:0] forward_awburst,   // Burst type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWLOCK" *)
    output wire [  LOCK_WIDTH-1:0] forward_awlock,    // Lock type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWCACHE" *)
    output wire [             3:0] forward_awcache,   // Cache type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWPROT" *)
    output wire [             2:0] forward_awprot,    // Protection type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWREGION" *)
    output wire [             3:0] forward_awregion,  // Write address slave region
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWQOS" *)
    output wire [             3:0] forward_awqos,     // Transaction Quality of Service token
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWUSER" *)
    output wire [  USER_WIDTH-1:0] forward_awuser,    // Write address user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWVALID" *)
    output wire                    forward_awvalid,   // Write address valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI AWREADY" *)
    input  wire                    forward_awready,   // Write address ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI WID" *)
    output wire [    ID_WIDTH-1:0] forward_wid,       // Write ID tag
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI WDATA" *)
    output wire [  DATA_WIDTH-1:0] forward_wdata,     // Write data
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI WSTRB" *)
    output wire [DATA_WIDTH/8-1:0] forward_wstrb,     // Write strobes
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI WLAST" *)
    output wire                    forward_wlast,     // Write last beat
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI WUSER" *)
    output wire [  USER_WIDTH-1:0] forward_wuser,     // Write data user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI WVALID" *)
    output wire                    forward_wvalid,    // Write valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI WREADY" *)
    input  wire                    forward_wready,    // Write ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI BID" *)
    input  wire [    ID_WIDTH-1:0] forward_bid,       // Response ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI BRESP" *)
    input  wire [             1:0] forward_bresp,     // Write response
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI BUSER" *)
    input  wire [  USER_WIDTH-1:0] forward_buser,     // Write response user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI BVALID" *)
    input  wire                    forward_bvalid,    // Write response valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI BREADY" *)
    output wire                    forward_bready,    // Write response ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARID" *)
    output wire [    ID_WIDTH-1:0] forward_arid,      // Read address ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARADDR" *)
    output wire [  ADDR_WIDTH-1:0] forward_araddr,    // Read address
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARLEN" *)
    output wire [   BURST_LEN-1:0] forward_arlen,     // Burst length
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARSIZE" *)
    output wire [             2:0] forward_arsize,    // Burst size
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARBURST" *)
    output wire [             1:0] forward_arburst,   // Burst type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARLOCK" *)
    output wire [  LOCK_WIDTH-1:0] forward_arlock,    // Lock type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARCACHE" *)
    output wire [             3:0] forward_arcache,   // Cache type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARPROT" *)
    output wire [             2:0] forward_arprot,    // Protection type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARREGION" *)
    output wire [             3:0] forward_arregion,  // Read address slave region
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARQOS" *)
    output wire [             3:0] forward_arqos,     // Quality of service token
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARUSER" *)
    output wire [  USER_WIDTH-1:0] forward_aruser,    // Read address user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARVALID" *)
    output wire                    forward_arvalid,   // Read address valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI ARREADY" *)
    input  wire                    forward_arready,   // Read address ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI RID" *)
    input  wire [    ID_WIDTH-1:0] forward_rid,       // Read ID tag
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI RDATA" *)
    input  wire [  DATA_WIDTH-1:0] forward_rdata,     // Read data
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI RRESP" *)
    input  wire [             1:0] forward_rresp,     // Read response
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI RLAST" *)
    input  wire                    forward_rlast,     // Read last beat
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI RUSER" *)
    input  wire [  USER_WIDTH-1:0] forward_ruser,     // Read user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI RVALID" *)
    input  wire                    forward_rvalid,    // Read valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 FORWARD_AXI RREADY" *)
    output wire                    forward_rready,    // Read ready
    // AXI stream Master (stream input wire) interface
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TID" *)
    // Uncomment the following to set interface specific parameter on the bus interface.
    //  (* X_INTERFACE_PARAMETER = "CLK_DOMAIN <value>,PHASE <value>,FREQ_HZ <value>,LAYERED_METADATA <value>,HAS_TLAST <value>,HAS_TKEEP <value>,HAS_TSTRB <value>,HAS_TREADY <value>,TUSER_WIDTH <value>,TID_WIDTH <value>,TDEST_WIDTH <value>,TDATA_NUM_BYTES <value>" *)
    output wire [    ID_WIDTH-1:0] stream_tid,        // Transfer ID tag (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TDEST" *)
    output wire [  DEST_WIDTH-1:0] stream_tdest,      // Transfer Destination (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TDATA" *)
    output wire [  DATA_WIDTH-1:0] stream_tdata,      // Transfer Data (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TSTRB" *)
    output wire [DATA_WIDTH/8-1:0] stream_tstrb,      // Transfer Data Byte Strobes (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TKEEP" *)
    output wire [DATA_WIDTH/8-1:0] stream_tkeep,      // Transfer Null Byte Indicators (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TLAST" *)
    output wire                    stream_tlast,      // Packet Boundary Indicator (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TUSER" *)
    output wire [  USER_WIDTH-1:0] stream_tuser,      // Transfer user sideband (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TVALID" *)
    output wire                    stream_tvalid,     // Transfer valid (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TREADY" *)
    input  wire                    stream_tready,     // Transfer ready (optional)

    output wire [STREAM_TYPE_WIDTH-1:0] DBG_stream_type
);

  AXIToStream #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .ID_WIDTH(BURST_LEN),
      .LOCK_WIDTH(LOCK_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .STREAM_TYPE_WIDTH(STREAM_TYPE_WIDTH)
  ) axi_to_stream (
      .clk(clk),
      .resetn(resetn),
      .snoop_araddr(snoop_araddr),
      .snoop_arburst(snoop_arburst),
      .snoop_arcache(snoop_arcache),
      .snoop_arid(snoop_arid),
      .snoop_arlen(snoop_arlen),
      .snoop_arlock(snoop_arlock),
      .snoop_arprot(snoop_arprot),
      .snoop_arqos(snoop_arqos),
      .snoop_arready(snoop_arready),
      .snoop_arregion(snoop_arregion),
      .snoop_arsize(snoop_arsize),
      .snoop_aruser(snoop_aruser),
      .snoop_arvalid(snoop_arvalid),

      .snoop_rdata(snoop_rdata),
      .snoop_rid(snoop_rid),
      .snoop_rlast(snoop_rlast),
      .snoop_rready(snoop_rready),
      .snoop_rresp(snoop_rresp),
      .snoop_ruser(snoop_ruser),
      .snoop_rvalid(snoop_rvalid),

      .snoop_awaddr(snoop_awaddr),
      .snoop_awburst(snoop_awburst),
      .snoop_awcache(snoop_awcache),
      .snoop_awid(snoop_awid),
      .snoop_awlen(snoop_awlen),
      .snoop_awlock(snoop_awlock),
      .snoop_awprot(snoop_awprot),
      .snoop_awqos(snoop_awqos),
      .snoop_awready(snoop_awready),
      .snoop_awregion(snoop_awregion),
      .snoop_awsize(snoop_awsize),
      .snoop_awuser(snoop_awuser),
      .snoop_awvalid(snoop_awvalid),

      .snoop_wdata(snoop_wdata),
      .snoop_wid(snoop_wid),
      .snoop_wlast(snoop_wlast),
      .snoop_wready(snoop_wready),
      .snoop_wstrb(snoop_wstrb),
      .snoop_wuser(snoop_wuser),
      .snoop_wvalid(snoop_wvalid),

      .snoop_bid(snoop_bid),
      .snoop_bready(snoop_bready),
      .snoop_bresp(snoop_bresp),
      .snoop_buser(snoop_buser),
      .snoop_bvalid(snoop_bvalid),

      .forward_araddr(forward_araddr),
      .forward_arburst(forward_arburst),
      .forward_arcache(forward_arcache),
      .forward_arid(forward_arid),
      .forward_arlen(forward_arlen),
      .forward_arlock(forward_arlock),
      .forward_arprot(forward_arprot),
      .forward_arqos(forward_arqos),
      .forward_arready(forward_arready),
      .forward_arregion(forward_arregion),
      .forward_arsize(forward_arsize),
      .forward_aruser(forward_aruser),
      .forward_arvalid(forward_arvalid),

      .forward_rdata(forward_rdata),
      .forward_rid(forward_rid),
      .forward_rlast(forward_rlast),
      .forward_rready(forward_rready),
      .forward_rresp(forward_rresp),
      .forward_ruser(forward_ruser),
      .forward_rvalid(forward_rvalid),

      .forward_awaddr(forward_awaddr),
      .forward_awburst(forward_awburst),
      .forward_awcache(forward_awcache),
      .forward_awid(forward_awid),
      .forward_awlen(forward_awlen),
      .forward_awlock(forward_awlock),
      .forward_awprot(forward_awprot),
      .forward_awqos(forward_awqos),
      .forward_awready(forward_awready),
      .forward_awregion(forward_awregion),
      .forward_awsize(forward_awsize),
      .forward_awuser(forward_awuser),
      .forward_awvalid(forward_awvalid),

      .forward_wdata(forward_wdata),
      .forward_wid(forward_wid),
      .forward_wlast(forward_wlast),
      .forward_wready(forward_wready),
      .forward_wstrb(forward_wstrb),
      .forward_wuser(forward_wuser),
      .forward_wvalid(forward_wvalid),

      .forward_bid(forward_bid),
      .forward_bready(forward_bready),
      .forward_bresp(forward_bresp),
      .forward_buser(forward_buser),
      .forward_bvalid(forward_bvalid),

      .stream_tdata(stream_tdata),
      .stream_tdest(stream_tdest),
      .stream_tid(stream_tid),
      .stream_tkeep(stream_tkeep),
      .stream_tlast(stream_tlast),
      .stream_tready(stream_tready),
      .stream_tstrb(stream_tstrb),
      .stream_tuser(stream_tuser),
      .stream_tvalid(stream_tvalid),


      .DBG_stream_type(DBG_stream_type)
  );

endmodule
