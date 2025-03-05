`timescale 1 ns / 1 ps

module UARTDriver #(
	parameter integer ID_WIDTH     = 4,
    parameter integer MASTER_ID_WIDTH = 4,
	parameter integer ADDR_WIDTH   = 10,
	parameter integer DATA_WIDTH   = 32,
	parameter integer USER_WIDTH   = 16
) (
	(* X_INTERFACE_PARAMETER = "ASSOCIATED_CLKEN aresetn, ASSOCIATED_BUSIF axi_master:axi_slave" *)
	input  wire                      clk     ,
	input  wire                      aresetn ,

    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARADDR" *)
    output  [      ADDR_WIDTH-1:0] axi_master_araddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARBURST" *)
    output  [                 1:0] axi_master_arburst,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARCACHE" *)
    output  [                 3:0] axi_master_arcache,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARID" *)
    output  [        MASTER_ID_WIDTH-1:0] axi_master_arid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARLEN" *)
    output  [                 7:0] axi_master_arlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARLOCK" *)
    output   axi_master_arlock,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARPROT" *)
    output  [                 2:0] axi_master_arprot,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARQOS" *)
    output  [                 3:0] axi_master_arqos,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARREADY" *)
    input   axi_master_arready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARREGION" *)
    output  [                 1:0] axi_master_arregion,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARSIZE" *)
    output  [                 2:0] axi_master_arsize,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARUSER" *)
    output  [(USER_WIDTH > 0 ? USER_WIDTH : 1) -1:0] axi_master_aruser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master ARVALID" *)
    output   axi_master_arvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWADDR" *)
    output  [      ADDR_WIDTH-1:0] axi_master_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWBURST" *)
    output  [                 1:0] axi_master_awburst,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWCACHE" *)
    output  [                 3:0] axi_master_awcache,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWID" *)
    output  [        MASTER_ID_WIDTH-1:0] axi_master_awid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWLEN" *)
    output  [                 7:0] axi_master_awlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWLOCK" *)
    output   axi_master_awlock,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWPROT" *)
    output  [                 2:0] axi_master_awprot,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWQOS" *)
    output  [                 3:0] axi_master_awqos,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWREADY" *)
    input   axi_master_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWREGION" *)
    output  [                 1:0] axi_master_awregion,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWSIZE" *)
    output  [                 2:0] axi_master_awsize,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWUSER" *)
    output  [                15:0] axi_master_awuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master AWVALID" *)
    output   axi_master_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master BID" *)
    input  [        MASTER_ID_WIDTH-1:0] axi_master_bid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master BREADY" *)
    output   axi_master_bready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master BRESP" *)
    input  [                 1:0] axi_master_bresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master BUSER" *)
    input  [(USER_WIDTH > 0 ? USER_WIDTH : 1) -1:0] axi_master_buser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master BVALID" *)
    input   axi_master_bvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master RDATA" *)
    input  [      DATA_WIDTH-1:0] axi_master_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master RID" *)
    input  [        MASTER_ID_WIDTH-1:0] axi_master_rid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master RLAST" *)
    input   axi_master_rlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master RREADY" *)
    output   axi_master_rready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master RRESP" *)
    input  [                 3:0] axi_master_rresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master RUSER" *)
    input  [(USER_WIDTH > 0 ? USER_WIDTH : 1) -1:0] axi_master_ruser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master RVALID" *)
    input   axi_master_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master WDATA" *)
    output  [      DATA_WIDTH-1:0] axi_master_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master WLAST" *)
    output   axi_master_wlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master WREADY" *)
    input   axi_master_wready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master WSTRB" *)
    output  [  (DATA_WIDTH/8)-1:0] axi_master_wstrb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master WUSER" *)
    output  [(USER_WIDTH > 0 ? USER_WIDTH : 1) -1:0] axi_master_wuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_master WVALID" *)
    output   axi_master_wvalid,

    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARADDR" *)
    input  [      ADDR_WIDTH-1:0] axi_slave_araddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARBURST" *)
    input  [                 1:0] axi_slave_arburst,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARCACHE" *)
    input  [                 3:0] axi_slave_arcache,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARID" *)
    input  [        ID_WIDTH-1:0] axi_slave_arid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARLEN" *)
    input  [                 7:0] axi_slave_arlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARLOCK" *)
    input   axi_slave_arlock,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARPROT" *)
    input  [                 2:0] axi_slave_arprot,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARQOS" *)
    input  [                 3:0] axi_slave_arqos,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARREADY" *)
    output   axi_slave_arready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARREGION" *)
    input  [                 1:0] axi_slave_arregion,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARSIZE" *)
    input  [                 2:0] axi_slave_arsize,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARUSER" *)
    input  [(USER_WIDTH > 0 ? USER_WIDTH : 1) -1:0] axi_slave_aruser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave ARVALID" *)
    input   axi_slave_arvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWADDR" *)
    input  [      ADDR_WIDTH-1:0] axi_slave_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWBURST" *)
    input  [                 1:0] axi_slave_awburst,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWCACHE" *)
    input  [                 3:0] axi_slave_awcache,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWID" *)
    input  [        ID_WIDTH-1:0] axi_slave_awid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWLEN" *)
    input  [                 7:0] axi_slave_awlen,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWLOCK" *)
    input   axi_slave_awlock,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWPROT" *)
    input  [                 2:0] axi_slave_awprot,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWQOS" *)
    input  [                 3:0] axi_slave_awqos,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWREADY" *)
    output   axi_slave_awready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWREGION" *)
    input  [                 1:0] axi_slave_awregion,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWSIZE" *)
    input  [                 2:0] axi_slave_awsize,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWUSER" *)
    input  [                15:0] axi_slave_awuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave AWVALID" *)
    input   axi_slave_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave BID" *)
    output  [        ID_WIDTH-1:0] axi_slave_bid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave BREADY" *)
    input   axi_slave_bready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave BRESP" *)
    output  [                 1:0] axi_slave_bresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave BUSER" *)
    output  [(USER_WIDTH > 0 ? USER_WIDTH : 1) -1:0] axi_slave_buser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave BVALID" *)
    output   axi_slave_bvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave RDATA" *)
    output  [      DATA_WIDTH-1:0] axi_slave_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave RID" *)
    output  [        ID_WIDTH-1:0] axi_slave_rid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave RLAST" *)
    output   axi_slave_rlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave RREADY" *)
    input   axi_slave_rready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave RRESP" *)
    output  [                 3:0] axi_slave_rresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave RUSER" *)
    output  [(USER_WIDTH > 0 ? USER_WIDTH : 1) -1:0] axi_slave_ruser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave RVALID" *)
    output   axi_slave_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave WDATA" *)
    input  [      DATA_WIDTH-1:0] axi_slave_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave WLAST" *)
    input   axi_slave_wlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave WREADY" *)
    output   axi_slave_wready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave WSTRB" *)
    input  [  (DATA_WIDTH/8)-1:0] axi_slave_wstrb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave WUSER" *)
    input  [(USER_WIDTH > 0 ? USER_WIDTH : 1) -1:0] axi_slave_wuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 axi_slave WVALID" *)
    input   axi_slave_wvalid
);

    assign axi_master_araddr = 'h870000000 + axi_slave_araddr[27:0];
    assign axi_master_arburst = axi_slave_arburst;
    assign axi_master_arcache = axi_slave_arcache;
    assign axi_master_arid = axi_slave_arid;
    assign axi_master_arlen = axi_slave_arlen;
    assign axi_master_arlock = axi_slave_arlock;
    assign axi_master_arprot = axi_slave_arprot;
    assign axi_master_arqos = axi_slave_arqos;
    assign axi_slave_arready = axi_master_arready;
    assign axi_master_arregion = axi_slave_arregion;
    assign axi_master_arsize = axi_slave_arsize;
    assign axi_master_aruser = axi_slave_aruser;
    assign axi_master_arvalid = axi_slave_arvalid;
    assign axi_master_awaddr = 'h870000000 + axi_slave_awaddr[27:0];//axi_slave_awaddr;
    assign axi_master_awburst = axi_slave_awburst;
    assign axi_master_awcache = axi_slave_awcache;
    assign axi_master_awid = axi_slave_awid;
    assign axi_master_awlen = axi_slave_awlen;
    assign axi_master_awlock = axi_slave_awlock;
    assign axi_master_awprot = axi_slave_awprot;
    assign axi_master_awqos = axi_slave_awqos;
    assign axi_slave_awready = axi_master_awready;
    assign axi_master_awregion = axi_slave_awregion;
    assign axi_master_awsize = axi_slave_awsize;
    assign axi_master_awuser = axi_slave_awuser;
    assign axi_master_awvalid = axi_slave_awvalid;
    assign axi_slave_bid = axi_master_bid;
    assign axi_master_bready = axi_slave_bready;
    assign axi_slave_bresp = axi_master_bresp;
    assign axi_slave_buser = axi_master_buser;
    assign axi_slave_bvalid = axi_master_bvalid;
    assign axi_slave_rdata = axi_master_rdata;
    assign axi_slave_rid = axi_master_rid;
    assign axi_slave_rlast = axi_master_rlast;
    assign axi_master_rready = axi_slave_rready;
    assign axi_slave_rresp = axi_master_rresp;
    assign axi_slave_ruser = axi_master_ruser;
    assign axi_slave_rvalid = axi_master_rvalid;
    assign axi_master_wdata = axi_slave_wdata;
    assign axi_master_wlast = axi_slave_wlast;
    assign axi_slave_wready = axi_master_wready;
    assign axi_master_wstrb = axi_slave_wstrb;
    assign axi_master_wuser = axi_slave_wuser;
    assign axi_master_wvalid = axi_slave_wvalid;

endmodule
