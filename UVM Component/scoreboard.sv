`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "x2p_parameter.h"
`include "transaction.sv"
`include "parameter.h"
`ifndef sco
`define sco
//=====================================================================================//
//==========================            Scoreboard          ===========================//
//=====================================================================================//
`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_drv)
class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard);
    
    uvm_analysis_imp_mon #(transaction, scoreboard) mon_imp;
    uvm_analysis_imp_drv #(transaction, scoreboard) drv_imp;
    
    transaction queue_mon [$];
    transaction queue_drv [$];
  
    bit mon_full = 0;
    bit drv_full = 0;
    
    bit data_check = 0;
    
    int i = 0;
    int m = 0;
    transaction mon_txn;
    transaction drv_txn;
    
    string w_r;
    logic w_r_tran;
    
    logic [31:0] addr;
    logic [2:0]  bsize;
    logic [2:0]  bsize_display;
    `ifdef LENGTH_2
        string data_checker_array [2];
        logic [31:0] mon_array [2];
        logic [31:0] drv_array [2];
        logic [31:0] mon_addr_array[2];
        logic [31:0] drv_addr_array[2];
    `elsif LENGTH_4
        string data_checker_array [4];
        logic [31:0] mon_array [4];
        logic [31:0] drv_array [4];
        logic [31:0] mon_addr_array[4];
        logic [31:0] drv_addr_array[4];
    `elsif LENGTH_8
        string data_checker_array [8];
        logic [31:0] mon_array [8];
        logic [31:0] drv_array [8];
        logic [31:0] mon_addr_array[8];
        logic [31:0] drv_addr_array[8];
    `elsif LENGTH_16
        string data_checker_array [16];
        logic [31:0] mon_array [16];
        logic [31:0] drv_array [16];
        logic [31:0] mon_addr_array[16];
        logic [31:0] drv_addr_array[16];
    `endif
    
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_imp = new("mon_imp", this);
        drv_imp = new("drv_imp", this);
    endfunction 
    
    task run_phase(uvm_phase phase);
        `uvm_info("SCO", "Run Phase started", UVM_LOW)

        forever begin
            // Đợi khi có dữ liệu trong ít nhất một queue
            wait(queue_mon.size() > 0 || queue_drv.size() > 0);
            
            // Xử lý transaction từ monitor (nếu có)
            if(queue_mon.size() > 0) begin
                mon_txn = queue_mon.pop_front();
//                `uvm_info("SCO/MON", $sformatf("\n
//                    Monitor Data\n 
//                    Addr: 0x%h\n 
//                    %s: 0x%h\n", 
//                    mon_txn.paddr, 
//                    mon_txn.pwrite ? "WriteData" : "ReadData",
//                    mon_txn.pwrite ? mon_txn.pwdata : mon_txn.prdata[2]), UVM_LOW);
                    `ifdef AXI_MEM_SIZE_8_BIT
                        mon_array[m] = mon_txn.pwrite ? mon_txn.pwdata : mon_txn.prdata[0];
                    `elsif AXI_MEM_SIZE_16_BIT
                        mon_array[m] = mon_txn.pwrite ? mon_txn.pwdata : mon_txn.prdata[1];
                    `elsif AXI_MEM_SIZE_32_BIT
                        mon_array[m] = mon_txn.pwrite ? mon_txn.pwdata : mon_txn.prdata[2];
                    `endif
                    mon_addr_array[m] = mon_txn.paddr;
                    m++;
                    w_r = mon_txn.pwrite ? "WRITE" : "READ";
                    w_r_tran = mon_txn.pwrite ? 1 : 0;
                    if(m > length) 
                        begin
                            mon_full = 1;
                            m = 0;
                        end
                    else mon_full = 0;
            end
            
            // Xử lý transaction từ driver (nếu có)
            if(queue_drv.size() > 0) begin
                drv_txn = queue_drv.pop_front();
