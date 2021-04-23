import rv32i_types::*;
import instr_types::*;
import ctrl_types::*;
import alumux::*;
import cmpmux::*;
import rs1mux::*;
import rs2mux::*;

module ex_stage(
	// stage inputs
    input instr_types::instr_t idex_instruction,
    input ctrl_types::ctrl_t idex_ctrl_word,
    input rv32i_word idex_pc,
    input rv32i_word idex_rs1_out,
    input rv32i_word idex_rs2_out,
	
	// forwarding inputs
	/*
	input rs1mux_sel_t rs1mux_sel,
	input logic exmem_br_en,
	input instr_types::instr_t exmem_instruction,
	input rv32i_word exmem_alu_out,
	input rv32i_word wb_regfilemux_out,
	*/
	
	// stage outputs
    output rv32i_word ex_alu_out,
    output logic ex_br_en
);

/******************************** SIGNALS ************************************/
//rv32i_word rs1mux_out;
rv32i_word alumux1_out;
rv32i_word cmpmux_out;
rv32i_word alumux2_out;
/*****************************************************************************/

/******************************** Muxes **************************************/
always_comb begin : MUXES
	// forwarding rs1
	/*
	unique case (rs1mux_sel) 
        rs1mux::rs1_out:        rs1mux_out = idex_rs1_out;
        rs1mux::br_en:          rs1mux_out = exmem_br_en;
        rs1mux::u_imm:          rs1mux_out = exmem_instruction.u_imm;
        rs1mux::alu_out:        rs1mux_out = exmem_alu_out;
        rs1mux::regfilemux_out: rs1mux_out = wb_regfilemux_out;
        default:                rs1mux_out = idex_rs1_out;
    endcase
	*/
	
    // alumux1
    unique case (idex_ctrl_word.alumux1_sel)
        alumux::rs1_out:    alumux1_out = idex_rs1_out; //rs1mux_sel;
        alumux::pc_out:     alumux1_out = idex_pc;
    endcase

    // cmpmux
    unique case (idex_ctrl_word.cmpmux_sel)
        cmpmux::rs2_out:    cmpmux_out = idex_rs2_out;
        cmpmux::i_imm:      cmpmux_out = idex_instruction.i_imm;
    endcase

    // alumux2
    unique case (idex_ctrl_word.alumux2_sel)
        alumux::i_imm:      alumux2_out = idex_instruction.i_imm;
        alumux::u_imm:      alumux2_out = idex_instruction.u_imm;
        alumux::b_imm:      alumux2_out = idex_instruction.b_imm;
        alumux::s_imm:      alumux2_out = idex_instruction.s_imm;
        alumux::j_imm:      alumux2_out = idex_instruction.j_imm;
        alumux::rs2_out:    alumux2_out = idex_rs2_out;
        default: ;
    endcase
end
/*****************************************************************************/

/******************************* LOGIC UNITS *********************************/
alu ALU(
    .aluop  (idex_ctrl_word.aluop),
    .a      (alumux1_out),
    .b      (alumux2_out),
    .f      (ex_alu_out)
);

cmp CMP(
    .cmpop  (idex_ctrl_word.cmpop),
    .a      (idex_rs1_out /*rs1mux_out*/),
    .b      (cmpmux_out),
    .br_en  (ex_br_en)
);
/*****************************************************************************/

endmodule : ex_stage
