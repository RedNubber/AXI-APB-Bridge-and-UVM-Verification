`timescale 1ns / 1ps

module apb_slave_32bit(
    input logic PCLK,               // APB clock
    input logic PRESETn,            // APB reset (active low)
    input logic PSEL,               // APB select
    input logic PENABLE,            // APB enable
    input logic PWRITE,             // APB write enable
    input logic [2:0] PPROT,
    input logic [ADDR_WIDTH-1:0] PADDR,              // APB address
    input logic [DATA_WIDTH-1:0] PWDATA,             // APB write data
    input logic [3:0] PSTRB,
    
    output logic [DATA_WIDTH-1:0] PRDATA,             // APB read data
    output logic PREADY,             // APB ready signal
    output logic PSLVERR             // APB slave error
    );
    parameter MEM_DEPTH = 4096;       // Memory depth
    parameter ADDR_WIDTH = 32;     // Address width
    parameter DATA_WIDTH = 32;      // Data width
    parameter MEM_BIT_SIZE = 32;
    parameter A_START_SLAVE2 = 32'h0000_3000;
    parameter A_END_SLAVE2 = 32'h0000_3FFF;
    // Internal memory
    logic [MEM_BIT_SIZE-1:0] mem [MEM_DEPTH]; 
    // Internal signal
    logic [ADDR_WIDTH-1:0] addr_reg;
    logic PSLVERR_reg;
    

    
    logic [ADDR_WIDTH-1:0] local_addr;
    assign local_addr = PADDR - A_START_SLAVE2;
    
                          
    always_ff @(*) begin
    if (!PRESETn) begin
        // Reset logic
        PSLVERR_reg = '0;
        PRDATA      = '0;
        addr_reg    = '0;
        foreach(mem[i]) mem[i] = '0;
    end
    else begin
        // Default values
        PSLVERR_reg = '0;
        
        // Phase detection
        if (PSEL) begin
            if (PENABLE) begin
                addr_reg = local_addr;
		    if (PWRITE) begin
                              mem[addr_reg][7:0]   = (PSTRB[0] == 1) ? PWDATA[7:0]   : mem[addr_reg][7:0];
                              mem[addr_reg][15:8]  = (PSTRB[1] == 1) ? PWDATA[15:8]  : mem[addr_reg][15:8];
                              mem[addr_reg][23:16] = (PSTRB[2] == 1) ? PWDATA[23:16] : mem[addr_reg][23:16];
                              mem[addr_reg][31:24] = (PSTRB[3] == 1) ? PWDATA[31:24] : mem[addr_reg][31:24];
                        end 
                        // Read operation
                        else begin
                            if (PSTRB == 4'b0000) begin
                                PRDATA = {mem[addr_reg]};    
                            end
                            else begin
                                PSLVERR_reg = 1'b1;                    
                            end
                        end
                    end
                
            
        end
    end
end

    assign PSLVERR = (PSLVERR_reg && PREADY);
    assign PREADY = 1'b1;

endmodule
