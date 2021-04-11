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

assign rvfi.commit = 0; // Set high when a valid instruction is modifying regfile or PC
assign rvfi.halt = (dut.datapath.memwb_br_en == 1'b1 
	&& dut.datapath.memwb_instruction.opcode == 7'b1100011
	&& dut.datapath.memwb_alu_out == dut.datapath.memwb_pc);   // Set high when you detect an infinite loop
initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO

/*
The following signals need to be set:
Instruction and trap:
    rvfi.inst
    rvfi.trap

Regfile:
    rvfi.rs1_addr
    rvfi.rs2_add
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
//assign itf.inst_read = dut.icache_read;
//assign itf.inst_addr = dut.icache_addr;
//assign itf.inst_resp = dut.icache_resp;
//assign itf.inst_rdata = dut.icache_rdata;
//
//assign itf.data_read = dut.dcache_read;
//assign itf.data_write = dut.dcache_write;
//assign itf.data_mbe = dut.dcache_byte_enable;
//assign itf.data_addr = dut.dcache_addr;
//assign itf.data_wdata = dut.dcache_wdata;
//assign itf.data_resp = dut.dcache_resp;
//assign itf.data_rdata = dut.dcache_rdata;


/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = dut.datapath.idecode.regfile.data; 


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
