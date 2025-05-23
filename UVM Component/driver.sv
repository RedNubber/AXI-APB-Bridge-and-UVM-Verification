`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "x2p_parameter.h"
`include "transaction.sv"
`include "parameter.h"
`ifndef driver
`define driver

//=====================================================================================//
//==========================              Driver            ===========================//
//=====================================================================================//
class driver extends uvm_driver#(transaction);
    `uvm_component_utils(driver)
     virtual top_if vif;
     transaction t;
     uvm_analysis_port #(transaction) item_collected_port;
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
     
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("DRV", "Build Phase", UVM_NONE);
        t = transaction::type_id::create("TRANS");
        if(!uvm_config_db #(virtual top_if)::get(this, "", "vif",vif))
                `uvm_info("DRV", "Unable to read db", UVM_NONE);
    endfunction
 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("DRV", "Connect Phase", UVM_NONE);
    endfunction
 

    virtual task run_phase(uvm_phase phase);
        `uvm_info("DRV", "Run Phase", UVM_NONE);
        forever begin
            seq_item_port.get_next_item(t);
            `uvm_info("DRV", "Get package", UVM_LOW)
            t.print();
            if (t.awvalid == 1) begin
                
                 drive_write_transaction(t);
                 
            end
            else if (t.arvalid == 1) begin
                 @(vif.pclk);
                 #1;
                 drive_read_transaction(t);
                 //item_collected_port.write(t);
            end
        seq_item_port.item_done();
        
        `uvm_info("DRV debug", "send to scoreboard", UVM_LOW)
    end
    endtask
    
    
    task drive_write_transaction(transaction t);
        fork
        begin
        @(posedge vif.aclk);
        vif.wvalid <= 1;
        end
        vif.awvalid <= 1;
        
        vif.awaddr <= t.awaddr;
        vif.awsize <= t.awsize;
        vif.awlen <= t.awlen;
        vif.awburst <= t.awburst;
        vif.awid <= t.awid;
        vif.awprot <= t.awprot;
            for (int i = 0; i <= t.awlen; i++) begin
                @(posedge vif.aclk iff vif.wready); 
                vif.wdata = t.wdata[i];
                vif.wstrb = t.wstrb;
                vif.wlast = (i == t.awlen);
                t.pwrite = vif.pwrite;
                #0.5;
                t.wvalid = vif.wvalid;
                
                
                item_collected_port.write(t);
                
            end
            begin
                @(posedge vif.aclk iff (vif.awready && vif.wready));
                #1;
                vif.awvalid <= 0;
                
            end
        join
        @(posedge vif.aclk);
        vif.wvalid <= 0;
        
        
    endtask
    
    task drive_read_transaction(transaction t);
        @(posedge vif.aclk iff vif.arready);
        vif.arvalid <= 1;
        vif.araddr  <= t.araddr;
        vif.arsize  <= t.arsize;
        vif.arlen   <= t.arlen;
        vif.arburst <= t.arburst;
        vif.arid    <= t.arid;
        vif.arprot  <= t.arprot;
        t.wvalid    <= vif.wvalid;
        @(posedge vif.aclk);
        vif.arvalid <= 0;
        
        
        @(posedge vif.aclk);
        vif.rready <= 1;
        
        for (int i = 0; i <= t.arlen; i++) begin
            
            @(posedge vif.aclk iff vif.rvalid);
            t.pwrite = vif.pwrite;
            t.rdata  = vif.rdata;
            t.rvalid = 1;

            item_collected_port.write(t);
            
            if (i == t.arlen) begin
                if (!vif.rlast) begin
                    `uvm_error("DRV", "rlast not asserted on final beat")
                end
            end
        end
        
        vif.rready <= 0;
    endtask
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("DRV", "Report Phase", UVM_NONE);
    endfunction
 
endclass
`endif