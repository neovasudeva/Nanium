`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;
import ctrl_types::*;
import instr_types::*;
import pcmux::*;
import cmpmux::*;
import alumux::*;
import regfilemux::*;
import rs1mux::*;
import rs2mux::*;
import dcacheforwardmux::*;

module datapath(
    input clk, 
    input rst, 

    // icache mem signals
    output logic icache_read,
    output rv32i_word icache_addr,
    input rv32i_word icache_rdata,
    input logic icache_resp,
    
    // dcache mem signals
    output logic [3:0] dcache_byte_enable,
    output logic dcache_read,
    output logic dcache_write,
    output rv32i_word dcache_addr,
    output rv32i_word dcache_wdata,
    input rv32i_word dcache_rdata,
    input logic dcache_resp
);

/****************************** PIPELINE SIGNALS *****************************/ 
// pcmux
rv32i_word pcmux_out;

// IF signals
rv32i_word if_pc;
instr_types::instr_t if_instruction;

// ID signals (also from IF/ID regs)
instr_types::instr_t ifid_instruction;
rv32i_word ifid_pc;
ctrl_types::ctrl_t id_ctrl_word;
rv32i_word id_rs1_out;
rv32i_word id_rs2_out;

// EX signals (also from ID/EX regs)
ctrl_types::ctrl_t idex_ctrl_word;
rv32i_word idex_pc;
instr_types::instr_t idex_instruction;
rv32i_word idex_rs1_out;
rv32i_word idex_rs2_out;
rv32i_word ex_alumux1_out;
rv32i_word ex_alumux2_out;
rv32i_word ex_alu_out;
rv32i_word ex_cmpmux_out;
logic ex_br_en;

// MEM signals (also from EX/MEM regs)
ctrl_types::ctrl_t exmem_ctrl_word;
rv32i_word exmem_pc;
logic exmem_br_en;
rv32i_word exmem_alu_out;
rv32i_word exmem_rs2_out;
instr_types::instr_t exmem_instruction;
rv32i_word mem_rdata;

// WB signals
ctrl_types::ctrl_t memwb_ctrl_word;
rv32i_word memwb_pc;
logic memwb_br_en;
rv32i_word memwb_rdata;
rv32i_word memwb_alu_out;
instr_types::instr_t memwb_instruction;
rv32i_word wb_regfilemux_out;

// forwarding mux signals
rs1mux_sel_t rs1mux_sel;
rs2mux_sel_t rs2mux_sel;
dcacheforwardmux_sel_t dcacheforwardmux_sel;
rv32i_word rs1mux_out;
rv32i_word rs2mux_out;
rv32i_word dcacheforwardmux_out;
/*****************************************************************************/

/**************************** LOAD/STALL SIGNALS ******************************/ 
// load and reset signals to pipeline regs
logic pc_load, ifid_load, idex_load, exmem_load, memwb_load;
logic pc_rst, ifid_rst, idex_rst, exmem_rst, memwb_rst;

// stall and rst signals
logic forward_stall;
logic cache_stall;
logic branch_rst;
assign cache_stall = ((dcache_read || dcache_write) && ~dcache_resp) || 
                     ((icache_read) && ~icache_resp);
assign branch_rst = ((exmem_br_en && exmem_instruction.opcode == rv32i_types::op_br) || 
                    (exmem_instruction.opcode == rv32i_types::op_jal) || 
                    (exmem_instruction.opcode == rv32i_types::op_jalr)) &&
					~cache_stall;

// loads and reset
assign pc_load = ~forward_stall && ~cache_stall;
assign ifid_load = ~forward_stall && ~cache_stall;
assign idex_load = ~forward_stall && ~cache_stall;
assign exmem_load = ~cache_stall;
assign memwb_load = ~cache_stall; 
assign pc_rst = rst;
assign ifid_rst = rst || branch_rst;
assign idex_rst = rst || branch_rst;
assign exmem_rst = rst || (forward_stall && ~cache_stall) || branch_rst;
assign memwb_rst = rst;
/*****************************************************************************/

/******************************** MEMORY SIGNALS *****************************/ 
assign icache_read = 1'b1; // always read, change later
assign icache_addr = if_pc;
/*****************************************************************************/ 

/******************************* PIPELINE REGS *******************************/
/* Instruction Fetch Registers */
pc_register if_pc_reg (
    .clk    (clk),
    .rst    (pc_rst),
    .load   (pc_load),
    .in     (pcmux_out),
    .out    (if_pc)
);

ifid_reg ifid_pipe (
    .clk                (clk), 
    .ifid_rst           (ifid_rst),
    .ifid_load          (ifid_load),
    .if_instruction     (if_instruction),
    .ifid_instruction   (ifid_instruction),
    .if_pc              (if_pc),
    .ifid_pc            (ifid_pc)
);

id_stage idecode(
    .clk                    (clk),
	.rst					(rst),
    .ifid_instruction       (ifid_instruction),
    .ifid_pc                (ifid_pc),
    .memwb_load_regfile     (memwb_ctrl_word.load_regfile),
    .memwb_rd               (memwb_instruction.rd),
    .wb_regfilemux_out      (wb_regfilemux_out),
    .id_ctrl_word           (id_ctrl_word),
    .id_rs1_out             (id_rs1_out),
    .id_rs2_out             (id_rs2_out)
);

/* Instruction Decode Registers */
idex_reg idex_pipe(
    .clk                (clk),
    .idex_rst           (idex_rst),
    .idex_load          (idex_load),
    .id_ctrl_word       (id_ctrl_word),
    .idex_ctrl_word     (idex_ctrl_word),
    .ifid_pc            (ifid_pc),
    .idex_pc            (idex_pc),
    .ifid_instruction   (ifid_instruction),
    .idex_instruction   (idex_instruction),
    .id_rs1_out         (id_rs1_out),
    .idex_rs1_out       (idex_rs1_out),
    .id_rs2_out         (id_rs2_out),
    .idex_rs2_out       (idex_rs2_out)
);

ex_stage execute(
    .idex_instruction   (idex_instruction),
    .idex_ctrl_word     (idex_ctrl_word),
    .idex_pc            (idex_pc),
    .idex_rs1_out       (rs1mux_out /*idex_rs1_out*/),
    .idex_rs2_out       (rs2mux_out /*idex_rs2_out*/),
    .ex_alu_out         (ex_alu_out),
    .ex_br_en           (ex_br_en)
);

/* Execute Registers */
exmem_reg exmem_pipe(
    .clk                (clk),
    .exmem_rst          (exmem_rst),
    .exmem_load         (exmem_load),
    .idex_ctrl_word     (idex_ctrl_word),
    .exmem_ctrl_word    (exmem_ctrl_word),
    .idex_pc            (idex_pc),
    .exmem_pc           (exmem_pc),
    .ex_br_en           (ex_br_en),
    .exmem_br_en        (exmem_br_en),
    .ex_alu_out         (ex_alu_out),
    .exmem_alu_out      (exmem_alu_out),
    .idex_rs2_out       (idex_rs2_out),
    .exmem_rs2_out      (exmem_rs2_out),
    .idex_instruction   (idex_instruction),
    .exmem_instruction  (exmem_instruction)
);

mem_stage memory (
    .exmem_instruction  (exmem_instruction),
    .exmem_ctrl_word    (exmem_ctrl_word),
    .exmem_pc           (exmem_pc),
    .exmem_br_en        (exmem_br_en),
    .exmem_alu_out      (exmem_alu_out),
    .exmem_rs2_out      (dcacheforwardmux_out /*exmem_rs2_out*/),
    .dcache_byte_enable (dcache_byte_enable),
    .dcache_read        (dcache_read),
    .dcache_write       (dcache_write),
    .dcache_addr        (dcache_addr),
    .dcache_wdata       (dcache_wdata),
    .dcache_rdata       (dcache_rdata),
    .mem_rdata          (mem_rdata)

);

/* Memory Registers */
memwb_reg memwb_pipe(
    .clk                (clk),
    .memwb_rst          (memwb_rst),
    .memwb_load         (memwb_load),
    .exmem_ctrl_word    (exmem_ctrl_word),
    .memwb_ctrl_word    (memwb_ctrl_word),
    .exmem_br_en        (exmem_br_en),
    .memwb_br_en        (memwb_br_en),
    .mem_rdata          (mem_rdata),
    .memwb_rdata        (memwb_rdata),
    .exmem_alu_out      (exmem_alu_out),
    .memwb_alu_out      (memwb_alu_out),
    .exmem_instruction  (exmem_instruction),
    .memwb_instruction  (memwb_instruction),
    .exmem_pc           (exmem_pc),
    .memwb_pc           (memwb_pc)
);

wb_stage writeback (
    .memwb_instruction	(memwb_instruction),
    .memwb_ctrl_word	(memwb_ctrl_word),
    .memwb_alu_out		(memwb_alu_out),
    .memwb_br_en		(memwb_br_en),
    .memwb_rdata		(memwb_rdata),
    .memwb_pc			(memwb_pc),
    .wb_regfilemux_out	(wb_regfilemux_out)
);
/*****************************************************************************/

/******************************* LOGIC UNITS *********************************/
// instruction breakdown logic 
assign if_instruction.opcode = opcode_t'(icache_rdata[6:0]);
assign if_instruction.rs1 = icache_rdata[19:15];
assign if_instruction.rs2 = icache_rdata[24:20];
assign if_instruction.rd = icache_rdata[11:7];
assign if_instruction.funct3 = icache_rdata[14:12];
assign if_instruction.funct7 = icache_rdata[31:25];
assign if_instruction.i_imm = {{21{icache_rdata[31]}}, icache_rdata[30:20]};
assign if_instruction.u_imm = {icache_rdata[31:12], 12'h000};
assign if_instruction.j_imm = {{12{icache_rdata[31]}}, icache_rdata[19:12], icache_rdata[20], icache_rdata[30:21], 1'b0};
assign if_instruction.b_imm = {{20{icache_rdata[31]}}, icache_rdata[7], icache_rdata[30:25], icache_rdata[11:8], 1'b0};
assign if_instruction.s_imm = {{21{icache_rdata[31]}}, icache_rdata[30:25], icache_rdata[11:7]};

// forwarding unit
forward forwarding_unit (
    .idex_instruction     (idex_instruction),
    .exmem_instruction    (exmem_instruction),
    .memwb_instruction    (memwb_instruction),
	.exmem_load_regfile   (exmem_ctrl_word.load_regfile),
	.memwb_load_regfile	  (memwb_ctrl_word.load_regfile),
    .rs1mux_sel           (rs1mux_sel),
    .rs2mux_sel           (rs2mux_sel),
    .dcacheforwardmux_sel (dcacheforwardmux_sel),
    .forward_stall        (forward_stall)
);
/*****************************************************************************/

/******************************** Muxes **************************************/
always_comb begin
    // pcmux
    if (branch_rst) begin    
        // jal and jalr case
        if (exmem_instruction.opcode == rv32i_types::op_jal || exmem_instruction.opcode == rv32i_types::op_jalr)
            pcmux_out = {exmem_alu_out[31:1], 1'b0};     
        else
            pcmux_out = exmem_alu_out;
    end
    else    
        pcmux_out = if_pc + 4;

    // rs1mux
    unique case (rs1mux_sel) 
        rs1mux::rs1_out:        rs1mux_out = idex_rs1_out;
        rs1mux::br_en:          rs1mux_out = exmem_br_en;
        rs1mux::u_imm:          rs1mux_out = exmem_instruction.u_imm;
        rs1mux::alu_out:        rs1mux_out = exmem_alu_out;
        rs1mux::regfilemux_out: rs1mux_out = wb_regfilemux_out;
        default:                rs1mux_out = idex_rs1_out;
    endcase

    // rs2 mux
    unique case (rs2mux_sel) 
        rs2mux::rs2_out:        rs2mux_out = idex_rs2_out;
        rs2mux::br_en:          rs2mux_out = exmem_br_en;
        rs2mux::u_imm:          rs2mux_out = exmem_instruction.u_imm;
        rs2mux::alu_out:        rs2mux_out = exmem_alu_out;
        rs2mux::regfilemux_out: rs2mux_out = wb_regfilemux_out;
        default:                rs2mux_out = idex_rs2_out;
    endcase

    // dcacheforward mux
    unique case (dcacheforwardmux_sel) 
        dcacheforwardmux::rs2_out:          dcacheforwardmux_out = exmem_rs2_out;
        dcacheforwardmux::regfilemux_out:   dcacheforwardmux_out = wb_regfilemux_out;
    endcase
end
/*****************************************************************************/

endmodule : datapath