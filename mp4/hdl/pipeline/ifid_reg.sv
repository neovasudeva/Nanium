import rv32i_types::*;
import instr_types::*;
import ctrl_types::*;
import pbp_types::*;

module ifid_reg (
    input clk,
    input ifid_rst,
    input ifid_load,

    // data in/out
    input instr_types::instr_t if_instruction,
    output instr_types::instr_t ifid_instruction,
    input rv32i_word if_pc,
    output rv32i_word ifid_pc,
	input pbp_types::pbp_t if_pbp,
	output pbp_types::pbp_t ifid_pbp
);

// IF / ID Registers 
register #(.width(192)) ifid_instr_reg (
    .clk    (clk),
    .rst    (ifid_rst),
    .load   (ifid_load),
    .in     (if_instruction),
    .out    (ifid_instruction)
);

register ifid_pc_reg (
    .clk    (clk),
    .rst    (ifid_rst),
    .load   (ifid_load),
    .in     (if_pc),
    .out    (ifid_pc)
);

register #(.width(41)) ifid_pbp_reg (
	.clk    (clk),
    .rst    (ifid_rst),
    .load   (ifid_load),
    .in     (if_pbp),
    .out    (ifid_pbp)
);

endmodule : ifid_reg