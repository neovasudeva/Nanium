// control ROM - generates control signals for instruction through pipeline
import rv32i_types::*;
import ctrl_types::*;
import instr_types::*;
import pcmux::*;
import marmux::*;
import cmpmux::*;
import alumux::*;
import regfilemux::*;

module ctrl_rom(
    input instr_types::instr_t instruction,
    output ctrl_types::ctrl_t ctrl
);

always_comb
begin
    /* Default assignments */
    ctrl.load_regfile = 1'b0;
	ctrl.regfilemux_sel = regfilemux::alu_out;
	ctrl.alumux1_sel = alumux::rs1_out;
    ctrl.alumux2_sel = alumux::i_imm;
    ctrl.cmpmux_sel = cmpmux::rs2_out;
    ctrl.rdata_sel = dcachemux::lw;
    ctrl.aluop = rv32i_types::alu_add;
	ctrl.cmpop = rv32i_types::beq;
	ctrl.dcache_read = 1'b0;
	ctrl.dcache_write = 1'b0;

    /* Assign control signals based on opcode */
    case(instruction.opcode)
        /* op_lui */
        op_lui: begin
            ctrl.load_regfile = 1'b1;
            ctrl.regfilemux_sel = regfilemux::u_imm;
        end

        /* auipc */
        op_auipc: begin
            ctrl.load_regfile = 1'b1;
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = alumux::u_imm;
        end

        /* jal */
        op_jal: begin
            ctrl.regfilemux_sel = regfilemux::pc_plus4;
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = alumux::j_imm;
            ctrl.load_regfile = 1'b1;
        end

        /* jalr */
        op_jalr: begin
            ctrl.regfilemux_sel = regfilemux::pc_plus4;
            ctrl.load_regfile = 1'b1;
        end

        /* br */
        op_br: begin
            ctrl.alumux1_sel = alumux::pc_out;
            ctrl.alumux2_sel = alumux:b_imm;
            ctrl.aluop = rv32i_types::alu_add;
            ctrl.cmpop = branch_funct3_t'(instruction.funct3);
        end

        /* load */
        op_load: begin
            ctrl.dcache_read = 1'b1;
            ctrl.load_regfile = 1'b1;
            ctrl.regfilemux_sel = regfilemux::rdata;
            unique case (instruction.funct3)
                rv32i_types::lw:    ctrl.rdata_sel = dcachemux::lw;
                rv32i_types::lhu:   ctrl.rdata_sel = dcachemux::lhu;
                rv32i_types::lh:    ctrl.rdata_sel = dcachemux::lh;
                rv32i_types::lbu:   ctrl.rdata_sel = dcachemux::lbu;
                rv32i_types::lb:    ctrl.rdata_sel = dcachemux::lb;
                default:            ctrl.rdata_sel = dcachemux::lw;
            endcase
        end

        /* store */
        op_store: begin
            ctrl.dcache_write = 1'b1;
            ctrl.alumux2_sel = alumux::s_imm;
        end

        /* imm */
        op_imm: begin
            // slti
            if (instruction.funct3 == rv32i_types::slt) begin
                ctrl.load_regfile = 1'b1;
                ctrl.cmpop = rv32i_types::blt;
                ctrl.regfilemux_sel = regfilemux::br_en;
                ctrl.cmpmux_sel = cmpmux::i_imm;
            end

            else if (instruction.funct3 == rv32i_types::sltu) begin
				ctrl.load_regfile = 1'b1;
				ctrl.cmpop = rv32i_types::bltu;
				ctrl.regfilemux_sel = regfilemux::br_en;
				ctrl.cmpmux_sel = cmpmux::i_imm;
			end
			
			// sr (srai, srli)
			else if (instruction.funct3 == rv32i_types::sr) begin
				ctrl.load_regfile = 1'b1;
				ctrl.regfilemux_sel = regfilemux::alu_out;
				
				// srai/srli
				if (instruction.funct7 == 7'b0100000)
					ctrl.aluop = rv32i_types::alu_sra;
				else
					ctrl.aluop = rv32i_types::alu_srl;
			end
            
            // other immediates
            else begin
				ctrl.load_regfile = 1'b1;
				ctrl.aluop = alu_ops'(instruction.funct3);
			end
        end

        /* reg */
        op_reg: begin
            // other control signals
            ctrl.load_regfile = 1'b1;
            ctrl.alumux1_sel = alumux::rs1_out;
            ctrl.alumux2_sel = alumux::rs2_out; 
            ctrl.regfilemux_sel = regfilemux::alu_out; 
                        
            // add/sub
            if (instruction.funct3 == rv32i_types::add) begin
                if (instruction.funct7 == 7'b0000000) 
                    ctrl.aluop = rv32i_types::alu_add;
                else 
                    ctrl.aluop = rv32i_types::alu_sub;
            end
                        
            // srl/sra
            else if (instruction.funct3 == rv32i_types::sr) begin
                if (instruction.funct7 == 7'b0000000)
                    ctrl.aluop = rv32i_types::alu_srl;
                else 
                    ctrl.aluop = rv32i_types::alu_sra;
            end
                        
            // sll
            else if (instruction.funct3 == rv32i_types::sll) 
                ctrl.aluop = rv32i_types::alu_sll;
                        
            // slt
            else if (instruction.funct3 == rv32i_types::slt) begin
                ctrl.cmpop = rv32i_types::blt;
                ctrl.regfilemux_sel = regfilemux::br_en;
                ctrl.cmpmux_sel = cmpmux::rs2_out; 
            end
                        
            // sltu
            else if (instruction.funct3 == rv32i_types::sltu) begin
                ctrl.cmpop = rv32i_types::bltu;
                ctrl.regfilemux_sel = regfilemux::br_en;
                ctrl.cmpmux_sel = cmpmux::rs2_out;
            end
                        
            // xor
            else if (instruction.funct3 == rv32i_types::axor)
                ctrl.aluop = rv32i_types::alu_xor;
                        
            // or
            else if (instruction.funct3 == rv32i_types::aor)
                ctrl.aluop = rv32i_types::alu_or;
                        
            // and
            else if (instruction.funct3 == rv32i_types::aand) 
                ctrl.aluop = rv32i_types::alu_and;
        end
        
        default: begin
            ctrl = 0;   /* Unknown opcode, set control word to zero */
        end
    endcase
end
endmodule : ctrl_rom