import rv32i_types::*;
import instr_types::*;
import ctrl_types::*;
import dcachemux::*;

/* 
 * Sends dcache_address, dcache_byte_enable, dcache_read/write, dcache_wdata as outputs to dcache 
 * Receives input data from dcache as dcache_rdata
 */
module mem_stage(
    // input from EX/MEM regs
    input instr_types::instr_t exmem_instruction,
    input ctrl_types::ctrl_t exmem_ctrl_word, 
    input rv32i_word exmem_pc,
    input logic exmem_br_en,
    input rv32i_word exmem_alu_out,
    input rv32i_word exmem_rs2_out,

    // output to dcache
    output logic [3:0] dcache_byte_enable,
    output logic dcache_read,
    output logic dcache_write,
    output rv32i_word dcache_addr,
    output rv32i_word dcache_wdata,

    // input from dcache
    input rv32i_word dcache_rdata,

    // output to MEM/WB Regs
    output rv32i_word mem_rdata
);

// signal for sb and sh
//logic filter_data;

// dcache signals
assign dcache_read = exmem_ctrl_word.dcache_read;
assign dcache_write = exmem_ctrl_word.dcache_write;
assign dcache_addr = {exmem_alu_out[31:2], 2'b0};
assign dcache_wdata = exmem_rs2_out;

/*********************************** SIGNALS *********************************/
rv32i_word lhumux_out;
rv32i_word lhmux_out;
rv32i_word lbumux_out;
rv32i_word lbmux_out;
/*****************************************************************************/

/******************************** READ LOGIC *********************************/
always_comb begin : READ
    // lhu mux
    unique case (exmem_alu_out[1:0])
        2'b00:      lhumux_out = {16'b0, dcache_rdata[15:0]};
        2'b10:      lhumux_out = {16'b0, dcache_rdata[31:16]};
        default:    lhumux_out = {exmem_alu_out[31:2], 2'b0};
    endcase

    // lh mux
    unique case (exmem_alu_out[1:0])
        2'b00:      lhmux_out = {{16{dcache_rdata[15]}}, dcache_rdata[15:0]};
        2'b10:      lhmux_out = {{16{dcache_rdata[31]}}, dcache_rdata[31:16]};
        default:    lhmux_out = {exmem_alu_out[31:2], 2'b0};
    endcase

    // lbu mux
    unique case (exmem_alu_out[1:0])
        2'b00:  lbumux_out = {24'b0, dcache_rdata[7:0]};
        2'b01:  lbumux_out = {24'b0, dcache_rdata[15:8]};    
        2'b10:  lbumux_out = {24'b0, dcache_rdata[23:16]};
        2'b11:  lbumux_out = {24'b0, dcache_rdata[31:24]};
		default: lbumux_out = {exmem_alu_out[31:2], 2'b0};
    endcase

    // lb mux
    unique case (exmem_alu_out[1:0])
        2'b00:  lbmux_out = {{24{dcache_rdata[7]}}, dcache_rdata[7:0]};
        2'b01:  lbmux_out = {{24{dcache_rdata[15]}}, dcache_rdata[15:8]};    
        2'b10:  lbmux_out = {{24{dcache_rdata[23]}}, dcache_rdata[23:16]};
        2'b11:  lbmux_out = {{24{dcache_rdata[31]}}, dcache_rdata[31:24]};
		default: lbmux_out = {exmem_alu_out[31:2], 2'b0};
    endcase

    // rdata
    unique case (exmem_ctrl_word.rdata_sel) 
        dcachemux::lw:     mem_rdata = dcache_rdata;
        dcachemux::lhu:    mem_rdata = lhumux_out; 
        dcachemux::lh:     mem_rdata = lhmux_out;
        dcachemux::lbu:    mem_rdata = lbumux_out;
        dcachemux::lb:     mem_rdata = lbmux_out;
        default:           mem_rdata = dcache_rdata;
    endcase
end
/*****************************************************************************/

/******************************* WRITE LOGIC *********************************/
always_comb begin : WRITE
    if (exmem_instruction.funct3 == rv32i_types::sb) begin
        unique case (exmem_alu_out[1:0]) 
            2'b00:  dcache_byte_enable = 4'b0001; 
            2'b01:  dcache_byte_enable = 4'b0010;
            2'b10:  dcache_byte_enable = 4'b0100;
            2'b11:  dcache_byte_enable = 4'b1000;
			default: dcache_byte_enable = 4'b0000;
        endcase
    end
    else if (exmem_instruction.funct3 == rv32i_types::sh) begin
        unique case (exmem_alu_out[1]) 
            1'b0:   dcache_byte_enable = 4'b0011;
            1'b1:   dcache_byte_enable = 4'b1100;
			default: dcache_byte_enable = 4'b0000;
        endcase
    end
    else 
        dcache_byte_enable = 4'b1111;
	
/*	
	unique case (exmem_instruction.funct3)
		rv32i_types::sb:	filter_data = exmem_rs2_out << (exmem_alu_out[1:0] * 8);
		rv32i_types::sh:	filter_data = exmem_rs2_out << (exmem_alu_out[1] * 16);
		default: 			filter_data = exmem_rs2_out;
	endcase
	*/
end
/*****************************************************************************/

endmodule : mem_stage