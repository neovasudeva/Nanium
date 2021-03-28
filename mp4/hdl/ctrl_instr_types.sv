import rv32i_types::*;
import pcmux::*;
import cmpmux::*;
import alumux::*;
import regfilemux::*;

// package contains struct(s) used for control ROM
// size = 20
package ctrl_types;
typedef struct packed {
	logic load_regfile;
	regfilemux::regfilemux_sel_t regfilemux_sel;
	alumux::alumux1_sel_t alumux1_sel;
    alumux::alumux2_sel_t alumux2_sel;
    cmpmux::cmpmux_sel_t cmpmux_sel;
	dcachemux::rdata_sel_t rdata_sel;
    rv32i_types::alu_ops aluop;
	rv32i_types::branch_funct3_t cmpop;
	logic dcache_read;
	logic dcache_write;
} ctrl_t;
endpackage : ctrl_types

// package contains struct(s) from instruction fetch/decode
// size = 192
package instr_types;
typedef struct packed {
	rv32i_types::opcode_t opcode;
	rv32i_types::rv32i_reg rs1;
	rv32i_types::rv32i_reg rs2;
	rv32i_types::rv32i_reg rd;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [31:0] i_imm;
	logic [31:0] u_imm;
	logic [31:0] j_imm;
	logic [31:0] b_imm;
	logic [31:0] s_imm;
} instr_t;
endpackage : instr_types