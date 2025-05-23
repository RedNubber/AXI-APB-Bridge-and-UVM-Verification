`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "x2p_parameter.h"
`include "transaction.sv"
`include "parameter.h"
`ifndef read_gen
`define read_gen
//=====================================================================================//
//========================            Read Generator        ===========================//
//=====================================================================================//
class generator_read extends uvm_sequence #(transaction);
    `uvm_object_utils(generator_read)
    transaction t;
    function new(string name = "generator_read");
        super.new(name);
    endfunction
    
    task body();
        read();
        read();
    endtask
    
    virtual task read();
        
        `ifdef AXI_MEM_SIZE_8_BIT
            t = transaction::type_id::create("t");
            
            start_item(t);
                // Thiết lập các tham số cho read
                t.arvalid = 1'b1;
                t.araddr  = config_addr;  // Địa chỉ đọc
                t.arsize  = burst_size;         // 4 bytes (32-bit)
                t.arlen   = length;              // Burst length 4
                t.arburst = burst_type;          // INCR burst
                t.arid    = 8'h12;          // ID của transaction
                t.arprot  = 3'b000;         // Normal non-secure access
                t.rready  = 1'b1;           // Sẵn sàng nhận dữ liệu
            finish_item(t);
         `elsif AXI_MEM_SIZE_16_BIT
            t = transaction::type_id::create("t");
            
            start_item(t);
                // Thiết lập các tham số cho read
                t.arvalid = 1'b1;
                t.araddr  = config_addr;  // Địa chỉ đọc
                t.arsize  = burst_size;         // 4 bytes (32-bit)
                t.arlen   = length;              // Burst length 4
                t.arburst = burst_type;          // INCR burst
                t.arid    = 8'h12;          // ID của transaction
                t.arprot  = 3'b000;         // Normal non-secure access
                t.rready  = 1'b1;           // Sẵn sàng nhận dữ liệu
            finish_item(t);
         `elsif AXI_MEM_SIZE_32_BIT
            t = transaction::type_id::create("t");
            
            start_item(t);
                // Thiết lập các tham số cho read
                t.arvalid = 1'b1;
                t.araddr  = config_addr;  // Địa chỉ đọc
                t.arsize  = burst_size;         // 4 bytes (32-bit)
                t.arlen   = length;              // Burst length 4
                t.arburst = burst_type;          // INCR burst
                t.arid    = 8'h12;          // ID của transaction
                t.arprot  = 3'b000;         // Normal non-secure access
                t.rready  = 1'b1;           // Sẵn sàng nhận dữ liệu
            finish_item(t);
         `elsif apb_reg
            t = transaction::type_id::create("t");
            
            start_item(t);
                // Thiết lập các tham số cho read
                t.arvalid = 1'b1;
                t.araddr  = config_addr;  // Địa chỉ đọc
                t.arsize  = burst_size;         // 4 bytes (32-bit)
                t.arlen   = length;              // Burst length 4
                t.arburst = burst_type;          // INCR burst
                t.arid    = 8'h12;          // ID của transaction
                t.arprot  = 3'b000;         // Normal non-secure access
                t.rready  = 1'b1;           // Sẵn sàng nhận dữ liệu
            finish_item(t);
         `endif
    endtask
endclass
`endif