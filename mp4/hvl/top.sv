module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// For local simulation, add signal for Modelsim to display by default
// Note that this signal does nothing and is not used for anything
bit f;

/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP2

//assign rvfi.commit = 0; // Set high when a valid instruction is modifying regfile or PC
assign rvfi.halt = (rvfi.pc_wdata == rvfi.pc_rdata) & rvfi.pc_rdata != '0; // Set high when you detect an infinite loop
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO

/*
The following signals need to be set:
Instruction and trap:
    rvfi.inst
    rvfi.trap

Regfile:
    rvfi.rs1_addr
    rvfi.rs2_addr
    rvfi.rs1_rdata
    rvfi.rs2_rdata
    rvfi.load_regfile
    rvfi.rd_addr
    rvfi.rd_wdata

PC:
    rvfi.pc_rdata
    rvfi.pc_wdata

Memory:
    rvfi.mem_addr
    rvfi.mem_rmask
    rvfi.mem_wmask
    rvfi.mem_rdata
    rvfi.mem_wdata

Please refer to rvfi_itf.sv for more information.
*/

logic [31:0] exmem_rs1_rdata;
logic [31:0] memwb_rs1_rdata;
logic [31:0] memwb_rs2_rdata;
logic [31:0] memwb_mem_addr;
logic [4:0] memwb_mem_rmask;
logic [4:0] memwb_mem_wmask;
logic [31:0] memwb_mem_rdata;
logic [31:0] memwb_mem_wdata;
logic branch_rst_delay;
logic forward_stall_delay;

assign stall = dut.datapath.forward_stall || dut.datapath.cache_stall;

always_ff @(posedge itf.clk) begin
	// move forward only on no stall
	if (~stall) begin
		// rs1 and rs2 data
		exmem_rs1_rdata <= dut.datapath.ex_stage.rs1mux_out;
		
		// branch delay
		branch_rst_delay <= dut.datapath.branch_rst;
	end
	
	// move down only on no cache stall (memwb is always loaded even on forward stall)
	if (~dut.datapath.cache_stall) begin
		forward_stall_delay <= dut.datapath.forward_stall;
		
		// rs1 and rs2 data
		memwb_rs1_rdata <= exmem_rs1_rdata;
		memwb_rs2_rdata <= dut.datapath.mem_stage.dcacheforwardmux_out;
		
		// mem addr/rmask/wmask/wdata/rdata
		memwb_mem_addr <= dut.dcache_addr;
		memwb_mem_rmask <= dut.datapath.exmem_ctrl_word.dcache_read ? dut.dcache_byte_enable : 4'b0;
		memwb_mem_wmask <= dut.datapath.exmem_ctrl_word.dcache_write ? dut.dcache_byte_enable : 4'b0;
		memwb_mem_rdata <= dut.dcache_rdata;
		memwb_mem_wdata <= dut.dcache_wdata;
	end
end

assign rvfi.commit = ~dut.datapath.cache_stall && dut.datapath.memwb_instruction.opcode != 7'b0;
assign rvfi.inst = {dut.datapath.memwb_instruction.u_imm[31:12], dut.datapath.memwb_instruction.rd, dut.datapath.memwb_instruction.opcode};
assign rvfi.trap = dut.datapath.memwb_instruction.opcode == 7'b0; //1'b0; 
assign rvfi.rs1_addr = dut.datapath.memwb_instruction.rs1;
assign rvfi.rs2_addr = dut.datapath.memwb_instruction.rs2;
assign rvfi.rs1_rdata = memwb_rs1_rdata;
assign rvfi.rs2_rdata = memwb_rs2_rdata;
assign rvfi.load_regfile = dut.datapath.memwb_ctrl_word.load_regfile;
assign rvfi.rd_addr = dut.datapath.memwb_instruction.rd;
assign rvfi.rd_wdata = rvfi.rd_addr == 5'b0 ? 32'b0 : dut.datapath.wb_regfilemux_out;
assign rvfi.pc_rdata = dut.datapath.memwb_pc;
assign rvfi.pc_wdata = branch_rst_delay ? dut.datapath.if_pc : (forward_stall_delay ? dut.datapath.idex_pc : dut.datapath.exmem_pc);   
assign rvfi.mem_addr = memwb_mem_addr;
assign rvfi.mem_rmask = memwb_mem_rmask;
assign rvfi.mem_wmask = memwb_mem_wmask;
assign rvfi.mem_rdata = memwb_mem_rdata;
assign rvfi.mem_wdata = memwb_mem_wdata;

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/
/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = dut.datapath.id_stage.regfile.data; 

/* perf counters */
assign itf.br_wrong = dut.datapath.br_wrong;
assign itf.br_total = dut.datapath.br_total;
		   
/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level:
Clock and reset signals:
    itf.clk
    itf.rst

Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

mp4 dut(
    .clk(itf.clk),
    .rst(itf.rst),

    .pmem_read(itf.mem_read),
	.pmem_write(itf.mem_write),
	.pmem_address(itf.mem_addr),
	.pmem_wdata(itf.mem_wdata),
	.pmem_rdata(itf.mem_rdata),
	.pmem_resp(itf.mem_resp)
);

/***************************** End Instantiation *****************************/

endmodule
