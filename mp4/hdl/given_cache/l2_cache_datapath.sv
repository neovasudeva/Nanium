`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;
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

    input logic [7:0] way_load,
    input logic [7:0] valid_load,
    input logic [7:0] valid_in,
    input logic [7:0] dirty_load,
    input logic [7:0] dirty_in,
    input logic lru_load,
    input logic [2:0] mru,
    output logic [23:0] way_out[8],
    output logic [7:0] valid_out,
    output logic [7:0] dirty_out,
    output logic [2:0] plru,
	
	output logic hit,
    output logic [7:0] way_hit,

    input logic [2:0] way_sel,
    input pmem_addr_mux_sel_t pmem_address_sel,
    input data_in_mux_sel_t way_data_in_sel[8],
    input data_write_en_mux_sel_t way_write_en_sel[8]
);

rv32i_word [7:0] data_array_write_en;
logic [7:0][255:0] data_array_in;
logic [7:0][255:0] data_array_out;

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

l2_array #(.s_index(3), .width(24)) tag_2(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(way_load[2]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(mem_address[31:8]),
    .dataout(way_out[2])
);
l2_array #(.s_index(3), .width(1)) valid_2(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(valid_load[2]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(valid_in[2]),
    .dataout(valid_out[2])
);
l2_array #(.s_index(3), .width(1)) dirty_2(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(dirty_load[2]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(dirty_in[2]),
    .dataout(dirty_out[2])
);
l2_data_array #(.s_offset(5), .s_index(3)) data_array_2(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_array_write_en[2]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(data_array_in[2]),
    .dataout(data_array_out[2])
);

l2_array #(.s_index(3), .width(24)) tag_3(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(way_load[3]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(mem_address[31:8]),
    .dataout(way_out[3])
);
l2_array #(.s_index(3), .width(1)) valid_3(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(valid_load[3]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(valid_in[3]),
    .dataout(valid_out[3])
);
l2_array #(.s_index(3), .width(1)) dirty_3(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(dirty_load[3]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(dirty_in[3]),
    .dataout(dirty_out[3])
);
l2_data_array #(.s_offset(5), .s_index(3)) data_array_3(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_array_write_en[3]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(data_array_in[3]),
    .dataout(data_array_out[3])
);

l2_array #(.s_index(3), .width(24)) tag_4(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(way_load[4]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(mem_address[31:8]),
    .dataout(way_out[4])
);
l2_array #(.s_index(3), .width(1)) valid_4(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(valid_load[4]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(valid_in[4]),
    .dataout(valid_out[4])
);
l2_array #(.s_index(3), .width(1)) dirty_4(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(dirty_load[4]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(dirty_in[4]),
    .dataout(dirty_out[4])
);
l2_data_array #(.s_offset(5), .s_index(3)) data_array_4(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_array_write_en[4]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(data_array_in[4]),
    .dataout(data_array_out[4])
);

l2_array #(.s_index(3), .width(24)) tag_5(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(way_load[5]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(mem_address[31:8]),
    .dataout(way_out[5])
);
l2_array #(.s_index(3), .width(1)) valid_5(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(valid_load[5]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(valid_in[5]),
    .dataout(valid_out[5])
);
l2_array #(.s_index(3), .width(1)) dirty_5(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(dirty_load[5]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(dirty_in[5]),
    .dataout(dirty_out[5])
);
l2_data_array #(.s_offset(5), .s_index(3)) data_array_5(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_array_write_en[5]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(data_array_in[5]),
    .dataout(data_array_out[5])
);

l2_array #(.s_index(3), .width(24)) tag_6(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(way_load[6]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(mem_address[31:8]),
    .dataout(way_out[6])
);
l2_array #(.s_index(3), .width(1)) valid_6(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(valid_load[6]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(valid_in[6]),
    .dataout(valid_out[6])
);
l2_array #(.s_index(3), .width(1)) dirty_6(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(dirty_load[6]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(dirty_in[6]),
    .dataout(dirty_out[6])
);
l2_data_array #(.s_offset(5), .s_index(3)) data_array_6(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_array_write_en[6]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(data_array_in[6]),
    .dataout(data_array_out[6])
);

l2_array #(.s_index(3), .width(24)) tag_7(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(way_load[7]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(mem_address[31:8]),
    .dataout(way_out[7])
);
l2_array #(.s_index(3), .width(1)) valid_7(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(valid_load[7]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(valid_in[7]),
    .dataout(valid_out[7])
);
l2_array #(.s_index(3), .width(1)) dirty_7(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .load(dirty_load[7]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(dirty_in[7]),
    .dataout(dirty_out[7])
);
l2_data_array #(.s_offset(5), .s_index(3)) data_array_7(
    .clk(clk),
    .rst(rst),
    .read(1'b1),
    .write_en(data_array_write_en[7]),
    .rindex(mem_address[7:5]),
    .windex(mem_address[7:5]),
    .datain(data_array_in[7]),
    .dataout(data_array_out[7])
);

plru #(.s_index(3), .width(3)) pLRU(
    .clk(clk),
    .rst(rst),
    .load(lru_load),
    .index(mem_address[7:5]), 
    .mru(mru),
    .plru(plru)
);

always_comb begin: WAY_HIT
    for (logic [3:0] i = 0; i < 4'd8; i++) begin
        way_hit[i] = (way_out[i] == mem_address[31:8]) && valid_out[i];
    end
end

assign hit = way_hit[0] || way_hit[1] || way_hit[2] || way_hit[3] || way_hit[4] || way_hit[5] || way_hit[6] || way_hit[7];

assign cache_o = data_array_out[way_sel];

always_comb begin: LOGIC
    unique case (pmem_address_sel)
        pmem_addr_mux::cpu: pmem_address = {mem_address[31:5], 5'b0};
        pmem_addr_mux::dirty_0_write: pmem_address = {way_out[0], mem_address[7:5], 5'b0};
        pmem_addr_mux::dirty_1_write: pmem_address = {way_out[1], mem_address[7:5], 5'b0};
        pmem_addr_mux::dirty_2_write: pmem_address = {way_out[2], mem_address[7:5], 5'b0};
        pmem_addr_mux::dirty_3_write: pmem_address = {way_out[3], mem_address[7:5], 5'b0};
        pmem_addr_mux::dirty_4_write: pmem_address = {way_out[4], mem_address[7:5], 5'b0};
        pmem_addr_mux::dirty_5_write: pmem_address = {way_out[5], mem_address[7:5], 5'b0};
        pmem_addr_mux::dirty_6_write: pmem_address = {way_out[6], mem_address[7:5], 5'b0};
        pmem_addr_mux::dirty_7_write: pmem_address = {way_out[7], mem_address[7:5], 5'b0};
        default: pmem_address = {mem_address[31:5], 5'b0};
    endcase

    for (logic [3:0] i = 0; i < 4'd8; i++) begin
        unique case (way_data_in_sel[i])
            data_in_mux::cacheline_adaptor: data_array_in[i] = pmem_rdata;
            data_in_mux::bus_adaptor: data_array_in[i] = mem_wdata256;
            default: data_array_in[i] = pmem_rdata;
        endcase
        unique case (way_write_en_sel[i])
            data_write_en_mux::idle: data_array_write_en[i] = 32'b0;
            data_write_en_mux::load_mem: data_array_write_en[i] = 32'hFFFFFFFF;
            data_write_en_mux::cpu_write: data_array_write_en[i] = mem_byte_enable256;
            default: data_array_write_en[i] = 32'b0;
        endcase
    end
end

endmodule : l2_cache_datapath
