import rv32i_types::*;

module pbp_tb ();
`timescale 1ns/1ns

logic clk;
logic rst;

/* inputs/outputs in IF stage */
logic [31:0] if_pc;
logic if_bp_br_en;
logic [7:0] if_y_out;
logic [31:0] if_bp_target;
logic btb_hit;
logic bp_rst;

/* inputs/outputs in EX/MEM regs */
logic [31:0] exmem_pc;
logic exmem_br_en;
logic [31:0] exmem_bp_target;
logic [7:0] exmem_y_out;
rv32i_types::opcode_t exmem_opcode;
logic [31:0] exmem_alu_out;
logic exmem_bp_br_en;

//logic [7:0] data [2][3] = '{'{8'b00000100, 8'b00000010, 8'b00000100},
//							'{8'b00000010, 8'b00000000, 8'b11111111}};

always begin : CLOCK_GENERATION
    #10000;
    clk = ~clk;
end

initial begin
    clk = 0;
    rst = 1;
    @(posedge clk);
    rst = 0;

    @(posedge clk);

    // wrong pred test
    if_pc = 32'h00000050;
    exmem_pc = 32'h0000005c;
    exmem_br_en = 1'b1;
    exmem_bp_br_en = 1'b0;
    exmem_bp_target = 32'hDEADBEEF;
    exmem_alu_out = 32'hDEADBEEF;
    exmem_opcode = rv32i_types::op_br;
    exmem_y_out = 8'b1;

    @(posedge clk);

    // right pred, wrong target test (no training)
    if_pc = 32'h00000054;
    exmem_pc = 32'h00000060;
    exmem_br_en = 1'b1;
    exmem_bp_br_en = 1'b1;
    exmem_bp_target = 32'hDEADBEEF;
    exmem_alu_out = 32'hDEADA55B;
    exmem_opcode = rv32i_types::op_br;
    exmem_y_out = 8'h41;

    @(posedge clk);

    // right pred, right target (no training)
    if_pc = 32'h00000058;
    exmem_pc = 32'h00000064;
    exmem_br_en = 1'b1;
    exmem_bp_br_en = 1'b1;
    exmem_bp_target = 32'hDEADBEEF;
    exmem_alu_out = 32'hDEADBEEF;
    exmem_opcode = rv32i_types::op_br;
    exmem_y_out = 8'h41;

    @(posedge clk);

    // right pred, right target (training)
    if_pc = 32'h0000005c;
    exmem_pc = 32'h00000068;
    exmem_br_en = 1'b1;
    exmem_bp_br_en = 1'b1;
    exmem_bp_target = 32'hDEADBEEF;
    exmem_alu_out = 32'hDEADBEEF;
    exmem_opcode = rv32i_types::op_br;
    exmem_y_out = 8'hF6;

    @(posedge clk);

    // btb hit (correct prediction, wrong target)
    if_pc = 32'h00000050;
    exmem_pc = 32'h0000005c;
    exmem_br_en = 1'b1;
    exmem_bp_br_en = 1'b1;
    exmem_bp_target = 32'hDEADBEEF;
    exmem_alu_out = 32'hDEADA55B;
    exmem_opcode = rv32i_types::op_br;
    exmem_y_out = 8'h42;

    @(posedge clk);
    #5000;

    $display("%1b", $signed(3'b111) > 0);
	$finish;
end

// dut
pbp #(.w_bits(8), .hist_len(12)) pbp(.*);

endmodule 