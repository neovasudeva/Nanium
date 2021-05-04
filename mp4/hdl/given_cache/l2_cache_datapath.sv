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

    input logic [31:0] mem_address,

    input logic [255:0] pmem_rdata,
    output logic [31:0] pmem_address,

    input logic [255:0] mem_wdata,

    output logic [255:0] cache_o,

    input logic [7:0] tag_load,
    input logic valid_load,
    input logic [7:0] valid_in,
    input logic dirty_load,
    input logic [7:0] dirty_in,
    input logic lru_load,
    input logic [2:0] mru,

    output logic [7:0] valid_out,
    output logic [7:0] dirty_out,
    output logic [2:0] plru,

    output logic [7:0] way_hit,

    input logic [2:0] way_sel,

    input logic way_data_in_sel,
    input logic [7:0] data_write_en
);

logic [255:0] data_array_in;
logic [255:0] data_array_out [8];
logic [23:0] tag_out [8];

logic [2:0] set;
logic [23:0] tag;
assign set = mem_address[7:5];
assign tag = mem_address[31:8];

l2_array #(.width(24)) tag_0(.clk(clk), .rst(), .load(tag_load[0]), .index(set), .datain(tag), .dataout(tag_out[0]));
l2_array #(.width(1)) valid_0(.clk(clk), .rst(rst), .load(valid_load), .datain(valid_in[0]), .index(set), .dataout(valid_out[0]));
l2_array #(.width(1)) dirty_0(.clk(clk), .rst(), .load(dirty_load), .datain(dirty_in[0]), .index(set), .dataout(dirty_out[0]));
l2_data_array data_array_0(.clk(clk), .rst(), .write_en(data_write_en[0]), .index(set), .datain(data_array_in), .dataout(data_array_out[0]));

l2_array #(.width(24)) tag_1(.clk(clk), .rst(), .load(tag_load[1]), .index(set), .datain(tag), .dataout(tag_out[1]));
l2_array #(.width(1)) valid_1(.clk(clk), .rst(rst), .load(valid_load), .datain(valid_in[1]), .index(set), .dataout(valid_out[1]));
l2_array #(.width(1)) dirty_1(.clk(clk), .rst(), .load(dirty_load), .datain(dirty_in[1]), .index(set), .dataout(dirty_out[1]));
l2_data_array data_array_1(.clk(clk), .rst(), .write_en(data_write_en[1]), .index(set), .datain(data_array_in), .dataout(data_array_out[1]));

l2_array #(.width(24)) tag_2(.clk(clk), .rst(), .load(tag_load[2]), .index(set), .datain(tag), .dataout(tag_out[2]));
l2_array #(.width(1)) valid_2(.clk(clk), .rst(rst), .load(valid_load), .datain(valid_in[2]), .index(set), .dataout(valid_out[2]));
l2_array #(.width(1)) dirty_2(.clk(clk), .rst(), .load(dirty_load), .datain(dirty_in[2]), .index(set), .dataout(dirty_out[2]));
l2_data_array data_array_2(.clk(clk), .rst(), .write_en(data_write_en[2]), .index(set), .datain(data_array_in), .dataout(data_array_out[2]));

l2_array #(.width(24)) tag_3(.clk(clk), .rst(), .load(tag_load[3]), .index(set), .datain(tag), .dataout(tag_out[3]));
l2_array #(.width(1)) valid_3(.clk(clk), .rst(rst), .load(valid_load), .datain(valid_in[3]), .index(set), .dataout(valid_out[3]));
l2_array #(.width(1)) dirty_3(.clk(clk), .rst(), .load(dirty_load), .datain(dirty_in[3]), .index(set), .dataout(dirty_out[3]));
l2_data_array data_array_3(.clk(clk), .rst(), .write_en(data_write_en[3]), .index(set), .datain(data_array_in), .dataout(data_array_out[3]));

l2_array #(.width(24)) tag_4(.clk(clk), .rst(), .load(tag_load[4]), .index(set), .datain(tag), .dataout(tag_out[4]));
l2_array #(.width(1)) valid_4(.clk(clk), .rst(rst), .load(valid_load), .datain(valid_in[4]), .index(set), .dataout(valid_out[4]));
l2_array #(.width(1)) dirty_4(.clk(clk), .rst(), .load(dirty_load), .datain(dirty_in[4]), .index(set), .dataout(dirty_out[4]));
l2_data_array data_array_4(.clk(clk), .rst(), .write_en(data_write_en[4]), .index(set), .datain(data_array_in), .dataout(data_array_out[4]));

l2_array #(.width(24)) tag_5(.clk(clk), .rst(), .load(tag_load[5]), .index(set), .datain(tag), .dataout(tag_out[5]));
l2_array #(.width(1)) valid_5(.clk(clk), .rst(rst), .load(valid_load), .datain(valid_in[5]), .index(set), .dataout(valid_out[5]));
l2_array #(.width(1)) dirty_5(.clk(clk), .rst(), .load(dirty_load), .datain(dirty_in[5]), .index(set), .dataout(dirty_out[5]));
l2_data_array data_array_5(.clk(clk), .rst(), .write_en(data_write_en[5]), .index(set), .datain(data_array_in), .dataout(data_array_out[5]));

l2_array #(.width(24)) tag_6(.clk(clk), .rst(), .load(tag_load[6]), .index(set), .datain(tag), .dataout(tag_out[6]));
l2_array #(.width(1)) valid_6(.clk(clk), .rst(rst), .load(valid_load), .datain(valid_in[6]), .index(set), .dataout(valid_out[6]));
l2_array #(.width(1)) dirty_6(.clk(clk), .rst(), .load(dirty_load), .datain(dirty_in[6]), .index(set), .dataout(dirty_out[6]));
l2_data_array data_array_6(.clk(clk), .rst(), .write_en(data_write_en[6]), .index(set), .datain(data_array_in), .dataout(data_array_out[6]));

l2_array #(.width(24)) tag_7(.clk(clk), .rst(), .load(tag_load[7]), .index(set), .datain(tag), .dataout(tag_out[7]));
l2_array #(.width(1)) valid_7(.clk(clk), .rst(rst), .load(valid_load), .datain(valid_in[7]), .index(set), .dataout(valid_out[7]));
l2_array #(.width(1)) dirty_7(.clk(clk), .rst(), .load(dirty_load), .datain(dirty_in[7]), .index(set), .dataout(dirty_out[7]));
l2_data_array data_array_7(.clk(clk), .rst(), .write_en(data_write_en[7]), .index(set), .datain(data_array_in), .dataout(data_array_out[7]));

plru #(.s_index(3)) pLRU(.clk(clk), .rst(rst), .load(lru_load), .index(set), .mru(mru), .plru(plru));

always_comb begin
    for (int i = 0; i < 8; i++) begin
        way_hit[i] = (tag == tag_out[i]) && valid_out[i];
    end

    cache_o = data_array_out[way_sel];

    pmem_address = {tag_out[way_sel], set, 5'b0};

    case(way_data_in_sel)
        1'b0: data_array_in = pmem_rdata;
        1'b1: data_array_in = mem_wdata;
    endcase
end

endmodule : l2_cache_datapath
