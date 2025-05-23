`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "x2p_parameter.h"
`include "transaction.sv"
`include "parameter.h"
`ifndef gen
`define gen
//=====================================================================================//
//==========================            Generator           ===========================//
//=====================================================================================//
class generator extends uvm_sequence;
    `uvm_object_utils(generator)
    
    transaction t;
    
    function new(string name = "GEN");
        super.new(name);
    endfunction
    
    virtual task body();
       write(8'd200);
       write(8'd100);
    endtask
    virtual task write(logic [7:0] awid);
        `ifdef AXI_MEM_SIZE_8_BIT
           t = transaction::type_id::create("TRANS");
           start_item(t);
                t.awvalid = 1'b1;
                t.awaddr = config_addr;
                t.awsize = burst_size;
                t.awlen = length;
                t.awburst = burst_type;
                t.awid = awid;
                t.awprot = 3'b000;
                
                t.wdata = new[t.awlen + 1];
                for (int i = 0; i <= t.awlen; i++) begin
                    t.wdata[i] = $random;
                    t.wstrb = (burst_size == 3'd0) ? 4'b0001 :
                              (burst_size == 3'd1) ? 4'b0011 :
                              (burst_size == 3'd2) ? 4'b1111 : 4'b0000;
                end
           finish_item(t);
       `elsif AXI_MEM_SIZE_16_BIT
           t = transaction::type_id::create("TRANS");
           start_item(t);
                t.awvalid = 1'b1;
                t.awaddr = config_addr;
                t.awsize = burst_size;
                t.awlen = length;
                t.awburst = burst_type;
                t.awid = awid;
                t.awprot = 3'b000;
                
                t.wdata = new[t.awlen + 1];
                for (int i = 0; i <= t.awlen; i++) begin
                    t.wdata[i] = $random;
                    t.wstrb = (burst_size == 3'd0) ? 4'b0001 :
                              (burst_size == 3'd1) ? 4'b0011 :
                              (burst_size == 3'd2) ? 4'b1111 : 4'b0000;
                end
           finish_item(t);
       `elsif AXI_MEM_SIZE_32_BIT
            t = transaction::type_id::create("TRANS");
            start_item(t);
                t.awvalid = 1'b1;
                t.awaddr = config_addr;
                t.awsize = burst_size;
                t.awlen = length;
                t.awburst = burst_type;
                t.awid = awid;
                t.awprot = 3'b000;
                
                t.wdata = new[t.awlen + 1];
                for (int i = 0; i <= t.awlen; i++) begin
                    t.wdata[i] = $random;
                    t.wstrb = (burst_size == 3'd0) ? 4'b0001 :
                              (burst_size == 3'd1) ? 4'b0011 :
                              (burst_size == 3'd2) ? 4'b1111 : 4'b0000;
                end
            finish_item(t);
        `endif
    endtask
    
endclass
`endif