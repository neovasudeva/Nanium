module mp4(
    input clk,
    input rst,

    output logic icache_read,
    output logic icache_write,
    output logic [31:0] icache_addr,
    input logic [31:0] icache_rdata,
    input logic icache_resp,

    output logic [3:0] dcache_byte_enable,
    output logic dcache_read,
    output logic dcache_write,
    output logic [31:0] dcache_addr,
    output logic [31:0] dcache_wdata,
    input logic [31:0] dcache_rdata,
    input logic dcache_resp
);

datapath datapath(.*);

endmodule : mp4
