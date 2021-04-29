import rv32i_types::*;

module btb #(
    parameter width = 32,
    parameter bit_entry = 3,
    parameter n_way = 4
)(
    input clk,
    input rst,
    input rv32i_word r_pc,
    output rv32i_word target_out,
    input rv32i_word w_pc,
    input load,
    input rv32i_word target_in, 
    output btb_hit
);

localparam num_entry = 2**bit_entry;
localparam tag_len = width - bit_entry - 2;

/********************************** SIGNALS **********************************/ 
// decoding index and tag
logic [bit_entry-1:0] r_index, w_index;
logic [tag_len-1:0] r_tag, w_tag;

assign r_index = r_pc[bit_entry+1:2];
assign w_index = w_pc[bit_entry+1:2];
assign r_tag = r_pc[width-1:width-tag_len];
assign w_tag = w_pc[width-1:width-tag_len];

// read and write ways
logic [1:0] w_mru;  // way to write to
logic [1:0] r_mru;  // way to read from
logic [1:0] plru;   // way to write to if write miss

// read accesses
logic [tag_len-1:0] r_tag_out_vec [n_way];
logic [width-1:0] r_target_out_vec [n_way];
logic r_valid_out_vec [n_way];
logic [n_way-1:0] r_btb_hit_vec;
assign r_btb_hit_vec[0] = {r_tag_out_vec[0] == r_tag && r_valid_out_vec[0]};
assign r_btb_hit_vec[1] = {r_tag_out_vec[1] == r_tag && r_valid_out_vec[1]};
assign r_btb_hit_vec[2] = {r_tag_out_vec[2] == r_tag && r_valid_out_vec[2]}; 
assign r_btb_hit_vec[3] = {r_tag_out_vec[3] == r_tag && r_valid_out_vec[3]}; 

// write accesses
logic [tag_len-1:0] w_tag_out_vec [n_way];
logic [width-1:0] w_target_out_vec [n_way];
logic w_valid_out_vec [n_way];
logic [n_way-1:0] w_btb_hit_vec;
assign w_btb_hit_vec[0] = {w_tag_out_vec[0] == w_tag && w_valid_out_vec[0]};
assign w_btb_hit_vec[1] = {w_tag_out_vec[1] == w_tag && w_valid_out_vec[1]};
assign w_btb_hit_vec[2] = {w_tag_out_vec[2] == w_tag && w_valid_out_vec[2]}; 
assign w_btb_hit_vec[3] = {w_tag_out_vec[3] == w_tag && w_valid_out_vec[3]}; 

// load signals to each way (for writes)
logic [n_way-1:0] w_load;
assign w_load = {(w_mru == 2'b11) && load, (w_mru == 2'b10) && load, (w_mru == 2'b01) && load, (w_mru == 2'b00) && load};
/*****************************************************************************/

/******************************* WAY CALCULATION *****************************/ 
// btb_hit (for reads)
assign btb_hit = (r_btb_hit_vec != 4'h0);

// r_mru, w_mru, target_out
always_comb begin
    unique case (r_btb_hit_vec) 
        4'b0001:    r_mru = 2'b00;
        4'b0010:    r_mru = 2'b01;
        4'b0100:    r_mru = 2'b10;
        4'b1000:    r_mru = 2'b11;
        default:    r_mru = 2'b00;  // set read to 0 in pLRU if no btb_hit 
    endcase

    unique case (w_btb_hit_vec) 
        4'b0001:    w_mru = 2'b00;
        4'b0010:    w_mru = 2'b01;
        4'b0100:    w_mru = 2'b10;
        4'b1000:    w_mru = 2'b11;
        default:    w_mru = plru;   // evict least recently used way 
    endcase

    unique case (r_btb_hit_vec)   // btb hit vec of reads
        4'b0001:    target_out = r_target_out_vec[0];
        4'b0010:    target_out = r_target_out_vec[1];
        4'b0100:    target_out = r_target_out_vec[2];
        4'b1000:    target_out = r_target_out_vec[3];
        default:    target_out = 32'b0;  
    endcase
end
/*****************************************************************************/

/******************************* LOGICAL UNITS *******************************/ 
// pLRU (default params)
btb_plru btb_plru (
    .clk        (clk),
    .rst        (rst),
    .read       (btb_hit),
    .load       (load),
    .r_index    (r_index),
    .w_index    (w_index),
    .r_mru      (r_mru),
    .w_mru      (w_mru),
    .plru       (plru)
);

// WAY 0
btb_array #(.width(tag_len), .bit_entry(bit_entry)) tag_array_0 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[0]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (w_tag),
    .r_dout     (r_tag_out_vec[0]),
    .w_dout     (w_tag_out_vec[0])
);

btb_array #(.width(width), .bit_entry(bit_entry)) target_array_0 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[0]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (target_in),
    .r_dout     (r_target_out_vec[0]),
    .w_dout     (w_target_out_vec[0])
);

btb_array #(.width(1), .bit_entry(bit_entry)) valid_array_0 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[0]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (1'b1),
    .r_dout     (r_valid_out_vec[0]),
    .w_dout     (w_valid_out_vec[0])
);

// WAY 1
btb_array #(.width(tag_len), .bit_entry(bit_entry)) tag_array_1 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[1]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (w_tag),
    .r_dout     (r_tag_out_vec[1]),
    .w_dout     (w_tag_out_vec[1])
);

btb_array #(.width(width), .bit_entry(bit_entry)) target_array_1 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[1]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (target_in),
    .r_dout     (r_target_out_vec[1]),
    .w_dout     (w_target_out_vec[1])
);

btb_array #(.width(1), .bit_entry(bit_entry)) valid_array_1 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[1]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (1'b1),
    .r_dout     (r_valid_out_vec[1]),
    .w_dout     (w_valid_out_vec[1])
);

// WAY 2
btb_array #(.width(tag_len), .bit_entry(bit_entry)) tag_array_2 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[2]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (w_tag),
    .r_dout     (r_tag_out_vec[2]),
    .w_dout     (w_tag_out_vec[2])
);

btb_array #(.width(width), .bit_entry(bit_entry)) target_array_2 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[2]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (target_in),
    .r_dout     (r_target_out_vec[2]),
    .w_dout     (w_target_out_vec[2])
);

btb_array #(.width(1), .bit_entry(bit_entry)) valid_array_2 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[2]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (1'b1),
    .r_dout     (r_valid_out_vec[2]),
    .w_dout     (w_valid_out_vec[2])
);

// WAY 3
btb_array #(.width(tag_len), .bit_entry(bit_entry)) tag_array_3 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[3]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (w_tag),
    .r_dout     (r_tag_out_vec[3]),
    .w_dout     (w_tag_out_vec[3])
);

btb_array #(.width(width), .bit_entry(bit_entry)) target_array_3 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[3]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (target_in),
    .r_dout     (r_target_out_vec[3]),
    .w_dout     (w_target_out_vec[3])
);

btb_array #(.width(1), .bit_entry(bit_entry)) valid_array_3 (
    .clk        (clk),
    .rst        (rst),
    .load       (w_load[3]),
    .r_index    (r_index),
    .w_index    (w_index),
    .w_din      (1'b1),
    .r_dout     (r_valid_out_vec[3]),
    .w_dout     (w_valid_out_vec[3])
);
/*****************************************************************************/

endmodule : btb