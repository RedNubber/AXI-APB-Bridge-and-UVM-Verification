`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "x2p_parameter.h"
`include "transaction.sv"

`ifndef monitor
`define monitor
//=====================================================================================//
//==========================              Monitor           ===========================//
//=====================================================================================//

class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)
     
     transaction t;
     virtual top_if vif;
     uvm_analysis_port #(transaction) send;
    function new(string name, uvm_component parent);
        super.new(name,parent);
        send = new("WRITE", this);
    endfunction
     
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("MON", "Build Phase", UVM_NONE);
        if (!uvm_config_db#(virtual top_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No interface found")
        t = transaction::type_id::create("t");
    endfunction
     
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("MON", "Connect Phase", UVM_NONE);
    endfunction
     
    virtual task run_phase(uvm_phase phase);
        `uvm_info("MON", "Run Phase", UVM_NONE);
        
        forever begin
            @(vif.paddr);
              @(vif.penable);
                if(vif.pwrite == 1)
                    begin
                    t.paddr     = vif.paddr;
                    t.pwdata    = vif.pwdata;
                    t.pwrite    = vif.pwrite;
                    send.write(t);  
                    end
                else if(vif.pwrite == 0)begin
                    t.paddr     = vif.paddr;
                    t.pwrite    = vif.pwrite;
                    t.prdata[0] = vif.prdata[0];
                    t.prdata[1] = vif.prdata[1];
                    t.prdata[2] = vif.prdata[2];
                    t.prdata[3] = vif.prdata[3];
                    
                    
                    send.write(t);        
                end
            
            
        end
    endtask
 
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("MON", "Report Phase", UVM_NONE);
        
    endfunction
 
endclass
`endif