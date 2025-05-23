`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "x2p_parameter.h"
`include "agent.sv"
`include "scoreboard.sv"
`ifndef envir
`define envir

//=====================================================================================//
//==========================                Env             ===========================//
//=====================================================================================//


class env extends uvm_env;
`uvm_component_utils(env)
agent a;
 
function new(string name, uvm_component parent);
super.new(name, parent);
endfunction
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
`uvm_info("ENV", "Build Phase", UVM_NONE);
 a = agent::type_id::create("AGENT",this);
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
`uvm_info("ENV", "Connect Phase", UVM_NONE);
endfunction
 
 
 
 
virtual task run_phase(uvm_phase phase);
`uvm_info("ENV", "Run Phase", UVM_NONE);
endtask
 
virtual function void report_phase(uvm_phase phase);
super.report_phase(phase);
`uvm_info("ENV", "Report Phase", UVM_NONE);
endfunction
 
endclass
`endif