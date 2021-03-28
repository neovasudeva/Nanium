import rv32i_types::*;
import instr_types::*;
import ctrl_types::*;

module idex_reg(
    input clk,
    input idex_rst,
    input idex_load,

    // data in/out
    input ctrl_types::ctrl_t id_ctrl_word,
    output ctrl_types::ctrl_t idex_ctrl_word,
    input rv32i_word ifid_pc,
    output rv32i_word idex_pc,
    input instr_types::instr_t ifid_instruction,
    output instr_types::instr_t idex_instruction,
    input rv32i_word id_rs1_out,
    output rv32i_word idex_rs1_out,
    input rv32i_word id_rs2_out,
    output rv32i_word idex_rs2_out
);

// ID / EX Registers 
register #(.width(20)) idex_ctrl_word_reg (
    .clk    (clk),
    .rst    (idex_rst),
    .load   (idex_load),
    .in     (id_ctrl_word),
    .out    (idex_ctrl_word)
);

register idex_pc_reg (
    .clk    (clk),
    .rst    (idex_rst),
    .load   (idex_load),
    .in     (ifid_pc),
    .out    (idex_pc)
);

register #(.width(192)) idex_instr_reg(
    .clk    (clk),
    .rst    (idex_rst),
    .load   (idex_load),
    .in     (ifid_instruction),
    .out    (idex_instruction)
);

register idex_rs1_out_reg(
    .clk    (clk),
    .rst    (idex_rst),
    .load   (idex_load),
    .in     (id_rs1_out),
    .out    (idex_rs1_out)
);

register idex_rs2_out_reg(
    .clk    (clk),
    .rst    (idex_rst),
    .load   (idex_load),
    .in     (id_rs2_out),
    .out    (idex_rs2_out)
);

endmodule : idex_reg