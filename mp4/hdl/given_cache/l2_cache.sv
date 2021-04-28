import rv32i_types::*;
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

logic [23:0] way_out[8];
logic [7:0] valid_out;
logic [7:0] dirty_out;
logic [2:0] plru;
logic [7:0] way_load;
logic [7:0] valid_load;
logic [7:0] valid_in;
logic [7:0] dirty_load;
logic [7:0] dirty_in;
logic lru_load;
logic [2:0] mru;
logic hit;
logic [7:0] way_hit;

logic [2:0] way_sel;
pmem_addr_mux_sel_t pmem_address_sel;
data_in_mux_sel_t way_data_in_sel;
data_write_en_mux_sel_t way_write_en_sel[8];

logic [255:0] cache_o;
assign mem_rdata = cache_o;
assign pmem_wdata = cache_o;

l2_cache_control control(.*);

l2_cache_datapath datapath(.*);


endmodule : l2_cache
