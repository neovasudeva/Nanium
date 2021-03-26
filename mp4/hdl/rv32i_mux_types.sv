package pcmux;
typedef enum bit [1:0] {
    pc_plus4  = 2'b00
    ,alu_out  = 2'b01
    ,alu_mod2 = 2'b10
} pcmux_sel_t;
endpackage

package marmux;
typedef enum bit {
    pc_out = 1'b0
    ,alu_out = 1'b1
} marmux_sel_t;
endpackage

package cmpmux;
typedef enum bit {
    rs2_out = 1'b0
    ,i_imm = 1'b1
} cmpmux_sel_t;
endpackage

package alumux;
typedef enum bit {
    rs1_out = 1'b0
    ,pc_out = 1'b1
} alumux1_sel_t;

typedef enum bit [2:0] {
    i_imm    = 3'b000
    ,u_imm   = 3'b001
    ,b_imm   = 3'b010
    ,s_imm   = 3'b011
    ,j_imm   = 3'b100
    ,rs2_out = 3'b101
} alumux2_sel_t;
endpackage

package regfilemux;
typedef enum bit [1:0] {
    alu_out   = 4'b0000
    ,br_en    = 4'b0001
    ,u_imm    = 4'b0010
    ,rdata    = 4'b0011
} regfilemux_sel_t;
endpackage

/* dcache_rdata mux for lb, lbu, lh, lhu, lw */
package dcachemux;
typedef enum bit [2:0] {
	lb	= 3'b000,
	lbu	= 3'b001,
	lh	= 3'b010,
	lhu = 3'b011,
	lw	= 3'b100
} rdata_sel_t;
endpackage

/* FOR FORWARDING
package rs1mux;
typedef enum bit [...] {
	...
} rs1mux_sel_t;
endpackage

package rs2mux;
typedef enum bit [...] {
	...
} rs2mux_sel_t;
endpackage

package dcachemux;
typedef enum bit [...] {
	...
} dcachemux_sel_t;
endpackage
*/