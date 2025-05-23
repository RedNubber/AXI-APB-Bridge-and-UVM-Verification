`ifndef TRANS
`define TRANS
`include "uvm_macros.svh"
import uvm_pkg::*;
//=====================================================================================//
//==========================           Transaction          ===========================//
//=====================================================================================//
class transaction extends uvm_sequence_item;
//==================       AW SIGNAL       =================//
    logic        awvalid;
    logic [31:0] awaddr;
    logic [2:0]  awsize;
    logic [7:0]  awlen;
    logic [1:0]  awburst;
    logic [7:0]  awid;
    logic [2:0]  awprot;
    logic        awready;
    
//==================       AR SIGNAL       =================//
    logic        arvalid;
    logic [31:0] araddr;
    logic [2:0]  arsize;
    logic [7:0]  arlen;
    logic [1:0]  arburst;
    logic [7:0]  arid;
    logic [2:0]  arprot;
    logic        arready;
    
//==================       W SIGNAL        =================//
    logic             wvalid;
    logic      [31:0] wdata [];
    logic      [3:0]  wstrb;
    logic             wlast;
    logic             wready;
    
//==================       R SIGNAL        =================//
    logic        rvalid;
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic [7:0]  rid;
    logic        rlast;
    logic        rready;
    
//==================       B SIGNAL        =================//
    logic        bready;
    logic        bvalid;
    logic [1:0]  bresp;
    logic [7:0]  bid;
    
//==================         APB           =================//
    logic [31:0]           paddr;
    logic [31:0]           pwdata;
    logic [3:0]            psel;
    logic                  penable;
    logic [31:0]           prdata [3:0];
    logic                  pwrite;



function new(string name = "TRANS");
    super.new(name);
endfunction

`uvm_object_utils_begin(transaction)
//==================       AW SIGNAL       =================//
    `uvm_field_int(awvalid, UVM_DEFAULT)
    `uvm_field_int(awaddr, UVM_DEFAULT)
    `uvm_field_int(awsize, UVM_DEFAULT)
    `uvm_field_int(awlen, UVM_DEFAULT)
    `uvm_field_int(awburst, UVM_DEFAULT)
    `uvm_field_int(awid, UVM_DEFAULT)
    `uvm_field_int(awprot, UVM_DEFAULT)
    `uvm_field_int(awready, UVM_DEFAULT)
    
//==================       AR SIGNAL       =================//
    `uvm_field_int(arvalid, UVM_DEFAULT)
    `uvm_field_int(araddr, UVM_DEFAULT)
    `uvm_field_int(arsize, UVM_DEFAULT)
    `uvm_field_int(arlen, UVM_DEFAULT)
    `uvm_field_int(arburst, UVM_DEFAULT)
    `uvm_field_int(arid, UVM_DEFAULT)
    `uvm_field_int(arprot, UVM_DEFAULT)
    `uvm_field_int(arready, UVM_DEFAULT)
    
//==================       W SIGNAL        =================//
    `uvm_field_int(wvalid, UVM_DEFAULT)
    `uvm_field_array_int(wdata, UVM_DEFAULT)
    `uvm_field_int(wstrb, UVM_DEFAULT)
    `uvm_field_int(wlast, UVM_DEFAULT)
    `uvm_field_int(wready, UVM_DEFAULT)
    
//==================       R SIGNAL        =================//
    `uvm_field_int(rvalid, UVM_DEFAULT)
    `uvm_field_int(rdata, UVM_DEFAULT)
    `uvm_field_int(rresp, UVM_DEFAULT)
    `uvm_field_int(rid, UVM_DEFAULT)
    `uvm_field_int(rlast, UVM_DEFAULT)
    `uvm_field_int(rready, UVM_DEFAULT)
    
    
//==================       B SIGNAL        =================//
    `uvm_field_int(bresp, UVM_DEFAULT)
    `uvm_field_int(bid, UVM_DEFAULT)
    `uvm_field_int(bvalid, UVM_DEFAULT)
    `uvm_field_int(bready, UVM_DEFAULT)
//==================          APB          =================//   
    `uvm_field_int(paddr, UVM_DEFAULT)
    `uvm_field_int(pwdata, UVM_DEFAULT)
    `uvm_field_int(psel, UVM_DEFAULT)
    `uvm_field_int(penable, UVM_DEFAULT)
    `uvm_field_int(pwrite, UVM_DEFAULT)
    `uvm_field_sarray_int(prdata, UVM_DEFAULT)
`uvm_object_utils_end


endclass
`endif