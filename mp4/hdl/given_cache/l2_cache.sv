/* MODIFY. Your cache design. It contains the cache
controller, cache datapath, and bus adapter. */

import rv32i_types::*;
import cache_out_mux::*;
import pmem_addr_mux::*;
import data_in_mux::*;
import data_write_en_mux::*;

module l2_cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
    input clk,
    input rst,

    // Port to CPU
    input logic mem_read,
    input logic mem_write,
    input logic [3:0] mem_byte_enable,
    input rv32i_word mem_address,
    input logic [255:0] mem_wdata,
    output logic mem_resp,
    output logic [255:0] mem_rdata,

    // Port to Cacheline Adapter
    input pmem_resp,
    input [255:0] pmem_rdata,
    output logic pmem_read,
    output logic pmem_write,
    output rv32i_word pmem_address,
    output [255:0] pmem_wdata
);

logic [23:0] way_out[2];
logic [1:0] valid_out;
logic [1:0] dirty_out;
// logic lru_out;
logic plru;
logic [1:0] way_load;
logic [1:0] valid_load;
logic [1:0] valid_in;
logic [1:0] dirty_load;
logic [1:0] dirty_in;
logic lru_load;
// logic lru_in;
logic mru;
logic hit;
logic [1:0] way_hit;

cache_out_mux_sel_t way_sel;
pmem_addr_mux_sel_t pmem_address_sel;
data_in_mux_sel_t way_data_in_sel[2];
data_write_en_mux_sel_t way_write_en_sel[2];

logic [255:0] mem_rdata256;
logic [255:0] mem_wdata256;
logic [31:0] mem_byte_enable256;

logic [255:0] cache_o;
assign mem_rdata256 = cache_o;
assign pmem_wdata = cache_o;

l2_cache_control control(.*);

l2_cache_datapath datapath(.*);

//bus_adapter bus_adapter(.address(mem_address), .*);
assign mem_wdata256 = {8{mem_wdata}};
assign mem_rdata = mem_rdata256[(32*mem_address[4:2]) +: 32];
assign mem_byte_enable256 = {28'h0, mem_byte_enable} << (mem_address[4:2]*4);

endmodule : l2_cache


