`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_apb_data_parameter.h"
`include "parameter.h"


//=====================================================================================//
//==========================            Interface           ===========================//
//=====================================================================================//
interface top_if();
    logic                    aclk;
    logic                    pclk;
    logic                    aresetn;
    //logic                    preset_n;
    
    //Aw signal
    logic                    awvalid;
    logic [31:0]             awaddr;
    logic [2:0]              awsize;
    logic [7:0]              awlen;
    logic [1:0]              awburst;
    logic [7:0]              awid;
    logic [2:0]              awprot;
    logic                    awready;

    // Address read channel
    logic                    arvalid;
    logic [31:0]             araddr;
    logic [2:0]              arsize;
    logic [7:0]              arlen;
    logic [1:0]              arburst;
    logic [7:0]              arid;
    logic [2:0]              arprot;
    logic                    arready;

    // Write data channel
    logic                    wvalid;
    logic [31:0]             wdata;
    logic [3:0]              wstrb;
    logic                    wlast;
    logic                    wready;

    // Read data channel
    logic                    rready;
    logic                    rvalid;
    logic [1:0]              rresp;
    logic                    rlast;
    logic [7:0]              rid;
    logic [31:0]             rdata;

    // Write response channel
    logic                    bready;
    logic                    bvalid;
    logic [1:0]              bresp;
    logic [7:0]              bid;

    logic [31:0]                paddr;
    logic [31:0]                pwdata;
    logic [SLAVE_NUM-1:0]       psel;
    logic                       penable;
    logic [2:0]                 pprot;
    logic [3:0]                 pstrb;
    logic                       pwrite;
    
    logic [3:0][31:0]           prdata;
    logic [3:0]                 pslverr;
    logic [3:0]                 pready;
    
endinterface 
//=====================================================================================//
//==========================                Top             ===========================//
//=====================================================================================//
module tb2();
 
    test t;
    top_if vif();
    logic bready;
    initial begin
        vif.aclk = 0;
        `ifdef 250_25_MHz
            forever #2 vif.aclk = ~vif.aclk;
        `elsif 200_20_MHz
            forever #2.5 vif.aclk = ~vif.aclk;
        `elsif 100_10 MHz
            forever #5 vif.aclk = ~vif.aclk;
        `endif
    end
    
    initial begin
        vif.pclk = 0;
        `ifdef 250_25_MHz
            forever #20 vif.pclk = ~vif.pclk;
        `elsif 200_20_MHz
            forever #25 vif.pclk = ~vif.pclk;
        `elsif 100_10 MHz
            forever #50 vif.pclk = ~vif.pclk;
        `endif
    end
    initial begin
        vif.aresetn = 0;
        #1;        
        vif.aresetn = 1; 
    end
    
    initial begin
        #10;
        @(posedge vif.aclk);
        bready = 1;
    end
    Module_top dut (
        .ACLK(vif.aclk),
        .RESETn(vif.aresetn),
        .AWVALID(vif.awvalid),
        .AWADDR(vif.awaddr),
        .AWSIZE(vif.awsize),
        .AWLEN(vif.awlen),
        .AWBURST(vif.awburst),
        .AWID(vif.awid),
        .AWPROT(vif.awprot),
        .AWREADY(vif.awready),
        .ARVALID(vif.arvalid),
        .ARADDR(vif.araddr),
        .ARSIZE(vif.arsize),
        .ARLEN(vif.arlen),
        .ARBURST(vif.arburst),
        .ARID(vif.arid),
        .ARPROT(vif.arprot),
        .ARREADY(vif.arready),
        .WVALID(vif.wvalid),
        .WDATA(vif.wdata),
        .WSTRB(vif.wstrb),
        .WLAST(vif.wlast),
        .WREADY(vif.wready),
        .RREADY(vif.rready),
        .RVALID(vif.rvalid),
        .RRESP(vif.rresp),
        .RLAST(vif.rlast),
        .RID(vif.rid),
        .RDATA(vif.rdata),
        .BREADY(bready),
        .BVALID(vif.bvalid),
        .BRESP(vif.bresp),
        .BID(vif.bid),
        .PCLK(vif.pclk),
        //.PRESET_N(vif.aresetn),
        .PREADY(vif.pready),
        .PRDATA(vif.prdata),
        .PSLVERR(vif.pslverr),
        .PADDR(vif.paddr),
        .PWDATA(vif.pwdata),
        .PSEL(vif.psel),
        .PENABLE(vif.penable),
        .PPROT(vif.pprot),
        .PSTRB(vif.pstrb),
        .PWRITE(vif.pwrite)
    );
    
    
    initial begin
    t = new("TEST", null);
    uvm_config_db #(virtual top_if)::set(null,"*","vif",vif);
    uvm_top.set_report_verbosity_level(UVM_LOW);
    
    run_test();
    end 
 
    
endmodule

//end