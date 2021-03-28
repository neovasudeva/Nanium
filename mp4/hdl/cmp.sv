`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)

import rv32i_types::*;

module cmp (
	input branch_funct3_t cmpop,
	input rv32i_word a, b,
	output logic br_en
);

always_comb begin
	unique case (cmpop) 
		rv32i_types::beq:	br_en = (a == b);
		rv32i_types::bne:	br_en = (a != b);
		rv32i_types::blt:	br_en = ($signed(a) < $signed(b));	//signed
		rv32i_types::bge:	br_en = ($signed(a) >= $signed(b));
		rv32i_types::bltu:	br_en = (a < b);					//unsigned
		rv32i_types::bgeu:	br_en = (a >= b);
		default: `BAD_MUX_SEL;
	endcase
end
	
endmodule : cmp	