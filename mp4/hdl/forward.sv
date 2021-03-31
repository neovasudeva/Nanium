// only useful for detecting data hazards, forwarding, and detecting forward stalls
import rv32i_types::*;
import ctrl_types::*;
import instr_types::*;
import rs1mux::*;
import rs2mux::*;
import dcacheforwardmux::*;

module forward (
    input instr_types::instr_t idex_instruction,
    input instr_types::instr_t exmem_instruction,
    input instr_types::instr_t memwb_instruction,

    output rs1mux_sel_t rs1mux_sel,
    output rs2mux_sel_t rs2mux_sel,
    output dcacheforwardmux_sel_t dcacheforwardmux_sel,
    output logic forward_stall
);

/**************************** Intermediary Signals ******************************/ 
logic idex_rd, idex_rs1, idex_rs2, idex_opcode;
logic exmem_rd, exmem_rs2, exmem_opcode;
logic memwb_rd, memwb_opcode;

assign idex_rd = idex_instruction.rd;
assign idex_rs1 = idex_instruction.rs1;
assign idex_rs2 = idex_instruction.rs2;
assign idex_opcode = idex_instruction.opcode;
assign exmem_rd = exmem_instruction.rd;
assign exmem_rs2 = exmem_instruction.rs2;
assign exmem_opcode = exmem_instruction.opcode;
assign memwb_rd = memwb_instruction.rd;
assign memwb_opcode = memwb_instruction.opcode;
/********************************************************************************/ 

/***************************** Forward Stall Logic ******************************/ 
logic fstall_rs1;
logic fstall_rs2;
assign fstall_rs1 = (exmem_rd == idex_rs1) && 
    (idex_opcode == rv32i_types::op_reg || 
    idex_opcode == rv32i_types::op_imm || 
    idex_opcode == rv32i_types::op_br || 
    idex_opcode == rv32i_types::op_jalr || 
    idex_opcode == rv32i_types::op_store || 
    idex_opcode == rv32i_types::op_load ||);
assign fstall_rs2 = (exmem_rd == idex_rs2) && 
    (idex_opcode == rv32i_types::op_reg || 
    idex_opcode == rv32i_types::op_br);

assign forward_stall = (fstall_rs1 || fstall_rs2) && exmem_opcode == rv32i_types::op_load;
/********************************************************************************/ 

/****************************** Forwarding Logic ********************************/ 
always_comb begin
    /* RS1 Forwarding logic */
    if (idex_rs1 == exmem_rd && exmem_instruction.load_regfile == 1'b1) begin
        // u_imm (lui)
        if (idex_opcode == rv32i_types::op_lui)
            rs1mux_sel = rs1mux::u_imm;

        // br_en (slt, sltu)
        else if ((idex_opcode == rv32i_types::op_reg || idex_opcode == rv32i_types::op_imm) && 
            (idex_instruction.funct3 == rv32i_types::slt || idex_instruction.funct3 == rv32i_types::sltu)) 
            rs1mux_sel = rs1mux::br_en;

        // alu_out
        else 
            rs1mux_sel = rs1mux::alu_out;
    end
    else if (idex_rs1 == memwb_rd && memwb_load_regfile == 1'b1) 
        rs1mux_sel = rs1mux::regfilemux_out;
    else 
        rs1mux_sel = rs1mux::rs1_out;

    /* RS2 Forwarding logic */
    if (idex_rs2 == exmem_rd && exmem_instruction.load_regfile == 1'b1) begin
        // u_imm (lui)
        if (idex_opcode == rv32i_types::op_lui)
            rs2mux_sel = rs2mux::u_imm;

        // br_en (slt, sltu)
        else if ((idex_opcode == rv32i_types::op_reg || idex_opcode == rv32i_types::op_imm) && 
            (idex_instruction.funct3 == rv32i_types::slt || idex_instruction.funct3 == rv32i_types::sltu)) 
            rs2mux_sel = rs2mux::br_en;

        // alu_out
        else 
            rs2mux_sel = rs2mux::alu_out;
    end
    else if (idex_rs2 == memwb_rd && memwb_load_regfile == 1'b1) 
        rs2mux_sel = rs2mux::regfilemux_out;
    else 
        rs2mux_sel = rs2mux::rs2_out;
    
    /* DCACHE forwarding logic */
    if (memwb_rd == exmem_rs2) 
        dcacheforwardmux_sel = dcacheforwardmux::regfilemux_out;
    else
        dcacheforwardmux_sel = dcacheforwardmux::rs2_out;
end
/********************************************************************************/ 


endmodule : forward