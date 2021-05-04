module l2_cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
) (
    input clk,
    input rst,

    // Port to L1 cache
    input logic mem_read,
    input logic mem_write,
    input logic [31:0] mem_address,
    input logic [255:0] mem_wdata,
    output logic mem_resp,
    output logic [255:0] mem_rdata,

    // Port to Cacheline Adapter
    input pmem_resp,
    input [255:0] pmem_rdata,
    output logic pmem_read,
    output logic pmem_write,
    output logic [31:0] pmem_address,
    output [255:0] pmem_wdata
);

logic [7:0] valid_out;
logic [7:0] dirty_out;
logic [2:0] plru;
logic [7:0] tag_load;
logic valid_load;
logic [7:0] valid_in;
logic dirty_load;
logic [7:0] dirty_in;
logic lru_load;
logic [2:0] mru;
logic [7:0] way_hit;

logic [2:0] way_sel;
logic way_data_in_sel;
logic [7:0] data_write_en;

logic mem_read2;
logic mem_write2;
logic [31:0] mem_address2;
logic [255:0] mem_wdata2;

always_ff @(posedge clk) begin
    mem_read2 <= mem_read;
    mem_write2 <= mem_write;
    mem_address2 <= mem_address;
    mem_wdata2 <= mem_wdata;
end

logic [255:0] cache_o;
assign mem_rdata = cache_o;
assign pmem_wdata = cache_o;

l2_cache_control control(.mem_read(mem_read2), .mem_write(mem_write2), .*);

l2_cache_datapath datapath(.mem_address(mem_address2), .mem_wdata(mem_wdata2), .*);

endmodule : l2_cache
