import rv32i_types::*;
import ctrl_types::*;
import instr_types::*;

module memwb_rg(
    input clk,
    input memwb_rst,
    input memwb_load,

    // data in/out
    input ctrl_types::ctrl_t exmem_ctrl_word,
    output ctrl_types::ctrl_t memwb_ctrl_word,
    input logic exmem_br_en,
    output logic memwb_br_en,
    input rv32i_word mem_rdata,
    output rv32i_word memwb_rdata,
    input rv32i_word exmem_alu_out,
    output rv32i_word memwb_alu_out,
    input instr_types::instr_t exmem_instruction,
    output instr_types::instr_t memwb_instruction,
    input rv32i_word exmem_pc,
    output rv32iword memwb_pc
);

// MEM / WB Registers
register #(.width=20) memwb_ctrl_word_reg(
    .clk    (clk),
    .rst    (memwb_rst),
    .load   (memwb_load),
    .in     (exmem_ctrl_word),
    .out    (memwb_ctrl_word)
);

register #(.width=1) memwb_br_en_reg(
    .clk    (clk),
    .rst    (memwb_rst),
    .load   (memwb_load),
    .in     (exmem_br_en),
    .out    (memwb_br_en)
);

register memwb_rdata_reg(
    .clk    (clk),
    .rst    (memwb_rst),
    .load   (memwb_load),
    .in     (mem_rdata),
    .out    (memwb_rdata)
);

register memwb_alu_out_reg(
    .clk    (clk),
    .rst    (memwb_rst),
    .load   (memwb_load),
    .in     (exmem_alu_out),
    .out    (memwb_alu_out)
);

register #(.width=192) memwb_instr_reg(
    .clk    (clk),
    .rst    (memwb_rst),
    .load   (memwb_load),
    .in     (exmem_instruction),
    .out    (memwb_instruction)
);

register memwb_pc_reg(
    .clk    (clk),
    .rst    (memwb_rst),
    .load   (memwb_load),
    .in     (exmem_pc),
    .out    (memwb_pc)
);

endmodule : memwb_rg