//                `uvm_info("SCO/DRV", $sformatf("\n
//                    Driver Data \n
//                    Addr: 0x%h\n 
//                    %s: 0x%h\n", 
//                    drv_txn.awaddr, 
//                    drv_txn.wvalid ? "WriteData" : "ReadData",
//                    drv_txn.wvalid ? drv_txn.wdata[i] : drv_txn.rdata), UVM_LOW);
                    drv_array[i] = drv_txn.wvalid ? drv_txn.wdata[i] : drv_txn.rdata;
                    drv_addr_array[i] = drv_txn.paddr;
                    addr = drv_txn.wvalid ? drv_txn.awaddr : drv_txn.araddr;
                    bsize = drv_txn.wvalid ? drv_txn.awsize : drv_txn.arsize;
                    bsize_display = (bsize == 0) ? 1 :
                                    (bsize == 1) ? 2 :
                                    (bsize == 2) ? 4 : 3;
                    i++;
                    w_r = drv_txn.wvalid ? "WRITE" : "READ";
                    w_r_tran = drv_txn.wvalid ? 1 : 0;
                    if(i > length) 
                        begin
                            drv_full = 1;
                            i = 0;                        end
                    else drv_full = 0;
                
            end
            compare();
            
            
        end
    endtask
    
    virtual function void compare();
        if(mon_full & drv_full) begin
            for(int k = 0; k < (length+1); k++) begin
                `ifdef BURST_SIZE_8
                    data_check = w_r_tran ? (drv_array[k] == mon_array[k]) : (drv_array[k] == {24'b0,mon_array[k][7:0]}) ;
                `elsif BURST_SIZE_16
                    data_check = w_r_tran ? (drv_array[k] == mon_array[k]) : (drv_array[k] == {16'b0,mon_array[k][15:0]});
                `elsif BURST_SIZE_32
                    data_check = (drv_array[k] == mon_array[k]);
                `endif
            
                if(data_check) begin
                    data_checker_array[k] = "PASS";
                    `uvm_info("SCO DATA CHECK PASS", "DATA MATCH", UVM_LOW)
                end
                else begin
                    data_checker_array[k] = "FAIL";
                    `uvm_info("SCO DATA CHECK FAIL", "DATA MISMATCH", UVM_LOW)
                end
            end
            
            `ifdef LENGTH_2
                `uvm_info("SCO DATA CHECK TABLE", $sformatf("\n\n\n
                                                                       COMPARE TABLE (%s)\n\n
                                                                       %s       : %h\n
                                                                       BURST TYPE   :%s\n
                                                                       BURST LENGTH : 2\n
                                                                       BURST SIZE   : %d byte\n
                                                                       %s\n
                    _________________________________________________________________________________________________________________________\n
                   |        PACKET         |         %s(AXI)       |        %s(APB)       |        PADDR        |       STATUS       |\n
                   -------------------------------------------------------------------------------------------------------------------------\n
                   |         [0]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [1]           |          %h         |         %h         |       %h      |        %s        |\n
                    ________________________________________________________________________________________________________________________\n
                    ",w_r,
                    w_r_tran ? "AWADDR" : "ARADDR",
                    addr, 
                    (burst_type == FIXED) ? "FIXED" : ((burst_type == INCR) ? "INCR" : "WRAP"),
                    //(length+1),
                    bsize_display,
                    w_r_tran ? "Master: AXI -> Slave: APB" : "Master: APB -> Slave: AXI",
                    w_r_tran ? "WDATA" : "RDATA", w_r_tran ? "PWDATA" : "PRDATA",
                    drv_array[0], mon_array[0], mon_addr_array[0], data_checker_array[0],
                    drv_array[1], mon_array[1], mon_addr_array[1], data_checker_array[1]), UVM_LOW)
            `elsif LENGTH_4
                `uvm_info("SCO DATA CHECK TABLE", $sformatf("\n\n\n
                                                                       COMPARE TABLE (%s)\n\n
                                                                       %s       : %h\n
                                                                       BURST TYPE   :%s\n
                                                                       BURST LENGTH : 4\n
                                                                       BURST SIZE   : %d byte\n
                                                                       %s\n
                    _________________________________________________________________________________________________________________________\n
                   |        PACKET         |         %s(AXI)       |        %s(APB)       |        PADDR        |       STATUS       |\n
                   -------------------------------------------------------------------------------------------------------------------------\n
                   |         [0]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [1]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [2]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [3]           |          %h         |         %h         |       %h      |        %s        |\n
                    ________________________________________________________________________________________________________________________\n
                    ",w_r,
                    w_r_tran ? "AWADDR" : "ARADDR",
                    addr, 
                    (burst_type == FIXED) ? "FIXED" : ((burst_type == INCR) ? "INCR" : "WRAP"),
                    //(length+1),
                    bsize_display, 
                    w_r_tran ? "Master: AXI -> Slave: APB" : "Master: APB -> Slave: AXI",
                    w_r_tran ? "WDATA" : "RDATA", w_r_tran ? "PWDATA" : "PRDATA",
                    drv_array[0], mon_array[0], mon_addr_array[0], data_checker_array[0],
                    drv_array[1], mon_array[1], mon_addr_array[1], data_checker_array[1],
                    drv_array[2], mon_array[2], mon_addr_array[2], data_checker_array[2],
                    drv_array[3], mon_array[3], mon_addr_array[3], data_checker_array[3]), UVM_LOW)
            `elsif LENGTH_8
                `uvm_info("SCO DATA CHECK TABLE", $sformatf("\n\n\n
                                                                       COMPARE TABLE (%s)\n\n
                                                                       %s       : %h\n
                                                                       BURST TYPE   :%s\n
                                                                       BURST LENGTH : 8\n
                                                                       BURST SIZE   : %d byte\n
                                                                       %s\n
                    _________________________________________________________________________________________________________________________\n
                   |        PACKET         |         %s(AXI)        |        %s(APB)       |        PADDR        |       STATUS       |\n
                   -------------------------------------------------------------------------------------------------------------------------\n
                   |         [0]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [1]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [2]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [3]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [4]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [5]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [6]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [7]           |          %h         |         %h         |       %h      |        %s        |\n
                    ________________________________________________________________________________________________________________________\n
                    ",w_r, 
                    w_r_tran ? "AWADDR" : "ARADDR",
                    addr, 
                    (burst_type == FIXED) ? "FIXED" : ((burst_type == INCR) ? "INCR" : "WRAP"),
                    //(length+1),
                    bsize_display,
                    w_r_tran ? "Master: AXI -> Slave: APB" : "Master: APB -> Slave: AXI",
                    w_r_tran ? "WDATA" : "RDATA", w_r_tran ? "PWDATA" : "PRDATA",
                    drv_array[0], mon_array[0], mon_addr_array[0], data_checker_array[0],
                    drv_array[1], mon_array[1], mon_addr_array[1], data_checker_array[1],
                    drv_array[2], mon_array[2], mon_addr_array[2], data_checker_array[2],
                    drv_array[3], mon_array[3], mon_addr_array[3], data_checker_array[3],
                    drv_array[4], mon_array[4], mon_addr_array[4], data_checker_array[4],
                    drv_array[5], mon_array[5], mon_addr_array[5], data_checker_array[5],
                    drv_array[6], mon_array[6], mon_addr_array[6], data_checker_array[6],
                    drv_array[7], mon_array[7], mon_addr_array[7], data_checker_array[7]), UVM_LOW)
            `elsif LENGTH_16
                `uvm_info("SCO DATA CHECK TABLE", $sformatf("\n\n\n
                                                                       COMPARE TABLE (%s)\n\n
                                                                       %s       : %h\n
                                                                       BURST TYPE   :%s\n
                                                                       BURST LENGTH : 16\n
                                                                       BURST SIZE   : %d byte\n
                                                                       %s\n
                    _________________________________________________________________________________________________________________________\n
                   |        PACKET         |         %s(AXI)        |        %s(APB)       |        PADDR        |       STATUS       |\n
                   -------------------------------------------------------------------------------------------------------------------------\n
                   |         [0]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [1]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [2]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [3]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [4]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [5]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [6]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [7]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [8]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [9]           |          %h         |         %h         |       %h      |        %s        |\n
                   |         [10]          |          %h         |         %h         |       %h      |        %s        |\n
                   |         [11]          |          %h         |         %h         |       %h      |        %s        |\n
                   |         [12]          |          %h         |         %h         |       %h      |        %s        |\n
                   |         [13]          |          %h         |         %h         |       %h      |        %s        |\n
                   |         [14]          |          %h         |         %h         |       %h      |        %s        |\n
                   |         [15]          |          %h         |         %h         |       %h      |        %s        |\n
                    ________________________________________________________________________________________________________________________\n
                    ",w_r, 
                    w_r_tran ? "AWADDR" : "ARADDR",
                    addr, 
                    (burst_type == FIXED) ? "FIXED" : ((burst_type == INCR) ? "INCR" : "WRAP"),
                    //(length+1),
                    bsize_display,
                    w_r_tran ? "Master: AXI -> Slave: APB" : "Master: APB -> Slave: AXI",
                    w_r_tran ? "WDATA" : "RDATA", w_r_tran ? "PWDATA" : "PRDATA",
                    drv_array[0], mon_array[0], mon_addr_array[0], data_checker_array[0],
                    drv_array[1], mon_array[1], mon_addr_array[1], data_checker_array[1],
                    drv_array[2], mon_array[2], mon_addr_array[2], data_checker_array[2],
                    drv_array[3], mon_array[3], mon_addr_array[3], data_checker_array[3],
                    drv_array[4], mon_array[4], mon_addr_array[4], data_checker_array[4],
                    drv_array[5], mon_array[5], mon_addr_array[5], data_checker_array[5],
                    drv_array[6], mon_array[6], mon_addr_array[6], data_checker_array[6],
                    drv_array[7], mon_array[7], mon_addr_array[7], data_checker_array[7],
                    drv_array[8], mon_array[8], mon_addr_array[8], data_checker_array[8],
                    drv_array[9], mon_array[9], mon_addr_array[9], data_checker_array[9],
                    drv_array[10], mon_array[10], mon_addr_array[10], data_checker_array[10],
                    drv_array[11], mon_array[11], mon_addr_array[11], data_checker_array[11],
                    drv_array[12], mon_array[12], mon_addr_array[12], data_checker_array[12],
                    drv_array[13], mon_array[13], mon_addr_array[13], data_checker_array[13],
                    drv_array[14], mon_array[14], mon_addr_array[14], data_checker_array[14],
                    drv_array[15], mon_array[15], mon_addr_array[15], data_checker_array[15]), UVM_LOW)
            `endif
            
            mon_full = 0;
            drv_full = 0;
        end
    endfunction
    
    virtual function void write_mon(transaction t);
//        `uvm_info("SCO/MON", $sformatf("Received from Monitor - Type: %s  - PWDATA: %h  -  PADDR: %h", 
//            t.pwrite ? "WRITE" : "READ", t.pwdata, t.paddr), UVM_LOW)
        queue_mon.push_back(t);
    endfunction
    
    virtual function void write_drv(transaction t);
//        `uvm_info("SCO/DRV", $sformatf("Received %s transaction - rvalid=%b, rdata=0x%h, wvalid = %b, wdata = %h", 
//              t.wvalid ? "WRITE" : "READ", t.rvalid, t.rdata, t.wvalid, t.wdata), UVM_LOW)
        queue_drv.push_back(t);
    endfunction
endclass
`endif