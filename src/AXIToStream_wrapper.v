`timescale 1ns / 1ps
/** @file AXIToStream_wrapper.v
 *  @brief Verilog wrapper for the ::AXIToStream.sv module.
 *  @author Mattia Nicolella
 */

module AXIToStream_wrapper #(
    parameter DATA_WIDTH = 128,
    parameter ADDR_WIDTH = 64,
    parameter ID_WIDTH   = 32,
    parameter BURST_LEN  = 8,
    parameter LOCK_WIDTH = 2,
    parameter USER_WIDTH = 64,
    parameter DEST_WIDTH = 32
) (
    input  wire                    clk,
    input  wire                    resetn,
    // AXI Slave (input wire) interface, will snoop a transaction
    // Uncomment the following to set interface specific parameter on the bus interface.
    //  (* X_INTERFACE_PARAMETER = "CLK_DOMAIN <value>,PHASE <value>,MAX_BURST_LENGTH <value>,NUM_WRITE_OUTSTANDING <value>,NUM_READ_OUTSTANDING <value>,SUPPORTS_NARROW_BURST <value>,READ_WRITE_MODE <value>,BUSER_WIDTH <value>,RUSER_WIDTH <value>,WUSER_WIDTH <value>,ARUSER_WIDTH <value>,AWUSER_WIDTH <value>,ADDR_WIDTH <value>,ID_WIDTH <value>,FREQ_HZ <value>,PROTOCOL <value>,DATA_WIDTH <value>,HAS_BURST <value>,HAS_CACHE <value>,HAS_LOCK <value>,HAS_PROT <value>,HAS_QOS <value>,HAS_REGION <value>,HAS_WSTRB <value>,HAS_BRESP <value>,HAS_RRESP <value>" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWID" *)
    input  wire [    ID_WIDTH-1:0] AXIS_awid,      // Write address ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWADDR" *)
    input  wire [  ADDR_WIDTH-1:0] AXIS_awaddr,    // Write address
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWLEN" *)
    input  wire [   BURST_LEN-1:0] AXIS_awlen,     // Burst length
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWSIZE" *)
    input  wire [             2:0] AXIS_awsize,    // Burst size
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWBURST" *)
    input  wire [             1:0] AXIS_awburst,   // Burst type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWLOCK" *)
    input  wire [  LOCK_WIDTH-1:0] AXIS_awlock,    // Lock type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWCACHE" *)
    input  wire [             3:0] AXIS_awcache,   // Cache type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWPROT" *)
    input  wire [             2:0] AXIS_awprot,    // Protection type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWREGION" *)
    input  wire [             3:0] AXIS_awregion,  // Write address slave region
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWQOS" *)
    input  wire [             3:0] AXIS_awqos,     // Transaction Quality of Service token
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWUSER" *)
    input  wire [  USER_WIDTH-1:0] AXIS_awuser,    // Write address user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWVALID" *)
    input  wire                    AXIS_awvalid,   // Write address valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS AWREADY" *)
    output wire                    AXIS_awready,   // Write address ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS WID" *)
    input  wire [    ID_WIDTH-1:0] AXIS_wid,       // Write ID tag
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS WDATA" *)
    input  wire [  DATA_WIDTH-1:0] AXIS_wdata,     // Write data
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS WSTRB" *)
    input  wire [DATA_WIDTH/8-1:0] AXIS_wstrb,     // Write strobes
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS WLAST" *)
    input  wire                    AXIS_wlast,     // Write last beat
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS WUSER" *)
    input  wire [  USER_WIDTH-1:0] AXIS_wuser,     // Write data user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS WVALID" *)
    input  wire                    AXIS_wvalid,    // Write valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS WREADY" *)
    output wire                    AXIS_wready,    // Write ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS BID" *)
    output wire [    ID_WIDTH-1:0] AXIS_bid,       // Response ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS BRESP" *)
    output wire [             1:0] AXIS_bresp,     // Write response
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS BUSER" *)
    output wire [  USER_WIDTH-1:0] AXIS_buser,     // Write response user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS BVALID" *)
    output wire                    AXIS_bvalid,    // Write response valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS BREADY" *)
    input  wire                    AXIS_bready,    // Write response ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARID" *)
    input  wire [    ID_WIDTH-1:0] AXIS_arid,      // Read address ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARADDR" *)
    input  wire [  ADDR_WIDTH-1:0] AXIS_araddr,    // Read address
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARLEN" *)
    input  wire [   BURST_LEN-1:0] AXIS_arlen,     // Burst length
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARSIZE" *)
    input  wire [             2:0] AXIS_arsize,    // Burst size
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARBURST" *)
    input  wire [             1:0] AXIS_arburst,   // Burst type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARLOCK" *)
    input  wire [  LOCK_WIDTH-1:0] AXIS_arlock,    // Lock type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARCACHE" *)
    input  wire [             3:0] AXIS_arcache,   // Cache type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARPROT" *)
    input  wire [             2:0] AXIS_arprot,    // Protection type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARREGION" *)
    input  wire [             3:0] AXIS_arregion,  // Read address slave region
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARQOS" *)
    input  wire [             3:0] AXIS_arqos,     // Quality of service token
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARUSER" *)
    input  wire [  USER_WIDTH-1:0] AXIS_aruser,    // Read address user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARVALID" *)
    input  wire                    AXIS_arvalid,   // Read address valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS ARREADY" *)
    output wire                    AXIS_arready,   // Read address ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS RID" *)
    output wire [    ID_WIDTH-1:0] AXIS_rid,       // Read ID tag
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS RDATA" *)
    output wire [  DATA_WIDTH-1:0] AXIS_rdata,     // Read data
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS RRESP" *)
    output wire [             1:0] AXIS_rresp,     // Read response
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS RLAST" *)
    output wire                    AXIS_rlast,     // Read last beat
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS RUSER" *)
    output wire [  USER_WIDTH-1:0] AXIS_ruser,     // Read user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS RVALID" *)
    output wire                    AXIS_rvalid,    // Read valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIS RREADY" *)
    input  wire                    AXIS_rready,    // Read ready
    // AXI master (output wire) Interface, will forward the snooped transaction to destination
    // Uncomment the following to set interface specific parameter on the bus interface.
    //  (* X_INTERFACE_PARAMETER = "CLK_DOMAIN <value>,PHASE <value>,MAX_BURST_LENGTH <value>,NUM_WRITE_OUTSTANDING <value>,NUM_READ_OUTSTANDING <value>,SUPPORTS_NARROW_BURST <value>,READ_WRITE_MODE <value>,BUSER_WIDTH <value>,RUSER_WIDTH <value>,WUSER_WIDTH <value>,ARUSER_WIDTH <value>,AWUSER_WIDTH <value>,ADDR_WIDTH <value>,ID_WIDTH <value>,FREQ_HZ <value>,PROTOCOL <value>,DATA_WIDTH <value>,HAS_BURST <value>,HAS_CACHE <value>,HAS_LOCK <value>,HAS_PROT <value>,HAS_QOS <value>,HAS_REGION <value>,HAS_WSTRB <value>,HAS_BRESP <value>,HAS_RRESP <value>" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWID" *)
    output wire [    ID_WIDTH-1:0] AXIM_awid,      // Write address ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWADDR" *)
    output wire [  ADDR_WIDTH-1:0] AXIM_awaddr,    // Write address
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWLEN" *)
    output wire [   BURST_LEN-1:0] AXIM_awlen,     // Burst length
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWSIZE" *)
    output wire [             2:0] AXIM_awsize,    // Burst size
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWBURST" *)
    output wire [             1:0] AXIM_awburst,   // Burst type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWLOCK" *)
    output wire [  LOCK_WIDTH-1:0] AXIM_awlock,    // Lock type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWCACHE" *)
    output wire [             3:0] AXIM_awcache,   // Cache type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWPROT" *)
    output wire [             2:0] AXIM_awprot,    // Protection type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWREGION" *)
    output wire [             3:0] AXIM_awregion,  // Write address slave region
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWQOS" *)
    output wire [             3:0] AXIM_awqos,     // Transaction Quality of Service token
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWUSER" *)
    output wire [  USER_WIDTH-1:0] AXIM_awuser,    // Write address user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWVALID" *)
    output wire                    AXIM_awvalid,   // Write address valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM AWREADY" *)
    input  wire                    AXIM_awready,   // Write address ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM WID" *)
    output wire [    ID_WIDTH-1:0] AXIM_wid,       // Write ID tag
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM WDATA" *)
    output wire [  DATA_WIDTH-1:0] AXIM_wdata,     // Write data
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM WSTRB" *)
    output wire [DATA_WIDTH/8-1:0] AXIM_wstrb,     // Write strobes
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM WLAST" *)
    output wire                    AXIM_wlast,     // Write last beat
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM WUSER" *)
    output wire [  USER_WIDTH-1:0] AXIM_wuser,     // Write data user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM WVALID" *)
    output wire                    AXIM_wvalid,    // Write valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM WREADY" *)
    input  wire                    AXIM_wready,    // Write ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM BID" *)
    input  wire [    ID_WIDTH-1:0] AXIM_bid,       // Response ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM BRESP" *)
    input  wire [             1:0] AXIM_bresp,     // Write response
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM BUSER" *)
    input  wire [  USER_WIDTH-1:0] AXIM_buser,     // Write response user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM BVALID" *)
    input  wire                    AXIM_bvalid,    // Write response valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM BREADY" *)
    output wire                    AXIM_bready,    // Write response ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARID" *)
    output wire [    ID_WIDTH-1:0] AXIM_arid,      // Read address ID
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARADDR" *)
    output wire [  ADDR_WIDTH-1:0] AXIM_araddr,    // Read address
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARLEN" *)
    output wire [   BURST_LEN-1:0] AXIM_arlen,     // Burst length
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARSIZE" *)
    output wire [             2:0] AXIM_arsize,    // Burst size
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARBURST" *)
    output wire [             1:0] AXIM_arburst,   // Burst type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARLOCK" *)
    output wire [  LOCK_WIDTH-1:0] AXIM_arlock,    // Lock type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARCACHE" *)
    output wire [             3:0] AXIM_arcache,   // Cache type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARPROT" *)
    output wire [             2:0] AXIM_arprot,    // Protection type
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARREGION" *)
    output wire [             3:0] AXIM_arregion,  // Read address slave region
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARQOS" *)
    output wire [             3:0] AXIM_arqos,     // Quality of service token
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARUSER" *)
    output wire [  USER_WIDTH-1:0] AXIM_aruser,    // Read address user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARVALID" *)
    output wire                    AXIM_arvalid,   // Read address valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM ARREADY" *)
    input  wire                    AXIM_arready,   // Read address ready
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM RID" *)
    input  wire [    ID_WIDTH-1:0] AXIM_rid,       // Read ID tag
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM RDATA" *)
    input  wire [  DATA_WIDTH-1:0] AXIM_rdata,     // Read data
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM RRESP" *)
    input  wire [             1:0] AXIM_rresp,     // Read response
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM RLAST" *)
    input  wire                    AXIM_rlast,     // Read last beat
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM RUSER" *)
    input  wire [  USER_WIDTH-1:0] AXIM_ruser,     // Read user sideband
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM RVALID" *)
    input  wire                    AXIM_rvalid,    // Read valid
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 AXIM RREADY" *)
    output wire                    AXIM_rready,    // Read ready
    // AXI stream Master (stream input wire) interface
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TID" *)
    // Uncomment the following to set interface specific parameter on the bus interface.
    //  (* X_INTERFACE_PARAMETER = "CLK_DOMAIN <value>,PHASE <value>,FREQ_HZ <value>,LAYERED_METADATA <value>,HAS_TLAST <value>,HAS_TKEEP <value>,HAS_TSTRB <value>,HAS_TREADY <value>,TUSER_WIDTH <value>,TID_WIDTH <value>,TDEST_WIDTH <value>,TDATA_NUM_BYTES <value>" *)
    output wire [    ID_WIDTH-1:0] stream_tid,     // Transfer ID tag (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TDEST" *)
    output wire [  DEST_WIDTH-1:0] stream_tdest,   // Transfer Destination (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TDATA" *)
    output wire [  DATA_WIDTH-1:0] stream_tdata,   // Transfer Data (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TSTRB" *)
    output wire [DATA_WIDTH/8-1:0] stream_tstrb,   // Transfer Data Byte Strobes (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TKEEP" *)
    output wire [DATA_WIDTH/8-1:0] stream_tkeep,   // Transfer Null Byte Indicators (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TLAST" *)
    output wire                    stream_tlast,   // Packet Boundary Indicator (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TUSER" *)
    output wire [  USER_WIDTH-1:0] stream_tuser,   // Transfer user sideband (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TVALID" *)
    output wire                    stream_tvalid,  // Transfer valid (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 STREAM_AXI TREADY" *)
    input  wire                    stream_tready,  // Transfer ready (optional)

    // reset params
    input wire RESETN_AR,
    input wire RESETN_AW,
    input wire RESETN_R,
    input wire RESETN_W,
    input wire RESETN_B
);

  AXIToStream #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .ID_WIDTH  (BURST_LEN),
      .LOCK_WIDTH(LOCK_WIDTH),
      .USER_WIDTH(USER_WIDTH)
  ) axi_to_stream (
      .clk(clk),
      .resetn(resetn),
      .RESETN_AR(RESETN_AR),
      .RESETN_AW(RESETN_AW),
      .RESETN_R(RESETN_R),
      .RESETN_W(RESETN_W),
      .RESETN_B(RESETN_B),
      .AXIS_araddr(AXIS_araddr),
      .AXIS_arburst(AXIS_arburst),
      .AXIS_arcache(AXIS_arcache),
      .AXIS_arid(AXIS_arid),
      .AXIS_arlen(AXIS_arlen),
      .AXIS_arlock(AXIS_arlock),
      .AXIS_arprot(AXIS_arprot),
      .AXIS_arqos(AXIS_arqos),
      .AXIS_arready(AXIS_arready),
      .AXIS_arregion(AXIS_arregion),
      .AXIS_arsize(AXIS_arsize),
      .AXIS_aruser(AXIS_aruser),
      .AXIS_arvalid(AXIS_arvalid),

      .AXIS_rdata(AXIS_rdata),
      .AXIS_rid(AXIS_rid),
      .AXIS_rlast(AXIS_rlast),
      .AXIS_rready(AXIS_rready),
      .AXIS_rresp(AXIS_rresp),
      .AXIS_ruser(AXIS_ruser),
      .AXIS_rvalid(AXIS_rvalid),

      .AXIS_awaddr(AXIS_awaddr),
      .AXIS_awburst(AXIS_awburst),
      .AXIS_awcache(AXIS_awcache),
      .AXIS_awid(AXIS_awid),
      .AXIS_awlen(AXIS_awlen),
      .AXIS_awlock(AXIS_awlock),
      .AXIS_awprot(AXIS_awprot),
      .AXIS_awqos(AXIS_awqos),
      .AXIS_awready(AXIS_awready),
      .AXIS_awregion(AXIS_awregion),
      .AXIS_awsize(AXIS_awsize),
      .AXIS_awuser(AXIS_awuser),
      .AXIS_awvalid(AXIS_awvalid),

      .AXIS_wdata(AXIS_wdata),
      .AXIS_wid(AXIS_wid),
      .AXIS_wlast(AXIS_wlast),
      .AXIS_wready(AXIS_wready),
      .AXIS_wstrb(AXIS_wstrb),
      .AXIS_wuser(AXIS_wuser),
      .AXIS_wvalid(AXIS_wvalid),

      .AXIS_bid(AXIS_bid),
      .AXIS_bready(AXIS_bready),
      .AXIS_bresp(AXIS_bresp),
      .AXIS_buser(AXIS_buser),
      .AXIS_bvalid(AXIS_bvalid),

      .AXIM_araddr(AXIM_araddr),
      .AXIM_arburst(AXIM_arburst),
      .AXIM_arcache(AXIM_arcache),
      .AXIM_arid(AXIM_arid),
      .AXIM_arlen(AXIM_arlen),
      .AXIM_arlock(AXIM_arlock),
      .AXIM_arprot(AXIM_arprot),
      .AXIM_arqos(AXIM_arqos),
      .AXIM_arready(AXIM_arready),
      .AXIM_arregion(AXIM_arregion),
      .AXIM_arsize(AXIM_arsize),
      .AXIM_aruser(AXIM_aruser),
      .AXIM_arvalid(AXIM_arvalid),

      .AXIM_rdata(AXIM_rdata),
      .AXIM_rid(AXIM_rid),
      .AXIM_rlast(AXIM_rlast),
      .AXIM_rready(AXIM_rready),
      .AXIM_rresp(AXIM_rresp),
      .AXIM_ruser(AXIM_ruser),
      .AXIM_rvalid(AXIM_rvalid),

      .AXIM_awaddr(AXIM_awaddr),
      .AXIM_awburst(AXIM_awburst),
      .AXIM_awcache(AXIM_awcache),
      .AXIM_awid(AXIM_awid),
      .AXIM_awlen(AXIM_awlen),
      .AXIM_awlock(AXIM_awlock),
      .AXIM_awprot(AXIM_awprot),
      .AXIM_awqos(AXIM_awqos),
      .AXIM_awready(AXIM_awready),
      .AXIM_awregion(AXIM_awregion),
      .AXIM_awsize(AXIM_awsize),
      .AXIM_awuser(AXIM_awuser),
      .AXIM_awvalid(AXIM_awvalid),

      .AXIM_wdata(AXIM_wdata),
      .AXIM_wid(AXIM_wid),
      .AXIM_wlast(AXIM_wlast),
      .AXIM_wready(AXIM_wready),
      .AXIM_wstrb(AXIM_wstrb),
      .AXIM_wuser(AXIM_wuser),
      .AXIM_wvalid(AXIM_wvalid),

      .AXIM_bid(AXIM_bid),
      .AXIM_bready(AXIM_bready),
      .AXIM_bresp(AXIM_bresp),
      .AXIM_buser(AXIM_buser),
      .AXIM_bvalid(AXIM_bvalid),

      .stream_tdata(stream_tdata),
      .stream_tdest(stream_tdest),
      .stream_tid(stream_tid),
      .stream_tkeep(stream_tkeep),
      .stream_tlast(stream_tlast),
      .stream_tready(stream_tready),
      .stream_tstrb(stream_tstrb),
      .stream_tuser(stream_tuser),
      .stream_tvalid(stream_tvalid)
  );

endmodule
