`timescale 1ns / 1ps

module FrameFormer_from_data # (
    parameter integer RAW_DATA_WIDTH = 256,
    parameter integer ETHERNET_DATA_WIDTH = 64
    )
    (
    input wire ACLK,
    input wire ARESETN,

    // From the data sender
    input wire send_valid,
    input wire [RAW_DATA_WIDTH-1:0] send_data,
    input wire[1:0] send_size, // 00: 8Btye, 01: 16Byte, 10: 24Byte, 11: 32Byte
    output wire send_ready,
    
    // To the Ethernet IP
    output wire [ETHERNET_DATA_WIDTH-1:0] M_AXIS_tdata,
    input wire M_AXIS_tready,
    output wire [7:0] M_AXIS_tkeep,
    output wire M_AXIS_tvalid,
    output wire M_AXIS_tlast,
    
    //specific helper values
    input wire [47:0] Destination_Address,
    input wire [47:0] Source_Address,
    input wire [15:0] Link_Type,
    input wire [15:0] SyncWord,
    input wire [13:0] Packet_Size

    );
    
    reg[13:0] total_data_done;
    reg[1:0] header_done;
    reg[2:0] data_done;
    reg send_ready_reg;
    
    always @ (posedge ACLK) begin
        if (!ARESETN) begin
            total_data_done <= 0;
            header_done <= 0;
            data_done <= 0;
            send_ready_reg <= 0;
        end
        else begin
        if (send_ready) begin
            send_ready_reg <= 0;
        end
        else begin
            send_ready_reg <= send_ready_reg;
        end
        if (M_AXIS_tvalid && M_AXIS_tready) begin
            if (header_done == 0) begin
                header_done <= header_done + 1;
            end
            else if (header_done == 1) begin
                header_done <= header_done + 1;
            end
            else if (header_done == 2) begin
                if (total_data_done == Packet_Size) begin
                    total_data_done <= 0;
                    header_done <= 0;
                end
                else if (send_valid && data_done <= send_size) begin
                    if (!send_ready) begin
                        if (data_done == send_size) begin
                            data_done <= 0;
                            send_ready_reg <= 1;
                        end else begin
                            data_done <= data_done + 1;
                        end
                    end
                    total_data_done <= total_data_done + 1;
                end
                else begin
                    total_data_done <= total_data_done + 1;
                end
            end
        end
        else begin
            total_data_done <= total_data_done;
            header_done <= header_done;
            data_done <= data_done;
        end
        end
    end

    assign M_AXIS_tdata = (header_done == 0) ? {Source_Address[15:0], Destination_Address} : 
                         (header_done == 1) ? {SyncWord, Link_Type, Source_Address[47:16]} :
                         (header_done == 2) ? (total_data_done == Packet_Size) ? 64'h5704 :
                                            (send_valid) ? (send_ready) ? 0 : ((data_done <= send_size) ? (send_data >> (ETHERNET_DATA_WIDTH * data_done)) : 0) 
                                            : 0
                                            : 0;

    assign M_AXIS_tkeep = (header_done == 2) ? (total_data_done == Packet_Size) ? 8'h07 : 0 : 0;
    assign M_AXIS_tlast = (header_done == 2) ? (total_data_done == Packet_Size) ? 1 : 0 : 0;    
    assign M_AXIS_tvalid = (!header_done && send_valid) || header_done;

    assign send_ready = send_ready_reg;

endmodule
