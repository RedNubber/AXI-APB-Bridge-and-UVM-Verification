module axi_apb_bridge (// AXI protocol
            aclk,
            aresetn,
			// Address write chanel
			awvalid,
			awready,
			awaddr,
			awsize,
			awlen,
			awburst,
			awid,
			awprot,
			// Address read chanel
			arvalid,
			arready,
			araddr,
			arsize,
			arlen,
			arburst,
			arid,
			arprot,
			// Write data chanel
			wvalid,
			wready,
			wdata,
			wstrb,
			wlast,
			// Read data chanel
			rvalid,
			rready,
			rlast,
			rresp,
			rid,
			rdata,
			// Write respond chanel
			bvalid,
			bready,
			bresp,
			bid,
			// APB protocol
			pclk,
			preset_n,
			paddr,
			pwdata,
			psel,
			penable,
			pprot,
			pready,
			pstrb,
			pwrite,
			prdata,
			pslverr,
			pselReg,
			preadyReg,
			pslverrReg,
			prdataReg
            );
  //iclude parameter file
  `include "axi_apb_data_parameter.h"
  //ports declaration
  //AXI protocol
  input logic                     aclk;
  input logic                     aresetn;
  // Address write chanel
  input  logic                    awvalid;
  input  logic [31:0]             awaddr;
  input  logic [2:0]              awsize;
  input  logic [7:0]              awlen;
  input  logic [1:0]              awburst;
  input  logic [7:0]              awid;
  input  logic [2:0]              awprot;
  output logic                    awready;
  // address read chanel
  input  logic                    arvalid;
  input  logic [31:0]             araddr;
  input  logic [2:0]              arsize;
  input  logic [7:0]              arlen;
  input  logic [1:0]              arburst;
  input  logic [7:0]              arid;
  input  logic [2:0]              arprot;
  output logic                    arready;
  //write data chanel
  input  logic                    wvalid;
  input  logic [31:0]             wdata;
  input  logic [3:0]              wstrb;
  input  logic                    wlast;
  output logic                    wready;
  //read data chanel
  input  logic                    rready;
  output logic                    rvalid;
  output logic [1:0]              rresp;
  output logic                    rlast;
  output logic [7:0]              rid;
  output logic [31:0]             rdata;
  //write respond chanel
  input  logic                    bready;
  output logic                    bvalid;
  output logic [1:0]              bresp;
  output logic [7:0]              bid;
  //APB protocol
  input  logic                    pclk;
  input  logic                    preset_n;
  input  logic [SLAVE_NUM-1:0]      pready;
  input  logic [SLAVE_NUM-1:0][31:0] prdata;
  input  logic [SLAVE_NUM-1:0]      pslverr;
  output logic [31:0]             paddr;
  output logic [31:0]             pwdata;
  output logic [SLAVE_NUM-1:0]      psel;
  output logic                    penable;
  output logic [2:0]              pprot;
  output logic [3:0]              pstrb;
  output logic                    pwrite;
  //reg
  output logic                    pselReg;
  input                           preadyReg;
  input                           pslverrReg;
  input [31:0]                    prdataReg;
  //internal signals
  //ASFIFO_AW
  logic                           asfifoAwFull;
  logic                           asfifoAwNotFull;
  logic                           asfifoAwEmpty;
  logic                           asfifoAwNotEmpty;
  logic                           asfifoAwWe;
  logic                           asfifoAwRe;
  logic [31:0]                    asfifoAwAwaddr;
  logic [7:0]                     asfifoAwAwid;
  logic [7:0]                     asfifoAwCtrlAwlen;
  logic [2:0]                     asfifoAwCtrlAwsize;
  logic [1:0]                     asfifoAwCtrlAwburst;
  logic [2:0]                     asfifoAwCtrlAwprot;
  //ASFIFO_AR
  logic                           asfifoArFull;
  logic                           asfifoArNotFull;
  logic                           asfifoArEmpty;
  logic                           asfifoArNotEmpty;
  logic                           asfifoArWe;
  logic                           asfifoArRe;
  logic [31:0]                    asfifoArAraddr;
  logic [7:0]                     asfifoArArid;
  logic [7:0]                     asfifoArCtrlArlen;
  logic [2:0]                     asfifoArCtrlArsize;
  logic [1:0]                     asfifoArCtrlArburst;
  logic [2:0]                     asfifoArCtrlArprot;
  //ASFIFO_WD
  logic                           asfifoWdFull;
  logic                           asfifoWdNotFull;
  logic                           asfifoWdEmpty;
  logic                           asfifoWdNotEmpty;
  logic                           asfifoWdWe;
  logic                           asfifoWdRe;
  logic [31:0]                    asfifoWdWdata;
  logic [3:0]                     asfifoWdWstrb;
  //ASFIFO_RD
  logic                           asfifoRdFull;
  logic                           asfifoRdNotFull;
  logic                           asfifoRdEmpty;
  logic                           asfifoRdNotEmpty;
  logic                           asfifoRdWe;
  logic                           asfifoRdRe;
  //RD_CH
  logic[1:0]                      rChRresp;
  //logic                           rChRlast;
  
  //ASFIFO_B
  logic                           asfifoBFull;
  logic                           asfifoBEmpty;
  logic                           asfifoBBvalid;
  logic [1:0]                     asfifoBBresp;
  logic [7:0]                     asfifoBId;
  logic                           asfifoBWe;
  logic                           asfifoBRe;
  logic                           Btrans_complete;
  logic                           Btrans_complete2;
  
  //READ/WRITE DECODER
  logic [1:0]                     RD_WR_sig;
  logic [1:0]                     RD_WR_nextsig;
  logic [1:0]                     nextSel;
  //DATA DECODER
  logic                           pslverrX;
  logic [31:0]                    prdataX;
  logic [31:0]                    prdatax_temp;
  logic                           preadyX;
  logic                           transCompleted;
  logic                           decError;
  logic                           transCntEn;
  logic [31:0]                    startAddr;
  logic [SLAVE_NUM-1:0]           sel;
  logic                           selReg;
  logic [7:0]                     selectLen;
  logic [2:0]                     selectSize;      
  logic [2:0]                     burst_size;      
  logic [7:0]                     transferCounter;
  logic                           transfer;
  logic [1:0]                     nextState;
  logic [1:0]                     currentState;
  logic                           fsmCal;
  logic [1:0]                     burstMode;
  logic [31:0]                    incrNextTransAddr;
  logic [31:0]                    wrapNextTransAddr;
  logic [2:0]                     bitNum;
  logic [2:0]                     bit3Addr;
  logic [3:0]                     bit4Addr;
  logic [4:0]                     bit5Addr;
  logic [5:0]                     bit6Addr;
  logic [SLAVE_NUM-1:0]           preadyOut;
  logic [SLAVE_NUM-1:0]           pslverrOut;
  logic [SLAVE_NUM-1:0][31:0]     prdataOut;
  logic [7:0]                     cnt_transfer;
  logic                           update;
  logic                           selRes;
  logic                           transEn;
  logic                           pselRes;
  logic [31:0]                    prdataRegOut;
  //body

  //          AXI_APB_BRIDGE_ASFIFO_AR
  asfifo #(.DATA_WIDTH(AXI_APB_BRIDGE_ASFIFO_AR_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) ar_asfifo (
  .clk_wr(aclk),
  .clk_rd(pclk),
  .rst_n(aresetn),
  .wr(asfifoArWe),
  .rd(asfifoArRe),
  .data_in({araddr[31:0], arid[7:0], arlen[7:0], arsize[2:0], arburst[1:0], arprot[2:0]}),
  .fifo_empty(asfifoArEmpty),
  .fifo_full(asfifoArFull),
  .data_out({asfifoArAraddr[31:0], asfifoArArid[7:0], asfifoArCtrlArlen[7:0], asfifoArCtrlArsize[2:0], asfifoArCtrlArburst[1:0], asfifoArCtrlArprot[2:0]})
  );
  //Logic
  assign asfifoArNotFull  = ~asfifoArFull;
  assign asfifoArNotEmpty = ~asfifoArEmpty;
  assign arready         = asfifoArNotFull;
  assign asfifoArWe       = arready & arvalid;
  assign asfifoArRe       = asfifoArNotEmpty  & transCompleted & RD_WR_sig[0];


  //          AXI_APB_BRIDGE_ASFIFO_RD
  asfifo #(.DATA_WIDTH(AXI_APB_BRIDGE_ASFIFO_RD_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) rd_asfifo(
  .clk_wr(pclk),
  .clk_rd(aclk),
  .rst_n(aresetn),
  .wr(asfifoRdWe),
  .rd(asfifoRdRe),
  .data_in({prdataX[31:0], rChRresp[1:0], asfifoArArid[7:0]}),
  .fifo_empty(asfifoRdEmpty),
  .fifo_full(asfifoRdFull),
  .data_out({rdata[31:0], rresp[1:0], rid[7:0]})
  );
  //Logic
  assign asfifoRdNotFull  = ~asfifoRdFull;
  assign asfifoRdNotEmpty = ~asfifoRdEmpty;
  assign rvalid          = asfifoRdNotEmpty;
  assign asfifoRdRe       = rvalid & rready;
  assign transCntEn      = (|psel[SLAVE_NUM-1:0] | pselRes | pselReg) & penable & preadyX;
  assign asfifoRdWe       = asfifoRdNotFull & transCntEn & ~pwrite;


  //          RD_CH
  //rChRresp
  always_comb begin
    if(~pslverrX)
	  rChRresp = OKAY;
	else if(decError)
	  rChRresp = DECERR;
	else
	  rChRresp = PSLVERR;
  end
  //rlast
  always_comb begin
    if(transCompleted & RD_WR_sig[0])
	  rlast = 1'b1;
	else
      rlast = 1'b0;	
  end


  //          AXI_APB_BRIDGE_ASFIFO_AW
  asfifo #(.DATA_WIDTH(AXI_APB_BRIDGE_ASFIFO_AW_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) aw_asfifo(
  .clk_wr(aclk),
  .clk_rd(pclk),
  .rst_n(aresetn),
  .wr(asfifoAwWe),
  .rd(asfifoAwRe),
  .data_in({awaddr[31:0], awid[7:0], awlen[7:0], awsize[2:0], awburst[1:0], awprot[2:0]}),
  .fifo_empty(asfifoAwEmpty),
  .fifo_full(asfifoAwFull),
  .data_out({asfifoAwAwaddr[31:0], asfifoAwAwid[7:0], asfifoAwCtrlAwlen[7:0], asfifoAwCtrlAwsize[2:0], asfifoAwCtrlAwburst[1:0], asfifoAwCtrlAwprot[2:0]})
  );
  //Logic
  assign asfifoAwNotFull  = ~asfifoAwFull;
  assign asfifoAwNotEmpty = ~asfifoAwEmpty;
  assign awready         = asfifoAwNotFull;
  assign asfifoAwWe       = awready & awvalid;
  assign asfifoAwRe       = asfifoAwNotEmpty & transCompleted & RD_WR_sig[1];


  //          AXI_APB_BRIDGE_ASFIFO_WD
  asfifo #(.DATA_WIDTH(AXI_APB_BRIDGE_ASFIFO_WD_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) wd_asfifo(
  .clk_wr(aclk),
  .clk_rd(pclk),
  .rst_n(aresetn),
  .wr(asfifoWdWe),
  .rd(asfifoWdRe),
  .data_in({wdata[31:0], wstrb[3:0]}),
  .fifo_empty(asfifoWdEmpty),
  .fifo_full(asfifoWdFull),
  .data_out({asfifoWdWdata[31:0], asfifoWdWstrb[3:0]})
  );
  //logic
  assign asfifoWdNotFull  = ~asfifoWdFull;
  assign asfifoWdNotEmpty = ~asfifoWdEmpty;
  assign wready          = asfifoWdNotFull;
  assign asfifoWdWe       = wvalid & wready;
  assign asfifoWdRe       = asfifoWdNotEmpty & RD_WR_sig[1] & (currentState == ACCESS);


//  //          B_CH
//  //bresp
//  always_ff @(posedge pclk, negedge aresetn) begin
//    if(~aresetn)
//	  bresp[1:0] <= OKAY;
//    else if(transCompleted & RD_WR_sig[1]) begin
//	  if(~pslverrX)
//	    bresp[1:0] <= OKAY;
//	  else if(decError)
//	    bresp[1:0] <= DECERR;
//      else
//	    bresp[1:0] <= PSLVERR;
//	end
//  end
//  //bid
//  always_ff @(posedge pclk, negedge aresetn) begin
//    if(~aresetn)
//	  bid[7:0] <= 8'd0;
//    else if(transCompleted & RD_WR_sig[1])
//	  bid[7:0] <= asfifoAwAwid[7:0];
//	else
//	  bid[7:0] <= 8'd0;
//  end
//  //bvalid
//  always_ff @(posedge pclk, negedge aresetn) begin
//    if(~aresetn)
//	  bvalid <= 1'b0;
//	else if(transCompleted & RD_WR_sig[1])
//	  bvalid <= 1'b1;
//	else
//	  bvalid <= 1'b0;
//  end
always_ff @(posedge pclk, negedge aresetn) begin
    if(~aresetn)
	  asfifoBBresp[1:0] <= OKAY;
    else if(transCompleted & RD_WR_sig[1]) begin
	  if(~pslverrX)
	    asfifoBBresp[1:0] <= OKAY;
	  else if(decError)
	    asfifoBBresp[1:0] <= DECERR;
      else
	    asfifoBBresp[1:0] <= PSLVERR;
	end
  end
  //bid
  always_ff @(posedge pclk, negedge aresetn) begin
    if(~aresetn)
	  asfifoBId[7:0] <= 8'd0;
    else if(transCompleted & RD_WR_sig[1])
	  asfifoBId[7:0] <= asfifoAwAwid[7:0];
	else
	  asfifoBId[7:0] <= 8'd0;
  end
  //bvalid
  always_ff @(posedge pclk, negedge aresetn) begin
    if(~aresetn)
	  asfifoBBvalid <= 1'b0;
	else if(transCompleted & RD_WR_sig[1])
	   begin
	       Btrans_complete <= 1'b1;
	       asfifoBBvalid <= 1'b1;
	   end
	else
	   begin
	       asfifoBBvalid <= 1'b0;
	       Btrans_complete <= 1'b0;
	   end
  end
  always_ff @(posedge aclk, negedge aresetn) begin
    if(~aresetn)
	  Btrans_complete <= 1'b0;
	if(transCompleted)
	   Btrans_complete2 <= 1'b1;
	else
	   Btrans_complete2 <= 1'b0;
  end
  //checked to here
  asfifo #(.DATA_WIDTH(AXI_APB_BRIDGE_ASFIFO_WD_DATA_WIDTH), .POINTER_WIDTH(POINTER_WIDTH)) b_asfifo(
  .clk_wr(pclk),
  .clk_rd(aclk),
  .rst_n(aresetn),
  .wr(asfifoBWe),
  .rd(asfifoBRe),
  .data_in({asfifoBBresp[1:0],asfifoBBvalid,asfifoBId[7:0]}),
  .fifo_empty(asfifoBEmpty),
  .fifo_full(asfifoBFull),
  .data_out({bresp[1:0],bvalid,bid[7:0]})
  );
  //logic
  //assign asfifoWdNotFull  = ~asfifoWdFull;
  //assign asfifoWdNotEmpty = ~asfifoWdEmpty;
  //assign wready          = asfifoWdNotFull;
  assign asfifoBWe       = Btrans_complete;
  assign asfifoBRe       = Btrans_complete2;

  //            READ_WRITE DECODER
  //nextSel0
  always_comb begin
    if(RD_WR_sig[0])
	  nextSel[0] = 1'b1;
	else if(~nextSel[1])
	  nextSel[0] = 1'b0;
	else if(asfifoArNotEmpty)
	  nextSel[0] = 1'b0;
	else
	  nextSel[0] = 1'b1;
  end

  //nextSel1
  always_comb begin
    if(RD_WR_sig[1])
	  nextSel[1] = 1'b1;
	else if(~nextSel[0])
	  nextSel[1] = 1'b0;
	else if(asfifoAwNotEmpty)
	  nextSel[1] = 1'b0;
	else
	  nextSel[1] = 1'b1;
  end
  
  //RD_WR_nextsig[1]
  always_comb begin
    if(~nextSel[0])
	  RD_WR_nextsig[1] = 1'b0;
	else if(asfifoAwNotEmpty)
	  RD_WR_nextsig[1] = 1'b1;
	else
	  RD_WR_nextsig[1] = RD_WR_sig[1];
  end

  //RD_WR_nextsig[0]
  always_comb begin
    if(~nextSel[1])
	  RD_WR_nextsig[0] = 1'b0;
	else if(asfifoArNotEmpty)
	  RD_WR_nextsig[0] = 1'b1;
	else
	  RD_WR_nextsig[0] = RD_WR_sig[0];
  end
  
  //RD_WR_sig
  assign update = (RD_WR_sig[0] & asfifoAwNotEmpty & ~asfifoArNotEmpty) | transCompleted;
  always_ff @(posedge pclk, negedge aresetn) begin
    if(~aresetn)
	  RD_WR_sig[1:0] <= 2'b01;
	else if(update)
    //else if(transCompleted || (RD_WR_sig[0] == 1'b1 && asfifoAwNotEmpty == 1'b1))
	  RD_WR_sig[1:0] <= RD_WR_nextsig[1:0];
	else
	  RD_WR_sig[1:0] <= RD_WR_sig[1:0];	  
  end


  //          DATA_DECODER
  //startAddr
  assign startAddr[31:0] = RD_WR_sig[0] ? asfifoArAraddr[31:0] : asfifoAwAwaddr[31:0];
  generate
    if(SLAVE_NUM >= 1) begin
	  assign selReg  = (startAddr[31:0] >= A_START_REG)     & (startAddr[31:0] <= A_END_REG);
	  assign sel[0]  = (startAddr[31:0] >= A_START_SLAVE0)  & (startAddr[31:0] <= A_END_SLAVE0);
	end
	if(SLAVE_NUM >= 2)
	  assign sel[1]  = (startAddr[31:0] >= A_START_SLAVE1)  & (startAddr[31:0] <= A_END_SLAVE1);
	if(SLAVE_NUM >= 3)
	  assign sel[2]  = (startAddr[31:0] >= A_START_SLAVE2)  & (startAddr[31:0] <= A_END_SLAVE2);
	if(SLAVE_NUM >= 4)
	  assign sel[3]  = (startAddr[31:0] >= A_START_SLAVE3)  & (startAddr[31:0] <= A_END_SLAVE3);
  endgenerate

  //selRes
  generate
    if(SLAVE_NUM == 1)
	  assign selRes  = (startAddr[31:0] < A_START_REG)|(startAddr[31:0] > A_END_SLAVE0);
	if(SLAVE_NUM == 2)
	  assign selRes  = (startAddr[31:0] < A_START_REG)|(startAddr[31:0] > A_END_SLAVE1);
	if(SLAVE_NUM == 3)
	  assign selRes  = (startAddr[31:0] < A_START_REG)|(startAddr[31:0] > A_END_SLAVE2);
	if(SLAVE_NUM == 4)
	  assign selRes  = (startAddr[31:0] < A_START_REG)|(startAddr[31:0] > A_END_SLAVE3);
  endgenerate

  //selectLen
  assign selectLen[7:0] = RD_WR_sig[0] ?  asfifoArCtrlArlen[7:0] : asfifoAwCtrlAwlen[7:0];

  //transCompleted
  assign transCompleted = (transferCounter[7:0] == selectLen[7:0] + 1'b1) ? 1'b1 : 1'b0;
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  transferCounter[7:0] <= 8'd0;
    else begin
      casez({transCntEn, transCompleted})
	    2'b?1:  transferCounter[7:0] <= 8'd0;
	    2'b10:  transferCounter[7:0] <= transferCounter[7:0] + 1'b1;
		default transferCounter[7:0] <= transferCounter[7:0];
	  endcase
	end	
  end

  //decError
  generate
    if(SLAVE_NUM == 1)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE0);
	else if(SLAVE_NUM == 2)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE1);
	else if(SLAVE_NUM == 3)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE2);
	else if(SLAVE_NUM == 4)
	  assign decError = (startAddr[31:0] < A_START_REG) | (startAddr[31:0] > A_END_SLAVE3);
  endgenerate

  //pslverrX, preadyX
  assign preadyX  = |preadyOut[SLAVE_NUM-1:0] | pselRes | pselReg & preadyReg;
  assign pslverrX = |pslverrOut[SLAVE_NUM-1:0]| pselRes | pselReg & pslverrReg;
  generate
    genvar i;
	for (i = 0; i <= SLAVE_NUM-1; i = i + 1) begin: decPreadyAndPslverr
	  assign preadyOut[i]  = psel[i] & pready[i];
	  assign pslverrOut[i] = psel[i] & pslverr[i];
	end
  endgenerate
  
  //prdataX
  assign prdataRegOut = pselReg ? prdataReg : 32'd0;
  assign prdataX = (selectSize == 3'h2) ? (prdataOut[SLAVE_NUM-1]                | prdataRegOut) : 
                   (selectSize == 3'h1) ? ({16'b0,prdataOut[SLAVE_NUM-1][15:0]}  | prdataRegOut) :
                   (selectSize == 3'h0) ? ({24'b0,prdataOut[SLAVE_NUM-1][7:0]}   | prdataRegOut) : 32'hx;
  assign prdataOut[0] = psel[0] ? prdata[0] : 32'd0;
  generate
    genvar j;
	for(j = 1; j <= SLAVE_NUM-1; j = j + 1) begin: decPrdata
	  assign prdataOut[j] = psel[j] ? prdata[j] : prdataOut[j-1];
	end
  endgenerate

  //transfer
  assign transEn = |sel[SLAVE_NUM-1:0] | selRes | selReg;
  
  //assign transfer = |sel[SLAVE_NUM:0] | selRes;
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  transfer <= 1'b0;
    else if(cnt_transfer[7:0] >= selectLen[7:0] + 1'b1)
	  transfer <= 1'b0;
	else if(transEn)
	  transfer <= 1'b1;
	else
	  transfer <= 1'b0;
  end
  //always_ff @(posedge pclk, negedge preset_n) begin
    //if(~preset_n)
	 // transfer <= 1'b0;
	//else if(transfer)
	 // transfer <= 1'b0;
	//else if(|sel[SLAVE_NUM:0])//
	//  transfer <= 1'b1;
  //end
  //assign transfer = |sel[SLAVE_NUM:0];
  
  //cnt_transfer
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  cnt_transfer[7:0] <= 8'd0;
	else if(transCompleted)
	  cnt_transfer[7:0] <= 8'd0;
	//else if((currentState == IDLE && transfer == 1'b1)|(currentState == ACCESS && transfer == 1'b1))
	else if(transfer & (currentState == ACCESS || currentState == IDLE))
	  cnt_transfer <= cnt_transfer + 1'b1;
  end
  
  //nextState FSM
  always_comb begin
    case(currentState[1:0])
	  IDLE: begin
	    if(transfer)
		  nextState[1:0] = SETUP;
		else
		  nextState[1:0] = IDLE;
	  end
	  SETUP: nextState[1:0] = ACCESS;
	  ACCESS: begin
	    if(~preadyX)
		  nextState[1:0] = ACCESS;
		else if(transfer)
		  nextState[1:0] = SETUP;
		else
		  nextState[1:0] = IDLE;
	  end
	  default nextState[1:0] = IDLE;
	endcase
  end
  //currentState FSM
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  currentState[1:0] <= IDLE;
	else
	  currentState[1:0] <= nextState[1:0];
  end
  
  //psel
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n) begin
	  psel[SLAVE_NUM-1:0] <= 0;
	  pselReg <= 0;
	  pselRes <= 0;
	end
	else begin
	  case(currentState[1:0])
	    IDLE:begin
    	  psel[SLAVE_NUM-1:0] <= 0;
		  pselRes             <= 0;
		  pselReg             <= 0;
		end
	    SETUP:begin
      	  psel[SLAVE_NUM-1:0] <= sel[SLAVE_NUM-1:0];
		  pselRes           <= selRes;
		  pselReg           <= selReg;
		end
	    ACCESS:begin
		  psel[SLAVE_NUM-1:0] <= psel[SLAVE_NUM-1:0];
		  pselRes             <= pselRes;
		  pselReg             <= pselReg;
		end
	  endcase
	end
  end
  
  //penable
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  penable <= 1'b0;
	else begin
	  case(currentState[1:0])
	    IDLE:   penable <= 1'b0;
		SETUP:  penable <= 1'b0;
		ACCESS: penable <= 1'b1;
	  endcase
	end
  end
  
  //paddr
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  paddr[31:0] = 32'd0;
	else begin
	  case(currentState[1:0])
	    IDLE: paddr[31:0] <= 32'd0;
		SETUP: begin
		  if(~fsmCal)
		    paddr[31:0] <= startAddr[31:0];
		  else begin
		    case(burstMode[1:0])
			  2'b00:  paddr[31:0] <= paddr[31:0];
			  2'b01:  paddr[31:0] <= incrNextTransAddr[31:0];
			  2'b10:  paddr[31:0] <= wrapNextTransAddr[31:0];
			  default paddr[31:0] <= 32'd0;
			endcase
		  end
		end
		ACCESS: paddr[31:0] <= paddr[31:0];
	  endcase
	end
  end
  
  //fsmCal
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  fsmCal <= 1'b0;
	else if(transCompleted)
	  fsmCal <= 1'b0;
	else
	  fsmCal <= |psel[SLAVE_NUM-1:0] | pselReg;
  end
  
  //            incrNextTransAddr
//  assign incrNextTransAddr[31:0] = paddr[31:0] + burst_size;
assign incrNextTransAddr[31:0] = (psel[0] == 1)                       ? (paddr[31:0] + burst_size)   :
                                 (psel[1] == 1 && burst_size == 3'h1) ? (paddr[31:0] + burst_size)   :
                                 (psel[1] == 1 && burst_size == 3'h2) ? (paddr[31:0] + burst_size/2) :
                                 (psel[1] == 1 && burst_size == 3'h4) ? (paddr[31:0] + burst_size/2) :
                                 (psel[2] == 1 && burst_size == 3'h1) ? (paddr[31:0] + burst_size)   :
                                 (psel[2] == 1 && burst_size == 3'h2) ? (paddr[31:0] + burst_size/2) :
                                 (psel[2] == 1 && burst_size == 3'h4) ? (paddr[31:0] + burst_size/4) : paddr[31:0];
  //burstMode
  assign burstMode[1:0] = (RD_WR_sig[0] == 1'b1) ? asfifoArCtrlArburst[1:0] : asfifoAwCtrlAwburst[1:0];
  //bitNum
  always_comb begin
    case(selectLen[7:0])
	  8'd1:  bitNum[2:0] = 3'b011;
	  8'd3:  bitNum[2:0] = 3'b100;
	  8'd7:  bitNum[2:0] = 3'b101;
	  8'd15: bitNum[2:0] = 3'b110;
	  default bitNum[2:0] = 3'bx;
	endcase
  end
  //bit3Addr, bit4Addr, bit5Addr, bit6Addr    - Case of 32 bit burst size
  always_comb begin
    if(bitNum[2:0] == 3'b011)
	  bit3Addr[2:0] = (selectSize == 3'd2 && psel[0]) ? (paddr[2:0] + burst_size)                   :
                      (selectSize == 3'd2 && psel[1]) ? (paddr[2:0] + burst_size/2)                 :
                      (selectSize == 3'd2 && psel[2]) ? (paddr[2:0] + burst_size/4)                 :
	                  (selectSize == 3'd1 && psel[0]) ? ({paddr[2],(paddr[1:0] + burst_size)})      :
	                  (selectSize == 3'd1 && psel[1]) ? ({paddr[2],(paddr[1:0] + burst_size/2)})    :
	                  (selectSize == 3'd1 && psel[2]) ? ({paddr[2],(paddr[1:0] + burst_size/2)})    :
	                  (selectSize == 3'd0)            ? ({paddr[2:1],(paddr[0:0] + burst_size)})    : 3'bxxx;
	else
	  bit3Addr[2:0] = 3'd0;
  end
  always_comb begin
    if(bitNum[2:0] == 3'b100)
	  bit4Addr[3:0] = (selectSize == 3'd2 && psel[0]) ? (paddr[3:0] + burst_size)                   :
	                  (selectSize == 3'd2 && psel[1]) ? (paddr[3:0] + burst_size/2)                 :
	                  (selectSize == 3'd2 && psel[2]) ? (paddr[3:0] + burst_size/4)                 :
	                  (selectSize == 3'd1 && psel[0]) ? ({paddr[3],(paddr[2:0] + burst_size)})      :
	                  (selectSize == 3'd1 && psel[1]) ? ({paddr[3],(paddr[2:0] + burst_size/2)})    :
	                  (selectSize == 3'd1 && psel[2]) ? ({paddr[3],(paddr[2:0] + burst_size/2)})    :
	                  (selectSize == 3'd0)            ? ({paddr[3:2],(paddr[1:0] + burst_size)})    : 4'bxxxx;
	else
	  bit4Addr[3:0] = 4'd0;
  end
  always_comb begin
    if(bitNum[2:0] == 3'b101)
	  bit5Addr[4:0] = (selectSize == 3'd2 && psel[0]) ? (paddr[4:0] + burst_size)                   :
                      (selectSize == 3'd2 && psel[1]) ? (paddr[4:0] + burst_size/2)                 :
                      (selectSize == 3'd2 && psel[2]) ? (paddr[4:0] + burst_size/4)                 :
	                  (selectSize == 3'd1 && psel[0]) ? ({paddr[4],(paddr[3:0] + burst_size)})      :
	                  (selectSize == 3'd1 && psel[1]) ? ({paddr[4],(paddr[3:0] + burst_size/2)})    :
	                  (selectSize == 3'd1 && psel[2]) ? ({paddr[4],(paddr[3:0] + burst_size/2)})    :
	                  (selectSize == 3'd0)            ? ({paddr[4:3],(paddr[2:0] + burst_size)})    : 5'bxxxxx;
	else
	  bit5Addr[4:0] = 5'd0;
  end
  always_comb begin
    if(bitNum[2:0] == 3'b110)
	  bit6Addr[5:0] = (selectSize == 3'd2 && psel[0]) ? (paddr[5:0] + burst_size)                   :
                      (selectSize == 3'd2 && psel[1]) ? (paddr[5:0] + burst_size/2)                 :
                      (selectSize == 3'd2 && psel[2]) ? (paddr[5:0] + burst_size/4)                 :
	                  (selectSize == 3'd1 && psel[0]) ? ({paddr[5],(paddr[4:0] + burst_size)})      :
	                  (selectSize == 3'd1 && psel[1]) ? ({paddr[5],(paddr[4:0] + burst_size/2)})    :
	                  (selectSize == 3'd1 && psel[2]) ? ({paddr[5],(paddr[4:0] + burst_size/2)})    :
	                  (selectSize == 3'd0)            ? ({paddr[5:4],(paddr[3:0] + burst_size)})    : 6'bxxxxxx;
	else
	  bit6Addr[5:0] = 6'd0;
  end
  //================   burst_size addition      Khoa begin    ==========================//
   assign selectSize[2:0] = RD_WR_sig[0] ?  asfifoArCtrlArsize[2:0] : asfifoAwCtrlAwsize[2:0];
   always_comb begin
    case(selectSize[2:0])
      3'd0:  burst_size[2:0] = 3'h1;
	  3'd1:  burst_size[2:0] = 3'h2;
	  3'd2:  burst_size[2:0] = 3'h4;
	  default burst_size[2:0] = 3'bx;
	endcase
  end
  //================   burst_size addition      Khoa end    ==========================//    
  //wrapNextTransAddr
  //================   addr step logic change with type of slave   Khoa debug begin ==//
  always_comb begin
    case(bitNum[2:0])
	  3'b011: wrapNextTransAddr[31:0] = (burst_size == 3'h4 && psel[0]) ? {paddr[31:3], bit3Addr[2:0]} :
	                                    (burst_size == 3'h4 && psel[1]) ? {paddr[31:2], bit3Addr[1:0]} :
                                        (burst_size == 3'h4 && psel[2]) ? {paddr[31:1], bit3Addr[0]  } : 
	                                    (burst_size == 3'h2 && psel[0]) ? {paddr[31:2], bit3Addr[1:0]} :
	                                    (burst_size == 3'h2 && psel[1]) ? {paddr[31:1], bit3Addr[0]  } :
	                                    (burst_size == 3'h2 && psel[2]) ? {paddr[31:1], bit3Addr[0]  } :
	                                    (burst_size == 3'h1 && psel[0]) ? {paddr[31:1], bit3Addr[0]  } :
	                                    (burst_size == 3'h1 && psel[1]) ? {paddr[31:1], bit3Addr[0]  } :
	                                    (burst_size == 3'h1 && psel[2]) ? {paddr[31:1], bit3Addr[0]  } : 
	                                    32'h7777_7777;
	  3'b100: wrapNextTransAddr[31:0] = (burst_size == 3'h4 && psel[0]) ? {paddr[31:4], bit4Addr[3:0]} :
	                                    (burst_size == 3'h4 && psel[1]) ? {paddr[31:3], bit4Addr[2:0]} :
                                        (burst_size == 3'h4 && psel[2]) ? {paddr[31:2], bit4Addr[1:0]} : 
	                                    (burst_size == 3'h2 && psel[0]) ? {paddr[31:3], bit4Addr[2:0]} :
	                                    (burst_size == 3'h2 && psel[1]) ? {paddr[31:2], bit4Addr[1:0]} :
	                                    (burst_size == 3'h2 && psel[2]) ? {paddr[31:2], bit4Addr[1:0]} :
	                                    (burst_size == 3'h1 && psel[0]) ? {paddr[31:2], bit4Addr[1:0]} :
	                                    (burst_size == 3'h1 && psel[1]) ? {paddr[31:2], bit4Addr[1:0]} :
	                                    (burst_size == 3'h1 && psel[2]) ? {paddr[31:2], bit4Addr[1:0]} :
	                                    32'h7777_7777;
	  3'b101: wrapNextTransAddr[31:0] = (burst_size == 3'h4 && psel[0]) ? {paddr[31:5], bit5Addr[4:0]} :
	                                    (burst_size == 3'h4 && psel[1]) ? {paddr[31:4], bit5Addr[3:0]} :
                                        (burst_size == 3'h4 && psel[2]) ? {paddr[31:3], bit5Addr[2:0]} : 
	                                    (burst_size == 3'h2 && psel[0]) ? {paddr[31:4], bit5Addr[3:0]} :
	                                    (burst_size == 3'h2 && psel[1]) ? {paddr[31:3], bit5Addr[2:0]} :
	                                    (burst_size == 3'h2 && psel[2]) ? {paddr[31:3], bit5Addr[2:0]} :
	                                    (burst_size == 3'h1 && psel[0]) ? {paddr[31:3], bit5Addr[2:0]} :
	                                    (burst_size == 3'h1 && psel[1]) ? {paddr[31:3], bit5Addr[2:0]} :
	                                    (burst_size == 3'h1 && psel[2]) ? {paddr[31:3], bit5Addr[2:0]} :
	                                    32'h7777_7777;
	  3'b110: wrapNextTransAddr[31:0] = (burst_size == 3'h4 && psel[0]) ? {paddr[31:6], bit6Addr[5:0]} :
	                                    (burst_size == 3'h4 && psel[1]) ? {paddr[31:5], bit6Addr[4:0]} :
                                        (burst_size == 3'h4 && psel[2]) ? {paddr[31:4], bit6Addr[3:0]} : 
	                                    (burst_size == 3'h2 && psel[0]) ? {paddr[31:5], bit6Addr[4:0]} :
	                                    (burst_size == 3'h2 && psel[1]) ? {paddr[31:4], bit6Addr[3:0]} :
	                                    (burst_size == 3'h2 && psel[2]) ? {paddr[31:4], bit6Addr[3:0]} :
	                                    (burst_size == 3'h1 && psel[0]) ? {paddr[31:4], bit6Addr[3:0]} :
	                                    (burst_size == 3'h1 && psel[1]) ? {paddr[31:4], bit6Addr[3:0]} :
	                                    (burst_size == 3'h1 && psel[2]) ? {paddr[31:4], bit6Addr[3:0]} :
	                                    32'h7777_7777;
	  default wrapNextTransAddr[31:0] = 32'bx;
	endcase
  end
  //================   addr step logic change with type of slave   Khoa debug end   ==//
  //pwrite
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pwrite <= 1'b0;
	else begin
	  case(currentState[1:0])
	    IDLE: pwrite <= 1'b0;
		SETUP: begin
		  if(~RD_WR_sig[0])
		    pwrite <= 1'b1;
		  else
		    pwrite <= 1'b0;
		end
		ACCESS: pwrite <= pwrite;
	  endcase
	end
  end
  //pwdata
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pwdata[31:0]           <= 32'd0;
	else begin
	  case(currentState[1:0])
	    IDLE: pwdata[31:0]   <= 32'd0;
		SETUP: begin
		  if(~RD_WR_sig[0])
		      begin
		          pwdata[31:0]     <= asfifoWdWdata[31:0];
		      end
		    else if(RD_WR_sig[0])
		      pwdata[31:0] <= 32'h0;
		   end
		ACCESS: pwdata[31:0] <= pwdata[31:0];
	  endcase
	end
  end
  //pprot
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pprot[2:0] <= 3'd0;
	else begin
	  case(currentState[1:0])
	    IDLE: pprot[2:0] <= 3'd0;
	    SETUP: begin
		  if(RD_WR_sig[0])
		    pprot[2:0] <= asfifoArCtrlArprot[2:0];
		  else
		    pprot[2:0] <= asfifoAwCtrlAwprot[2:0];
		end
		ACCESS: pprot[2:0] <= pprot[2:0];
	  endcase
	end
  end
  //pstrb
  always_ff @(posedge pclk, negedge preset_n) begin
    if(~preset_n)
	  pstrb[3:0] = 4'd0;
	else begin
	  case(currentState[1:0])
	    IDLE: pstrb[3:0] <= 4'd0;
		SETUP: begin
		  if(~RD_WR_sig[0])
		      
		     pstrb[3:0] <= asfifoWdWstrb[3:0];
		              
		end
		ACCESS: pstrb[3:0] <= pstrb[3:0];
	  endcase
	end
  end
endmodule: axi_apb_bridge