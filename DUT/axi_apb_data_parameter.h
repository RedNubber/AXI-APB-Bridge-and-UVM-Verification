//parameter declaration
//FIFO

parameter AXI_APB_BRIDGE_ASFIFO_AW_DATA_WIDTH = 56;
parameter AXI_APB_BRIDGE_ASFIFO_AR_DATA_WIDTH = 56;
parameter AXI_APB_BRIDGE_ASFIFO_WD_DATA_WIDTH = 36;
parameter AXI_APB_BRIDGE_ASFIFO_RD_DATA_WIDTH = 42;

parameter POINTER_WIDTH           = 4;
//state machine
parameter IDLE                    = 2'b00;
parameter SETUP                   = 2'b01;
parameter ACCESS                  = 2'b10;
//Error
parameter OKAY                    = 2'b00;
parameter DECERR                  = 2'b11;
parameter PSLVERR                 = 2'b10;
//parameter SLAVE_NUM is used to set number of APB slave
parameter SLAVE_NUM = 4 ;
//address of Register block
parameter A_START_REG     = 32'h0000_0000;
parameter A_END_REG       = 32'h0000_0FFF; 
//address of SLAVE APB
parameter A_START_SLAVE0  = 32'h0000_1000;
parameter A_END_SLAVE0    = 32'h0000_1FFF;
parameter A_START_SLAVE1  = 32'h0000_2000;
parameter A_END_SLAVE1    = 32'h0000_2FFF;
parameter A_START_SLAVE2  = 32'h0000_3000;
parameter A_END_SLAVE2    = 32'h0000_3FFF;
parameter A_START_SLAVE3  = 32'h0000_4000;
parameter A_END_SLAVE3    = 32'h0000_4FFF;
parameter A_START_SLAVE4  = 32'h0000_5000;
parameter A_END_SLAVE4    = 32'h0000_5FFF;

