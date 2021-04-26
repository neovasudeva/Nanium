module cache_top (
    input clk,
	input rst,
	
	/* CPU <--> icache */
	input icache_read,
	input logic [31:0] icache_addr,
	output logic [31:0] icache_rdata,
	output logic icache_resp,
	
	/* CPU <--> dcache */
	input logic [3:0] dcache_byte_enable,
	input dcache_read,
	input dcache_write,
	input logic [31:0] dcache_addr,
	input logic [31:0] dcache_wdata,
	output logic [31:0] dcache_rdata,
	output logic dcache_resp,
	
	/* cache <--> memory */
	output logic pmem_read,
	output logic pmem_write,
	output logic [31:0] pmem_address,
	output logic [63:0] pmem_wdata,
	input logic [63:0] pmem_rdata,
	input logic pmem_resp
);

/******************************** SIGNALS **********************************/ 
/* arbiter <--> icache */
logic ipmem_write;
logic ipmem_read;
logic [31:0] ipmem_address;
logic [255:0] ipmem_wdata;
logic ipmem_resp;
logic [255:0] ipmem_rdata;

/* arbiter <--> dcache */
logic dpmem_write;
logic dpmem_read;
logic [31:0] dpmem_address;
logic [255:0] dpmem_wdata;
logic dpmem_resp;
logic [255:0] dpmem_rdata;

/* arbiter <--> L2 */
logic l2mem_write;
logic l2mem_read;
logic [31:0] l2mem_address;
logic [255:0] l2mem_wdata;
logic l2mem_resp;
logic [255:0] l2mem_rdata;

/* L2 <--> cachline adapter */
logic apmem_write;
logic apmem_read;
logic [31:0] apmem_address;
logic [255:0] apmem_wdata;
logic apmem_resp;
logic [255:0] apmem_rdata;
/***************************************************************************/

/******************************** CACHES ***********************************/ 
// icache
cache icache (
	.clk					(clk),

	.pmem_resp				(ipmem_resp),
	.pmem_rdata				(ipmem_rdata),
	.pmem_address			(ipmem_address),
	.pmem_wdata				(ipmem_wdata),
	.pmem_read				(ipmem_read),
	.pmem_write				(ipmem_write),

	.mem_read				(icache_read),
	.mem_write				(1'b0),
	.mem_byte_enable_cpu	(4'b0),
	.mem_address			(icache_addr),
	.mem_wdata_cpu			(32'b0),
	.mem_resp				(icache_resp),
	.mem_rdata_cpu			(icache_rdata)
);

// data cache
cache dcache (
	.clk					(clk),

	.pmem_resp				(dpmem_resp),
	.pmem_rdata				(dpmem_rdata),
	.pmem_address			(dpmem_address),
	.pmem_wdata				(dpmem_wdata),
	.pmem_read				(dpmem_read),
	.pmem_write				(dpmem_write),

	.mem_read				(dcache_read),
	.mem_write				(dcache_write),
	.mem_byte_enable_cpu	(dcache_byte_enable),
	.mem_address			(dcache_addr),
	.mem_wdata_cpu			(dcache_wdata),
	.mem_resp				(dcache_resp),
	.mem_rdata_cpu			(dcache_rdata)
);

// arbiter
arbiter cache_arbiter (
	.clk			(clk),
    .rst			(rst),

    .ipmem_write	(ipmem_write),
    .ipmem_read		(ipmem_read),
    .ipmem_address	(ipmem_address),
    .ipmem_wdata	(ipmem_wdata),
    .ipmem_resp		(ipmem_resp),
    .ipmem_rdata	(ipmem_rdata),

    .dpmem_write	(dpmem_write),
    .dpmem_read		(dpmem_read),
    .dpmem_address	(dpmem_address),
    .dpmem_wdata	(dpmem_wdata),
    .dpmem_resp		(dpmem_resp),
    .dpmem_rdata	(dpmem_rdata),

    .pmem_write		(l2mem_write),
    .pmem_read		(l2mem_read),
    .pmem_address	(l2mem_address),
    .pmem_wdata		(l2mem_wdata),
    .pmem_resp		(l2mem_resp),
    .pmem_rdata		(l2mem_rdata)
);

l2_cache l2_cache (
	.clk(clk),
	.rst(rst),
	.mem_read(l2mem_read),
    .mem_write(l2mem_write),
    .mem_byte_enable(4'b1111),
    .mem_address(l2mem_address),
    .mem_wdata(l2mem_wdata),
    .mem_resp(l2mem_resp),
    .mem_rdata(l2mem_rdata),

    .pmem_resp(apmem_resp),
    .pmem_rdata(apmem_rdata),
    .pmem_read(apmem_read),
    .pmem_write(apmem_write),
    .pmem_address(apmem_address),
    .pmem_wdata(apmem_wdata)
);

// cacheline adapter
cacheline_adaptor ca (
	.clk		(clk),
    .reset_n	(~rst),

    .line_i		(apmem_wdata),
    .line_o		(apmem_rdata),
    .address_i	(apmem_address),
    .read_i		(apmem_read),
    .write_i	(apmem_write),
    .resp_o		(apmem_resp),

    .burst_i	(pmem_rdata),
    .burst_o	(pmem_wdata),
    .address_o	(pmem_address),
    .read_o		(pmem_read),
    .write_o	(pmem_write),
    .resp_i		(pmem_resp)
);	

/***************************************************************************/

endmodule : cache_top