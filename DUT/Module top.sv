`timescale 1ns / 1ps

module Module_top(ACLK,
                   RESETn,
        // AW channel
                   AWVALID,
                   AWADDR,
                   AWSIZE,
                   AWLEN,
                   AWBURST,
                   AWID,
                   AWPROT,
                   AWREADY,
        // AR channel
                   ARVALID,
                   ARADDR,
                   ARSIZE,
                   ARLEN,
                   ARBURST,
                   ARID,
                   ARPROT,
                   ARREADY,
        // W channel
                   WVALID,
                   WDATA,
                   WSTRB,
                   WLAST,
                   WREADY,
        // R channel
                   RREADY,
                   RVALID,
                   RRESP,
                   RLAST,
                   RID,
                   RDATA,
        // B channel
                   BREADY,
                   BVALID,
                   BRESP,
                   BID,
        // APB 8, 16, 32bit
                   PCLK,
                   PSEL,
                   PRDATA,
                   PREADY,
                   PSLVERR,
                   
                   
                   PWRITE,
                   PENABLE,
                   PADDR,
                   PWDATA,
                   PSTRB,
                   PPROT

                    );
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;                
    input logic ACLK;
    input logic PCLK;
    input logic RESETn;
    
    input logic          AWVALID;
    input logic [31:0]   AWADDR;
    input logic [2:0]    AWSIZE;
    input logic [7:0]    AWLEN;
    input logic [1:0]    AWBURST;
    input logic [7:0]    AWID;
    input logic [2:0]    AWPROT;
    output logic         AWREADY;
    
    // AR channel
    input logic          ARVALID;
    input logic [31:0]   ARADDR;
    input logic [2:0]    ARSIZE;
    input logic [7:0]    ARLEN;
    input logic [1:0]    ARBURST;
    input logic [7:0]    ARID;
    input logic [2:0]    ARPROT;
    output logic         ARREADY;
 
    // W channel
    input logic          WVALID;
    input logic [31:0]   WDATA;
    input logic [3:0]    WSTRB;
    input logic          WLAST;
    output logic         WREADY;
    
    // R channel
    output logic         RVALID;
    output logic [31:0]  RDATA;
    output logic         RLAST;
    input logic          RREADY;
    output logic [1:0]   RRESP;
    output logic [7:0]   RID;
    
    // B channel
    input logic          BREADY;
    output logic         BVALID;
    output logic [1:0]   BRESP;
    output logic [7:0]   BID;
    
//    // APB slave0 - 8bit
//    output logic                     PSEL_0;
//    output logic [DATA_WIDTH -1:0]   PRDATA_0;
//    output logic                     PREADY_0;
//    output logic                     PSLVERR_0;
    
//    // APB slave1 - 16bit
//    output logic                     PSEL_1;
//    output logic [DATA_WIDTH -1:0]   PRDATA_1;
//    output logic                     PREADY_1;
//    output logic                     PSLVERR_1;
    
//    // APB slave2 - 32bit
//    output logic                     PSEL_2;
//    output logic [DATA_WIDTH -1:0]   PRDATA_2;
//    output logic                     PREADY_2;
//    output logic                     PSLVERR_2;
    // COMMON WIRE
    output logic                     PWRITE;
    output logic                     PENABLE;
    output logic [ADDR_WIDTH -1:0]   PADDR;
    output logic [DATA_WIDTH -1:0]   PWDATA;
    output logic [3:0]               PSTRB;
    output logic [2:0]               PPROT;
    
    assign PSEL_0 = PSEL[0];
    
    //INTERNAL
    output logic [3:0] PSEL;
    output logic [3:0][DATA_WIDTH -1:0] PRDATA;
    output logic [3:0] PSLVERR;
    output logic [3:0] PREADY;
    
    axi_apb_bridge_top axi_apb_bridge (.aclk(ACLK),
               .aresetn(RESETn),
			   .awvalid(AWVALID),
			   .awaddr(AWADDR),
			   .awsize(AWSIZE),
			   .awlen(AWLEN),
			   .awburst(AWBURST),
			   .awid(AWID),
			   .awprot(AWPROT),
			   .awready(AWREADY),
			   //address read chanel
			   .arvalid(ARVALID),
			   .araddr(ARADDR),
			   .arsize(ARSIZE),
			   .arlen(ARLEN),
			   .arburst(ARBURST),
			   .arid(ARID),
			   .arprot(ARPROT),
			   .arready(ARREADY),
			   //write data chanel
			   .wvalid(WVALID),
			   .wdata(WDATA),
			   .wstrb(WSTRB),
			   .wlast(WLAST),
			   .wready(WREADY),
			   //read data chanel
			   .rready(RREADY),
			   .rvalid(RVALID),
			   .rresp(RRESP),
			   .rlast(RLAST),
			   .rid(RID),
			   .rdata(RDATA),
			   //write respond chanel
			   .bready(BREADY),
			   .bvalid(BVALID),
			   .bresp(BRESP),
			   .bid(BID),
			   //APB Protocol
			   .pclk(PCLK),
			   .preset_n(RESETn),
			   .pready(PREADY),
			   .prdata(PRDATA),
			   .pslverr(PSLVERR),
			   .paddr(PADDR),
			   .pwdata(PWDATA),
			   .psel(PSEL),
			   .penable(PENABLE),
			   .pprot(PPROT),
			   .pstrb(PSTRB),
			   .pwrite(PWRITE)
               );
               
     apb_slave_8bit slave0(.PCLK(CLK),
                      .PRESETn(RESETn),
                      .PSEL(PSEL[0]),
                      .PENABLE(PENABLE),
                      .PWRITE(PWRITE),
                      .PPROT(PPROT),
                      .PADDR(PADDR),
                      .PWDATA(PWDATA),
                      .PRDATA(PRDATA[0]),
                      .PREADY(PREADY[0]),
                      .PSLVERR(PSLVERR[0]),
                      .PSTRB(PSTRB)
                      );
     apb_slave_16bit slave1(.PCLK(CLK),
                      .PRESETn(RESETn),
                      .PSEL(PSEL[1]),
                      .PENABLE(PENABLE),
                      .PWRITE(PWRITE),
                      .PPROT(PPROT),
                      .PADDR(PADDR),
                      .PWDATA(PWDATA),
                      .PRDATA(PRDATA[1]),
                      .PREADY(PREADY[1]),
                      .PSLVERR(PSLVERR[1]),
                      .PSTRB(PSTRB)
                      );
                      
     apb_slave_32bit slave2(.PCLK(CLK),
                      .PRESETn(RESETn),
                      .PSEL(PSEL[2]),
                      .PENABLE(PENABLE),
                      .PWRITE(PWRITE),
                      .PPROT(PPROT),
                      .PADDR(PADDR),
                      .PWDATA(PWDATA),
                      .PRDATA(PRDATA[2]),
                      .PREADY(PREADY[2]),
                      .PSLVERR(PSLVERR[2]),
                      .PSTRB(PSTRB)
                      );
endmodule
