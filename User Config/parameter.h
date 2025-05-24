//=================================================================//
//================                                =================//
//================      CONFIG/PARAMETER FILE     =================//
//================                                =================//
//=================================================================//
`ifndef para_config
`define para_config
//================      Define apb_reg when you want to check APB Register     ==========//
    //`define apb_reg
    `ifdef apb_reg
        parameter config_addr = 32'h0000_0014;
        `define FIXED
        `define LENGTH_8
        `define BURST_SIZE_32
    `else



//=================================================================//
//================                                =================//
//================     Instruction for User       =================//
//================    Step 1: Turn on Slave       =================//
//================    Step 2: Choose Address      =================//
//================    Step 3: Choose BURST_TYPE   =================//
//================    Step 4: Choose BURST_LENGTH =================//
//================    Step 5: Choose BURST_SIZE   =================//
//================    Step 6: Choose Frequency    =================//
//================                                =================//
//=================================================================//

//================       Step1: TURN ON SLAVE     =================//

                      //`define AXI_MEM_SIZE_8_BIT              //Slave1
                      //`define AXI_MEM_SIZE_16_BIT             //Slave2      
                      `define AXI_MEM_SIZE_32_BIT             //Slave3
                      //`define apb_reg




//================       Step2: CHOOSE ADDRESS    =================//
                    `ifdef AXI_MEM_SIZE_8_BIT
                        parameter config_addr = 32'h0000_101C;                  //ADDRESS FOR SLAVE 1
                    `elsif AXI_MEM_SIZE_16_BIT
                        parameter config_addr = 32'h0000_201C;                  //ADDRESS FOR SLAVE 2
                    `elsif AXI_MEM_SIZE_32_BIT
                        parameter config_addr = 32'h0000_3004;                  //ADDRESS FOR SLAVE 3
                    `elsif apb_reg
                        parameter config_addr = 32'h0000_0014;                  //ADDRESS FOR SLAVE 3
                    `endif
                        /*0000_1000 to 0000_1FFF for SLAVE 8  BIT*/
                        /*0000_2000 to 0000_2FFF for SLAVE 16 BIT*/
                        /*0000_3000 to 0000_3FFF for SLAVE 32 BIT*/
//                        parameter config_addr = 32'h202C;





//================     Step3: CHOOSE BURST_TYPE   =================//

//Just choose one: FIXED, INCR or WRAP

                            //`define FIXED
                            //`define INCR
                            `define WRAP





//================    Step4: CHOOSE BURST_LENGTH  =================//

//Just choose one: BURST_LENGTH_2 or 4 or 8 or 16
                            //`define LENGTH_2
                            //`define LENGTH_4
                            `define LENGTH_8
                            //`define LENGTH_16
      
      
      
      
                            
//================     Step5: CHOOSE BURST_SIZE   =================//

//Just choose one: BURST_SIZE_8, BURST_SIZE_16 or BURST_SIZE_32
//                            `define BURST_SIZE_8
                            //`define BURST_SIZE_16
                            `define BURST_SIZE_32

`endif



//================     Step6: CHOOSE FREQUENT     =================//
                            `define 250_25_MHz
                            //`define 200_20_MHz
                            //`define 100_10 MHz































//=========================      BURST_SIZE             ====================//
parameter SIZE_8 = 3'h0;
parameter SIZE_16 = 3'h1;
parameter SIZE_32 = 3'h2;

`ifdef BURST_SIZE_8
    parameter burst_size = SIZE_8;
`elsif BURST_SIZE_16
    parameter burst_size = SIZE_16;
`elsif BURST_SIZE_32
    parameter burst_size = SIZE_32;
`endif

//=========================      BURST_TYPE             ====================//
parameter FIXED = 2'b00;
parameter INCR  = 2'b01;
parameter WRAP  = 2'b10;

`ifdef FIXED
    parameter burst_type  = FIXED;
`elsif INCR
    parameter burst_type  = INCR;
`elsif WRAP
    parameter burst_type  = WRAP;
`endif

//=========================      BURST_LENGTH          ====================//
parameter BURST_LENGTH_2   = 8'h1;
parameter BURST_LENGTH_4   = 8'h3;
parameter BURST_LENGTH_8   = 8'h7;
parameter BURST_LENGTH_16  = 8'hf;

`ifdef LENGTH_2
    parameter length  = BURST_LENGTH_2;
`elsif LENGTH_4
    parameter length  = BURST_LENGTH_4;
`elsif LENGTH_8
    parameter length  = BURST_LENGTH_8;
`elsif LENGTH_16
    parameter length  = BURST_LENGTH_16;
`endif
`endif
