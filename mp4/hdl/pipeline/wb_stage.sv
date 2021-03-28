import rv32i_types::*;
import ctrl_types::*;
import instr_types::*;
import regfilemux::*;

module wb_stage(
    input clk,
    input rst,
    input instr_types::instr_t memwb_instruction,
    input ctrl_types::ctrl_t memwb_ctrl_word,

    input rv32i_word memwb_alu_out,
    input logic memwb_br_en,
    input rv32i_word memwb_rdata,
    input rv32i_word memwb_pc,

    output rv32i_word wb_regfilemux_out
);

/******************************** Muxes **************************************/
always_comb begin : MUXES
    // regfilemux
    unique case (memwb_ctrl_word.regfilemux_sel)
        regfilemux::alu_out:    wb_regfilemux_out = memwb_alu_out;
        regfilemux::br_en:      wb_regfilemux_out = memwb_br_en;
        regfilemux::u_imm:      wb_regfilemux_out = memwb_instruction.u_imm;
        regfilemux::rdata:      wb_regfilemux_out = memwb_rdata;
        regfilemux::pc_plus4:   wb_regfilemux_out = memwb_pc + 4;
    endcase
end
/*****************************************************************************/


endmodule : wb_stage