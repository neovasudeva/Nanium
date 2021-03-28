import rv32i_types::*;
import instr_types::*;
import ctrl_types::*;

module id_stage(
    input clk,
    //input rst,
    input instr_types::instr_t ifid_instruction,
    input rv32i_word ifid_pc,
    input logic memwb_load_regfile,
    input rv32i_reg memwb_rd,
    input rv32i_word wb_regfilemux_out,

    output ctrl_types::ctrl_t id_ctrl_word,
    output rv32i_word id_rs1_out,
    output rv32i_word id_rs2_out
);

// control ROM
ctrl_rom control (
    .instruction    (ifid_instruction),
    .ctrl           (id_ctrl_word)
);

// regfile
regfile regs (
    .clk    (clk),
    .rst    (1'b0 /* fix later */),
    .load   (memwb_load_regfile),
    .in     (wb_regfilemux_out),
    .src_a  (ifid_instruction.rs1), 
    .src_b  (ifid_instruction.rs2),
    .dest   (memwb_rd),
    .reg_a  (id_rs1_out), 
    .reg_b  (id_rs2_out)
)

endmodule : id_stage