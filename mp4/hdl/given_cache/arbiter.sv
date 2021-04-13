module arbiter (
    input clk,
    input rst,

    /* arbiter <--> icache */
    input ipmem_write,
    input ipmem_read,
    input logic [31:0] ipmem_address,
    input logic [255:0] ipmem_wdata,
    output logic ipmem_resp,
    output logic [255:0] ipmem_rdata,

    /* arbiter <--> dcache */
    input dpmem_write,
    input dpmem_read,
    input logic [31:0] dpmem_address,
    input logic [255:0] dpmem_wdata,
    output logic dpmem_resp,
    output logic [255:0] dpmem_rdata,

    /* arbiter <--> cacheline adapter */
    output logic pmem_write,
    output logic pmem_read,
    output logic [31:0] pmem_address,
    output logic [255:0] pmem_wdata,
    input logic pmem_resp,
    input logic [255:0] pmem_rdata
);

/**************************** STATE/MUX SIGNALS ******************************/ 
// states
enum {IDLE, DCACHE, ICACHE} next_state, state;
logic icache_request, dcache_request;

assign icache_request = ipmem_read | ipmem_write;
assign dcache_request = dpmem_read | dpmem_write;
/*****************************************************************************/

/******************************* STATE MACHINE *******************************/ 
// update state
always @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

// next state logic 
always_comb begin
    // default
    next_state = state;
    unique case (state)
        IDLE: begin
            // prioritize instruction cache
            if (icache_request)
                next_state = ICACHE;
            else if (dcache_request)
                next_state = DCACHE;
        end

        ICACHE: begin
            if (~icache_request) begin
                if (dcache_request) next_state = DCACHE;
                else next_state = IDLE;
            end
        end

        DCACHE: begin
            if (~dcache_request) begin
                if (icache_request) next_state = ICACHE;
                else next_state = IDLE;
            end
        end

		default: ;
    endcase
end

// control signals
always_comb begin
    // defaults
    pmem_write = 1'b0;
    pmem_read = 1'b0;
    pmem_address = 32'b0;
    pmem_wdata = 256'b0;
    ipmem_resp = 1'b0;
    dpmem_resp = 1'b0;
    ipmem_rdata = 256'b0;
    dpmem_rdata = 256'b0;

    unique case (state)
        IDLE: ;

        ICACHE: begin
            pmem_write = ipmem_write;
            pmem_read = ipmem_read;
            pmem_address = ipmem_address;
            pmem_wdata = ipmem_wdata;
            ipmem_resp = pmem_resp;
            ipmem_rdata = pmem_rdata;
        end

        DCACHE: begin
            pmem_write = dpmem_write;
            pmem_read = dpmem_read;
            pmem_address = dpmem_address;
            pmem_wdata = dpmem_wdata;
            dpmem_resp = pmem_resp;
            dpmem_rdata = pmem_rdata;
        end
    endcase
end
/*****************************************************************************/


endmodule : arbiter