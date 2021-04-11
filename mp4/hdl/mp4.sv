module mp4(
    input clk,
    input rst,

	/* Caches <--> Memory*/
    output logic pmem_read,
	output logic pmem_write,
	output logic [31:0] pmem_address,
	output logic [63:0] pmem_wdata,
	input logic [63:0] pmem_rdata,
	input logic pmem_resp
);

/****************************** MEMORY SIGNALS *****************************/ 
logic icache_read;
logic icache_write;
logic [31:0] icache_addr;
logic [31:0] icache_rdata;
logic icache_resp;

logic [3:0] dcache_byte_enable;
logic dcache_read;
logic dcache_write;
logic [31:0] dcache_addr;
logic [31:0] dcache_wdata;
logic [31:0] dcache_rdata;
logic dcache_resp;
/***************************************************************************/

/****************************** DATAPATH/CACHE *****************************/ 
datapath datapath(.*);

cache_top caches(.*);
/***************************************************************************/

endmodule : mp4
