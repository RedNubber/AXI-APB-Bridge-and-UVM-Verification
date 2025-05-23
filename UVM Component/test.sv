`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "x2p_parameter.h"
`include "env.sv"
`include "generator.sv"
`include "read_generator.sv"
`ifndef base_test
`define base_test

//=====================================================================================//
//==========================               Test             ===========================//
//=====================================================================================//
class test extends uvm_test;
    `uvm_component_utils(test)
     
    env e;
    generator gen;
    generator_read gen_r;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
 
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TEST", "Build Phase", UVM_NONE);
        e = env::type_id::create("ENV",this);
        gen = generator::type_id::create("GEN");
        gen_r = generator_read::type_id::create("GEN READ");
    endfunction
     
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        print();
    endfunction
     
     
    virtual task run_phase(uvm_phase phase);
        `uvm_info("TEST", "Run Phase", UVM_NONE);
        phase.raise_objection(this);
            fork
                gen.start(e.a.sequencer);  // Start the sequence on the sequencer
                gen_r.start(e.a.sequencer);
            join
        phase.drop_objection(this);

endtask
 
 
endclass
`endif