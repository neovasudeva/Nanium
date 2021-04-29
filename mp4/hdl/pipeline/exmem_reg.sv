import rv32i_types::*;
import instr_types::*;
import ctrl_types::*;
import pbp_types::*;

module exmem_reg(
    input clk,
    input exmem_rst,
    input exmem_load,

    // data in/out
    input ctrl_types::ctrl_t idex_ctrl_word,
    output ctrl_types::ctrl_t exmem_ctrl_word,
    input rv32i_word idex_pc,
    output rv32i_word exmem_pc,
    input logic ex_br_en,
    output logic exmem_br_en,
    input rv32i_word ex_alu_out,
    output rv32i_word exmem_alu_out,
    input rv32i_word idex_rs2_out,
    output rv32i_word exmem_rs2_out,
    input instr_types::instr_t idex_instruction,
    output instr_types::instr_t exmem_instruction,
	input pbp_types::pbp_t idex_pbp,
	output pbp_types::pbp_t exmem_pbp
);

// EX / MEM Registers
register #(.width(20)) exmem_ctrl_word_reg(
    .clk    (clk),
    .rst    (exmem_rst),
    .load   (exmem_load),
    .in     (idex_ctrl_word),
    .out    (exmem_ctrl_word)
);

register exmem_pc_reg(
    .clk    (clk),
    .rst    (exmem_rst),
    .load   (exmem_load),
    .in     (idex_pc),
    .out    (exmem_pc)
);

register #(.width(1)) exmem_br_en_reg(
    .clk    (clk),
    .rst    (exmem_rst),
    .load   (exmem_load),
    .in     (ex_br_en),
    .out    (exmem_br_en)
);

register exmem_alu_out_reg(
    .clk    (clk),
    .rst    (exmem_rst),
    .load   (exmem_load),
    .in     (ex_alu_out),
    .out    (exmem_alu_out)
);

register exmem_rs2_out_reg(
    .clk    (clk),
    .rst    (exmem_rst),
    .load   (exmem_load),
    .in     (idex_rs2_out),
    .out    (exmem_rs2_out)
);

register #(.width(192)) exmem_instr_reg(
    .clk    (clk),
    .rst    (exmem_rst),
    .load   (exmem_load),
    .in     (idex_instruction),
    .out    (exmem_instruction)
);

register #(.width(41)) exmem_pbp_reg (
	.clk    (clk),
    .rst    (exmem_rst),
    .load   (exmem_load),
    .in     (idex_pbp),
    .out    (exmem_pbp)
);

endmodule : exmem_reg