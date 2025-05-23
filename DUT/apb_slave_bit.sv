`timescale 1ns / 1ps

module apb_slave_8bit(
    input  logic               PCLK,
    input  logic               PRESETn,
    input  logic               PSEL,
    input  logic               PENABLE,
    input  logic               PWRITE,
    input  logic [2:0]         PPROT,
    input  logic [ADDR_WIDTH-1:0] PADDR,
    input  logic [DATA_WIDTH-1:0] PWDATA,
    input  logic [3:0]         PSTRB,
    
    output logic [DATA_WIDTH-1:0] PRDATA,
    output logic               PREADY,
    output logic               PSLVERR
);

    parameter MEM_DEPTH = 4096;
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MEM_BIT_SIZE = 8;
    parameter A_START_SLAVE0 = 32'h0000_1000;
    parameter A_END_SLAVE0   = 32'h0000_1FFF;
    
    logic [MEM_BIT_SIZE-1:0] mem [MEM_DEPTH];
    logic [ADDR_WIDTH-1:0] addr_reg;
    logic PSLVERR_reg;
    
    logic [ADDR_WIDTH-1:0] local_addr;
    assign local_addr = PADDR - A_START_SLAVE0;
    
    
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
                            mem[addr_reg]     = (PSTRB[0] == 1) ? PWDATA[7:0]   : mem[addr_reg];
                            mem[addr_reg + 1] = (PSTRB[1] == 1) ? PWDATA[15:8]  : mem[addr_reg + 1];
                            mem[addr_reg + 2] = (PSTRB[2] == 1) ? PWDATA[23:16] : mem[addr_reg + 2];
                            mem[addr_reg + 3] = (PSTRB[3] == 1) ? PWDATA[31:24] : mem[addr_reg + 3];
                        end 
                        // Read operation
                        else begin
                            if (PSTRB == 4'b0000) begin
                                PRDATA = {  mem[addr_reg + 3], 
                                            mem[addr_reg + 2], 
                                            mem[addr_reg + 1], 
                                            mem[addr_reg]};        
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