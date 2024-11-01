`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2023 02:18:44 PM
// Design Name: 
// Module Name: FrameFormer_TB
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
import FrameFormer_BD_axi4stream_vip_1_0_pkg::*;  //master
import FrameFormer_BD_axi4stream_vip_0_0_pkg::*; //slave

module FrameFormer_TB(

    );
    
    bit iclk,resetn;
    bit[47:0] sa,da;
    bit[15:0] lt,sw;
    bit[13:0] ps;
    bit [63:0]i;
    
    
    FrameFormer_BD_wrapper DUT(
        .ACLK_0(iclk),
        .ARESETN_0(resetn),
        .Destination_Address_0(da),
        .Source_Address_0(sa),
        .Link_Type_0(lt),
        .SyncWord_0(sw),
        .Packet_Size_0(ps)
    );
    
    FrameFormer_BD_axi4stream_vip_1_0_mst_t master;
    FrameFormer_BD_axi4stream_vip_0_0_slv_t sub;
    
    axi4stream_transaction wr_transaction;
    axi4stream_ready_gen ready_gen;
    
    always #5ns iclk = ~iclk;
    
    always @ (posedge iclk) begin
        lt<=16'h1337;
        sw<=16'hdead;
        sa<=48'hf00f00cafe12;
        da<=48'hb00b5cafecaf;
        ps<=16;
    end
    
    initial begin
        #5ns;
        resetn=0;

        #10ns;
        resetn=1;
        
        #20ns;
        
        ready_gen= new("ready_gen");
        
        
        master = new("master vip agent", DUT.FrameFormer_BD_i.axi4stream_vip_1.inst.IF);
        master.set_agent_tag("MASTER VIP");
        master.set_verbosity(400);
        master.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);

        sub = new("slave vip agent", DUT.FrameFormer_BD_i.axi4stream_vip_0.inst.IF);
        sub.set_agent_tag("SLAVE VIP");
        sub.set_verbosity(400);
        
        master.start_master(); 
        sub.start_slave(); 

        
        
        ready_gen.set_ready_policy(XIL_AXI4STREAM_READY_GEN_AFTER_VALID_OSC);
        ready_gen.set_low_time(4);
        ready_gen.set_high_time(2);
        sub.driver.send_tready(ready_gen);
        
        wr_transaction = master.driver.create_transaction("write transaction");
        wr_transaction.set_delay_range(2,2);
        wr_transaction.set_driver_return_item_policy(XIL_AXI4STREAM_NO_RETURN);
        wr_transaction.set_delay_policy(XIL_AXI4STREAM_DELAY_INSERTION_FROM_IDLE);

        // Master agent create write transaction
        for(i=0;i<=20;i=i+1) begin
            
            //$finish;
            // send the transaction to VIP interface
            //if (master.driver.is_driver_idle()) begin
                wr_transaction.randomize();
                master.driver.send(wr_transaction);
            //end
            

       
       end
        

        #100ns;

        $finish;
    end

    
endmodule
