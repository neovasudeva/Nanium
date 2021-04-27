import rv32i_types::*;

module btb #(
    parameter width = 32,
    parameter bit_entry = 5,
    parameter num_entry = 2**bit_entry,
    parameter tag_len = width - bit_entry - 2
)
(
    input clk,
    input rst,
    input rv32i_word r_pc,
    output rv32i_word target_out,
    input rv32i_word w_pc,
    input load,
    input rv32i_word target_in, 
    output btb_hit
);

/********************************** SIGNALS **********************************/ 
logic [bit_entry-1:0] r_index, w_index;
logic [tag_len-1:0] r_tag, w_tag;

logic [tag_len-1:0] tag_out;
logic valid_out;

assign r_index = r_pc[bit_entry+1:2];
assign w_index = w_pc[bit_entry+1:2];
assign r_tag = r_pc[31:width-tag_len];
assign w_tag = w_pc[31:width-tag_len];

assign btb_hit = (r_tag == tag_out && valid_out);
/*****************************************************************************/

/******************************* LOGICAL UNITS *******************************/ 
btb_array #(.width(tag_len)) tag_array (
    .clk    (clk),
    .rst    (rst),
    .load   (load),
    .rindex (r_index),
    .windex (w_index),
    .din    (w_tag),
    .dout   (tag_out)
);

btb_array #(.width(width)) target_array (
    .clk    (clk),
    .rst    (rst),
    .load   (load),
    .rindex (r_index),
    .windex (w_index),
    .din    (target_in),
    .dout   (target_out)
);

btb_array #(.width(1)) valid_array (
    .clk    (clk),
    .rst    (rst),
    .load   (load),
    .rindex (r_index),
    .windex (w_index),
    .din    (1'b1),
    .dout   (valid_out)
);
/*****************************************************************************/

endmodule : btb