`include "uvm_macros.svh"
import uvm_pkg::*;

`include "monitor.sv"
`include "driver.sv"
`include "scoreboard.sv"
`ifndef agent
`define agent

//=====================================================================================//
//==========================              Agent             ===========================//
//=====================================================================================//


class agent extends uvm_agent;
    `uvm_component_utils(agent)
     
    monitor mon;
    driver drv;
    scoreboard sco;
    uvm_sequencer #(transaction) sequencer;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AGENT", "Build Phase", UVM_NONE);
         mon = monitor::type_id::create("MON",this);
         drv = driver::type_id::create("DRV", this);
         sco = scoreboard::type_id::create("SCO", this);
         sequencer = uvm_sequencer #(transaction)::type_id::create("SEQ", this); 
    endfunction
 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AGENT", "Connect Phase", UVM_NONE);
        mon.send.connect(sco.mon_imp);
        drv.item_collected_port.connect(sco.drv_imp);
        drv.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
     
     
    virtual task run_phase(uvm_phase phase);
        `uvm_info("AGENT", "Run Phase", UVM_NONE);
    endtask
     
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("AGENT", "Report Phase", UVM_NONE);
    endfunction
 
endclass
`endif