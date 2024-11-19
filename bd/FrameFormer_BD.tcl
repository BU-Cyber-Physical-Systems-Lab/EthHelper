
################################################################
# This is a generated script based on design: FrameFormer_BD
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
# source FrameFormer_BD_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# FrameFormer_wrapper

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu9eg-ffvb1156-2-e
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name FrameFormer_BD

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
xilinx.com:ip:axi4stream_vip:1.1\
xilinx.com:ip:axis_dwidth_converter:1.1\
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
FrameFormer_wrapper\
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

  # Create ports
  set ACLK_0 [ create_bd_port -dir I -type clk ACLK_0 ]
  set ARESETN_0 [ create_bd_port -dir I -type rst ARESETN_0 ]
  set Destination_Address_0 [ create_bd_port -dir I -from 47 -to 0 Destination_Address_0 ]
  set FFMState_0 [ create_bd_port -dir O -from 13 -to 0 FFMState_0 ]
  set FFMisReady_0 [ create_bd_port -dir O FFMisReady_0 ]
  set FFSFFM_Data_Transfer_0 [ create_bd_port -dir O -from 63 -to 0 FFSFFM_Data_Transfer_0 ]
  set FFSTail_0 [ create_bd_port -dir O -from 3 -to 0 FFSTail_0 ]
  set FFSisEmpty_0 [ create_bd_port -dir O FFSisEmpty_0 ]
  set FFSisFull_0 [ create_bd_port -dir O FFSisFull_0 ]
  set Link_Type_0 [ create_bd_port -dir I -from 15 -to 0 Link_Type_0 ]
  set Packet_Size_0 [ create_bd_port -dir I -from 13 -to 0 Packet_Size_0 ]
  set Source_Address_0 [ create_bd_port -dir I -from 47 -to 0 Source_Address_0 ]
  set SyncWord_0 [ create_bd_port -dir I -from 15 -to 0 SyncWord_0 ]

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
   CONFIG.MAX_INTERNAL_SPACE {8} \
 ] $FrameFormer_wrapper_0

  # Create instance: axi4stream_vip_0, and set properties
  set axi4stream_vip_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi4stream_vip:1.1 axi4stream_vip_0 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {SLAVE} \
   CONFIG.TDATA_NUM_BYTES {8} \
 ] $axi4stream_vip_0

  # Create instance: axi4stream_vip_1, and set properties
  set axi4stream_vip_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi4stream_vip:1.1 axi4stream_vip_1 ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.INTERFACE_MODE {MASTER} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
 ] $axi4stream_vip_1

  # Create instance: axis_dwidth_converter_0, and set properties
  set axis_dwidth_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0 ]
  set_property -dict [ list \
   CONFIG.HAS_MI_TKEEP {0} \
   CONFIG.M_TDATA_NUM_BYTES {8} \
 ] $axis_dwidth_converter_0

  # Create interface connections
  connect_bd_intf_net -intf_net FrameFormer_wrapper_0_M_AXIS [get_bd_intf_pins FrameFormer_wrapper_0/M_AXIS] [get_bd_intf_pins axi4stream_vip_0/S_AXIS]
  connect_bd_intf_net -intf_net axi4stream_vip_1_M_AXIS [get_bd_intf_pins axi4stream_vip_1/M_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_dwidth_converter_0_M_AXIS [get_bd_intf_pins FrameFormer_wrapper_0/S_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS]

  # Create port connections
  connect_bd_net -net ACLK_0_1 [get_bd_ports ACLK_0] [get_bd_pins FrameFormer_wrapper_0/ACLK] [get_bd_pins axi4stream_vip_0/aclk] [get_bd_pins axi4stream_vip_1/aclk] [get_bd_pins axis_dwidth_converter_0/aclk]
  connect_bd_net -net ARESETN_0_1 [get_bd_ports ARESETN_0] [get_bd_pins FrameFormer_wrapper_0/ARESETN] [get_bd_pins axi4stream_vip_0/aresetn] [get_bd_pins axi4stream_vip_1/aresetn] [get_bd_pins axis_dwidth_converter_0/aresetn]
  connect_bd_net -net Destination_Address_0_1 [get_bd_ports Destination_Address_0] [get_bd_pins FrameFormer_wrapper_0/Destination_Address]
  connect_bd_net -net FrameFormer_wrapper_0_FFMState [get_bd_ports FFMState_0] [get_bd_pins FrameFormer_wrapper_0/FFMState]
  connect_bd_net -net FrameFormer_wrapper_0_FFMisReady [get_bd_ports FFMisReady_0] [get_bd_pins FrameFormer_wrapper_0/FFMisReady]
  connect_bd_net -net FrameFormer_wrapper_0_FFSFFM_Data_Transfer [get_bd_ports FFSFFM_Data_Transfer_0] [get_bd_pins FrameFormer_wrapper_0/FFSFFM_Data_Transfer]
  connect_bd_net -net FrameFormer_wrapper_0_FFSTail [get_bd_ports FFSTail_0] [get_bd_pins FrameFormer_wrapper_0/FFSTail]
  connect_bd_net -net FrameFormer_wrapper_0_FFSisEmpty [get_bd_ports FFSisEmpty_0] [get_bd_pins FrameFormer_wrapper_0/FFSisEmpty]
  connect_bd_net -net FrameFormer_wrapper_0_FFSisFull [get_bd_ports FFSisFull_0] [get_bd_pins FrameFormer_wrapper_0/FFSisFull]
  connect_bd_net -net Link_Type_0_1 [get_bd_ports Link_Type_0] [get_bd_pins FrameFormer_wrapper_0/Link_Type]
  connect_bd_net -net Packet_Size_0_1 [get_bd_ports Packet_Size_0] [get_bd_pins FrameFormer_wrapper_0/Packet_Size]
  connect_bd_net -net Source_Address_0_1 [get_bd_ports Source_Address_0] [get_bd_pins FrameFormer_wrapper_0/Source_Address]
  connect_bd_net -net SyncWord_0_1 [get_bd_ports SyncWord_0] [get_bd_pins FrameFormer_wrapper_0/SyncWord]

  # Create address segments


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


