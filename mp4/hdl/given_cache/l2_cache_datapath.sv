/* MODIFY. The cache datapath. It contains the data,
valid, dirty, tag, and LRU arrays, comparators, muxes,
logic gates and other supporting logic. */

`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;
import cache_out_mux::*;
import pmem_addr_mux::*;
import data_in_mux::*;
import data_write_en_mux::*;

module l2_cache_datapath #(
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

    input rv32i_word mem_address,

    input logic [255:0] pmem_rdata,
    output rv32i_word pmem_address,

    input logic [255:0] mem_wdata256,
    input logic [31:0] mem_byte_enable256,

    output logic [255:0] cache_o,

    input logic [1:0] way_load,
    input logic [1:0] valid_load,
    input logic [1:0] valid_in,
    input logic [1:0] dirty_load,
    input logic [1:0] dirty_in,
    input logic lru_load,
    input logic mru,
    // input logic lru_in,
    output logic [23:0] way_out[2],
    output logic [1:0] valid_out,
    output logic [1:0] dirty_out,
    // output logic lru_out,
    output logic plru,
	
	output logic hit,
    output [1:0] way_hit,

    input cache_out_mux_sel_t way_sel,
    input pmem_addr_mux_sel_t pmem_address_sel,
    input data_in_mux_sel_t way_data_in_sel[2],
    input data_write_en_mux_sel_t way_write_en_sel[2]
);

rv32i_word [1:0] data_array_write_en;
logic [1:0][255:0] data_array_in;
logic [1:0][255:0] data_array_out;

l2_array #(.s_index(3), .width(24)) tag_0(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(way_load[0]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(mem_address[31:8]),
    .dataout(way_out[0])
);

l2_array #(.s_index(3), .width(24)) tag_1(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(way_load[1]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(mem_address[31:8]),
    .dataout(way_out[1])
);

l2_array #(.s_index(3), .width(1)) valid_0(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(valid_load[0]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(valid_in[0]),
    .dataout(valid_out[0])
);

l2_array #(.s_index(3), .width(1)) valid_1(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(valid_load[1]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(valid_in[1]),
    .dataout(valid_out[1])
);

l2_array #(.s_index(3), .width(1)) dirty_0(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(dirty_load[0]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(dirty_in[0]),
    .dataout(dirty_out[0])
);

l2_array #(.s_index(3), .width(1)) dirty_1(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(dirty_load[1]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(dirty_in[1]),
    .dataout(dirty_out[1])
);

// array #(.s_index(3), .width(1)) lru(
//     .clk(clk),
//     .rst(rst),
//     .read(1'b1),
//     .load(lru_load),
//     .rindex(mem_address[7:5]),
//     .windex(mem_address[7:5]),
//     .datain(lru_in),
//     .dataout(lru_out)
// );

plru #(.s_index(3), .width(1)) pLRU(
    .clk(clk),
    .rst(rst),
    .load(lru_load),
    .mru(mru),
    .plru(plru)
);

l2_data_array #(.s_offset(5), .s_index(3)) data_array_0(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_array_write_en[0]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(data_array_in[0]),
    .dataout(data_array_out[0])
);

l2_data_array #(.s_offset(5), .s_index(3)) data_array_1(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_array_write_en[1]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(data_array_in[1]),
    .dataout(data_array_out[1])
);

assign way_hit[0] = (way_out[0] == mem_address[31:8]) && valid_out[0];
assign way_hit[1] = (way_out[1] == mem_address[31:8]) && valid_out[1];
assign hit = way_hit[0] || way_hit[1];

always_comb begin: LOGIC
    unique case (way_sel)
        cache_out_mux::way_0: cache_o = data_array_out[0];
        cache_out_mux::way_1: cache_o = data_array_out[1];
        default: cache_o = data_array_out[0];
    endcase
    unique case (pmem_address_sel)
        pmem_addr_mux::cpu: pmem_address = {mem_address[31:5], 5'b0};
        pmem_addr_mux::dirty_0_write: pmem_address = {way_out[0], mem_address[7:5], 5'b0};
        pmem_addr_mux::dirty_1_write: pmem_address = {way_out[1], mem_address[7:5], 5'b0};
        default: pmem_address = {mem_address[31:5], 5'b0};
    endcase
    unique case (way_data_in_sel[0])
        data_in_mux::cacheline_adaptor: data_array_in[0] = pmem_rdata;
        data_in_mux::bus_adaptor: data_array_in[0] = mem_wdata256;
        default: data_array_in[0] = pmem_rdata;
    endcase
    unique case (way_data_in_sel[1])
        data_in_mux::cacheline_adaptor: data_array_in[1] = pmem_rdata;
        data_in_mux::bus_adaptor: data_array_in[1] = mem_wdata256;
        default: data_array_in[1] = pmem_rdata;
    endcase
    unique case (way_write_en_sel[0])
        data_write_en_mux::idle: data_array_write_en[0] = 32'b0;
        data_write_en_mux::load_mem: data_array_write_en[0] = 32'hFFFFFFFF;
        data_write_en_mux::cpu_write: data_array_write_en[0] = mem_byte_enable256;
        default: data_array_write_en[0] = 32'b0;
    endcase
    unique case (way_write_en_sel[1])
        data_write_en_mux::idle: data_array_write_en[1] = 32'b0;
        data_write_en_mux::load_mem: data_array_write_en[1] = 32'hFFFFFFFF;
        data_write_en_mux::cpu_write: data_array_write_en[1] = mem_byte_enable256;
        default: data_array_write_en[1] = 32'b0;
    endcase
end

endmodule : l2_cache_datapath


