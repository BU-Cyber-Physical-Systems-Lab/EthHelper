
################################################################
# This is a generated script based on design: FullPipelineSimulation
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source FullPipelineSimulation_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# AXIToStream_orchestrator_wrapper, FrameFormer_wrapper, OneShotEthReset_wrapper

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu9eg-ffvb1156-2-e
   set_property BOARD_PART xilinx.com:zcu102:part0:3.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name FullPipelineSimulation

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:axi_vip:1.1\
xilinx.com:ip:axis_dwidth_converter:1.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:sim_clk_gen:1.0\
xilinx.com:ip:util_idelay_ctrl:1.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:xxv_ethernet:3.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
AXIToStream_orchestrator_wrapper\
FrameFormer_wrapper\
OneShotEthReset_wrapper\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set gt_rtl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt_rtl ]


  # Create ports
  set Destination_Address_0 [ create_bd_port -dir I -from 47 -to 0 Destination_Address_0 ]
  set Link_Type_0 [ create_bd_port -dir I -from 15 -to 0 Link_Type_0 ]
  set Packet_Size_0 [ create_bd_port -dir I -from 13 -to 0 Packet_Size_0 ]
  set ResetAfter_0 [ create_bd_port -dir I -from 15 -to 0 ResetAfter_0 ]
  set ResetWidth_0 [ create_bd_port -dir I -from 15 -to 0 ResetWidth_0 ]
  set Source_Address_0 [ create_bd_port -dir I -from 47 -to 0 Source_Address_0 ]
  set SyncWord_0 [ create_bd_port -dir I -from 15 -to 0 SyncWord_0 ]
  set rxoutclksel_in_0_0 [ create_bd_port -dir I -from 2 -to 0 rxoutclksel_in_0_0 ]
  set submodule_resets_0 [ create_bd_port -dir I -from 5 -to 0 submodule_resets_0 ]
  set txoutclksel_in_0_0 [ create_bd_port -dir I -from 2 -to 0 txoutclksel_in_0_0 ]

  # Create instance: AXIToStream_orchestr_0, and set properties
  set block_name AXIToStream_orchestrator_wrapper
  set block_cell_name AXIToStream_orchestr_0
  if { [catch {set AXIToStream_orchestr_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $AXIToStream_orchestr_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: FrameFormer_wrapper_0, and set properties
  set block_name FrameFormer_wrapper
  set block_cell_name FrameFormer_wrapper_0
  if { [catch {set FrameFormer_wrapper_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $FrameFormer_wrapper_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.MAX_INTERNAL_SPACE {5} \
 ] $FrameFormer_wrapper_0

  # Create instance: OneShotEthReset_wrap_0, and set properties
  set block_name OneShotEthReset_wrapper
  set block_cell_name OneShotEthReset_wrap_0
  if { [catch {set OneShotEthReset_wrap_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $OneShotEthReset_wrap_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.RESET_MAX_WIDTH {16} \
   CONFIG.TIMER_MAX_WIDTH {16} \
 ] $OneShotEthReset_wrap_0

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.ECC_TYPE {0} \
 ] $axi_bram_ctrl_0

  # Create instance: axi_bram_ctrl_0_bram, and set properties
  set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 axi_bram_ctrl_0_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
 ] $axi_bram_ctrl_0_bram

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]

  # Create instance: axi_vip_0, and set properties
  set axi_vip_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_vip_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
 ] $axi_vip_0

  # Create instance: axis_dwidth_converter_0, and set properties
  set axis_dwidth_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0 ]
  set_property -dict [ list \
   CONFIG.M_TDATA_NUM_BYTES {8} \
 ] $axis_dwidth_converter_0

  # Create instance: rst_clk_75MHz_75M, and set properties
  set rst_clk_75MHz_75M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_75MHz_75M ]
  set_property -dict [ list \
   CONFIG.C_AUX_RESET_HIGH {1} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
 ] $rst_clk_75MHz_75M

  # Create instance: rst_clk_TX, and set properties
  set rst_clk_TX [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_TX ]
  set_property -dict [ list \
   CONFIG.C_AUX_RESET_HIGH {1} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
 ] $rst_clk_TX

  # Create instance: sim_clk_gen_0, and set properties
  set sim_clk_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:sim_clk_gen:1.0 sim_clk_gen_0 ]
  set_property -dict [ list \
   CONFIG.CLOCK_TYPE {Differential} \
   CONFIG.FREQ_HZ {156250000} \
 ] $sim_clk_gen_0

  # Create instance: sim_clk_gen_75MHZ, and set properties
  set sim_clk_gen_75MHZ [ create_bd_cell -type ip -vlnv xilinx.com:ip:sim_clk_gen:1.0 sim_clk_gen_75MHZ ]
  set_property -dict [ list \
   CONFIG.CLOCK_TYPE {Single_Ended} \
   CONFIG.FREQ_HZ {75000000} \
   CONFIG.INITIAL_RESET_CLOCK_CYCLES {100} \
   CONFIG.RESET_POLARITY {ACTIVE_HIGH} \
 ] $sim_clk_gen_75MHZ

  # Create instance: util_idelay_ctrl_0, and set properties
  set util_idelay_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_idelay_ctrl:1.0 util_idelay_ctrl_0 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {56} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_1

  # Create instance: xxv_ethernet_0, and set properties
  set xxv_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xxv_ethernet:3.1 xxv_ethernet_0 ]
  set_property -dict [ list \
   CONFIG.BASE_R_KR {BASE-R} \
   CONFIG.DIFFCLK_BOARD_INTERFACE {user_si570_sysclk} \
   CONFIG.GT_GROUP_SELECT {Quad_X1Y3} \
   CONFIG.INCLUDE_AXI4_INTERFACE {1} \
   CONFIG.INCLUDE_SHARED_LOGIC {1} \
   CONFIG.INCLUDE_STATISTICS_COUNTERS {1} \
   CONFIG.INCLUDE_USER_FIFO {1} \
   CONFIG.LANE1_GT_LOC {X1Y14} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $xxv_ethernet_0

  # Create interface connections
  connect_bd_intf_net -intf_net AXIToStream_orchestr_0_AXIM [get_bd_intf_pins AXIToStream_orchestr_0/AXIM] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net AXIToStream_orchestr_0_stream [get_bd_intf_pins AXIToStream_orchestr_0/stream] [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net FrameFormer_wrapper_0_M_AXIS [get_bd_intf_pins FrameFormer_wrapper_0/M_AXIS] [get_bd_intf_pins xxv_ethernet_0/axis_tx_0]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins axi_vip_0/M_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins AXIToStream_orchestr_0/AXIS] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins xxv_ethernet_0/s_axi_0]
  connect_bd_intf_net -intf_net axis_dwidth_converter_0_M_AXIS [get_bd_intf_pins FrameFormer_wrapper_0/S_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS]
  connect_bd_intf_net -intf_net sim_clk_gen_0_diff_clk [get_bd_intf_pins sim_clk_gen_0/diff_clk] [get_bd_intf_pins xxv_ethernet_0/gt_ref_clk]
  connect_bd_intf_net -intf_net xxv_ethernet_0_gt_serial_port [get_bd_intf_ports gt_rtl] [get_bd_intf_pins xxv_ethernet_0/gt_serial_port]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins rst_clk_TX/interconnect_aresetn]
  connect_bd_net -net Destination_Address_0_1 [get_bd_ports Destination_Address_0] [get_bd_pins FrameFormer_wrapper_0/Destination_Address]
  connect_bd_net -net Link_Type_0_1 [get_bd_ports Link_Type_0] [get_bd_pins FrameFormer_wrapper_0/Link_Type]
  connect_bd_net -net OneShotEthReset_wrap_0_OneShotReset [get_bd_pins OneShotEthReset_wrap_0/OneShotReset] [get_bd_pins xxv_ethernet_0/rx_reset_0] [get_bd_pins xxv_ethernet_0/tx_reset_0]
  connect_bd_net -net Packet_Size_0_1 [get_bd_ports Packet_Size_0] [get_bd_pins FrameFormer_wrapper_0/Packet_Size]
  connect_bd_net -net ResetAfter_0_1 [get_bd_ports ResetAfter_0] [get_bd_pins OneShotEthReset_wrap_0/ResetAfter]
  connect_bd_net -net ResetWidth_0_1 [get_bd_ports ResetWidth_0] [get_bd_pins OneShotEthReset_wrap_0/ResetWidth]
  connect_bd_net -net Source_Address_0_1 [get_bd_ports Source_Address_0] [get_bd_pins FrameFormer_wrapper_0/Source_Address]
  connect_bd_net -net SyncWord_0_1 [get_bd_ports SyncWord_0] [get_bd_pins FrameFormer_wrapper_0/SyncWord]
  connect_bd_net -net clk_75MHz_1 [get_bd_pins rst_clk_75MHz_75M/slowest_sync_clk] [get_bd_pins sim_clk_gen_75MHZ/clk] [get_bd_pins xxv_ethernet_0/dclk]
  connect_bd_net -net rst_clk_75MHz_75M1_peripheral_aresetn [get_bd_pins AXIToStream_orchestr_0/resetn] [get_bd_pins FrameFormer_wrapper_0/ARESETN] [get_bd_pins OneShotEthReset_wrap_0/ResetTrigger] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_vip_0/aresetn] [get_bd_pins axis_dwidth_converter_0/aresetn] [get_bd_pins rst_clk_TX/peripheral_aresetn] [get_bd_pins xxv_ethernet_0/s_axi_aresetn_0]
  connect_bd_net -net rst_clk_75MHz_75M_peripheral_reset [get_bd_pins rst_clk_75MHz_75M/peripheral_reset] [get_bd_pins xxv_ethernet_0/gtwiz_reset_rx_datapath_0] [get_bd_pins xxv_ethernet_0/gtwiz_reset_tx_datapath_0] [get_bd_pins xxv_ethernet_0/sys_reset]
  connect_bd_net -net rxoutclksel_in_0_0_1 [get_bd_ports rxoutclksel_in_0_0] [get_bd_pins xxv_ethernet_0/rxoutclksel_in_0]
  connect_bd_net -net sim_clk_gen_75MHZ_sync_rst [get_bd_pins rst_clk_75MHz_75M/aux_reset_in] [get_bd_pins sim_clk_gen_75MHZ/sync_rst]
  connect_bd_net -net submodule_resets_0_1 [get_bd_ports submodule_resets_0] [get_bd_pins AXIToStream_orchestr_0/submodule_resets]
  connect_bd_net -net txoutclksel_in_0_0_1 [get_bd_ports txoutclksel_in_0_0] [get_bd_pins xxv_ethernet_0/txoutclksel_in_0]
  connect_bd_net -net util_idelay_ctrl_0_rdy [get_bd_pins OneShotEthReset_wrap_0/aresetn] [get_bd_pins util_idelay_ctrl_0/rdy]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconstant_0/dout] [get_bd_pins xxv_ethernet_0/tx_preamblein_0]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconstant_1/dout] [get_bd_pins xxv_ethernet_0/ctl_tx_send_idle_0] [get_bd_pins xxv_ethernet_0/ctl_tx_send_lfi_0] [get_bd_pins xxv_ethernet_0/ctl_tx_send_rfi_0]
  connect_bd_net -net xxv_ethernet_0_gt_txn_out [get_bd_pins xxv_ethernet_0/gt_rxn_in] [get_bd_pins xxv_ethernet_0/gt_txn_out]
  connect_bd_net -net xxv_ethernet_0_gt_txp_out [get_bd_pins xxv_ethernet_0/gt_rxp_in] [get_bd_pins xxv_ethernet_0/gt_txp_out]
  connect_bd_net -net xxv_ethernet_0_tx_clk_out_0 [get_bd_pins AXIToStream_orchestr_0/clk] [get_bd_pins FrameFormer_wrapper_0/ACLK] [get_bd_pins OneShotEthReset_wrap_0/clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_vip_0/aclk] [get_bd_pins axis_dwidth_converter_0/aclk] [get_bd_pins rst_clk_TX/slowest_sync_clk] [get_bd_pins util_idelay_ctrl_0/ref_clk] [get_bd_pins xxv_ethernet_0/rx_core_clk_0] [get_bd_pins xxv_ethernet_0/s_axi_aclk_0] [get_bd_pins xxv_ethernet_0/tx_clk_out_0]
  connect_bd_net -net xxv_ethernet_0_user_tx_reset_0 [get_bd_pins rst_clk_TX/aux_reset_in] [get_bd_pins util_idelay_ctrl_0/rst] [get_bd_pins xxv_ethernet_0/user_tx_reset_0]

  # Create address segments
  assign_bd_address -offset 0x20000000 -range 0x00200000 -target_address_space [get_bd_addr_spaces AXIToStream_orchestr_0/AXIM] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x20000000 -range 0x00200000 -target_address_space [get_bd_addr_spaces axi_vip_0/Master_AXI] [get_bd_addr_segs AXIToStream_orchestr_0/AXIS/reg0] -force
  assign_bd_address -offset 0x44A00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces axi_vip_0/Master_AXI] [get_bd_addr_segs xxv_ethernet_0/s_axi_0/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


