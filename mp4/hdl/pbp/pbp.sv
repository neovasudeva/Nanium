import rv32i_types::*;

module pbp #(
    parameter w_bits = 8,
    parameter hist_len = 12
)
(
    input clk,
    input rst,
    
    /* inputs/outputs in IF stage */
    input rv32i_word if_pc,
    output logic if_bp_br_en,
    output logic [w_bits-1:0] if_y_out,
    output rv32i_word if_bp_target,
    output logic btb_hit,
    output logic bp_rst,

    /* inputs/outputs in EX/MEM regs */
    input rv32i_word exmem_pc,
    input logic exmem_br_en,
    input rv32i_types::opcode_t exmem_opcode,
    input rv32i_word exmem_alu_out,
	input logic exmem_bp_br_en,
	input logic [w_bits-1:0] exmem_y_out,
    input rv32i_word exmem_bp_target
);

/********************************** SIGNALS **********************************/ 
// perceptrons (note + 1 for bias weight)
logic [w_bits-1:0] perc1_out [hist_len + 1];
logic [w_bits-1:0] perc2_out [hist_len + 1];
logic [w_bits-1:0] perc2_in [hist_len + 1];
logic [w_bits-1:0] perc1_hist_prod [hist_len + 1]; 

// write enable signals for ghr and ptable
logic pt_wr_en;
logic ghr_wr_en;
logic [hist_len-1:0] global_history;

// absolute value of exmem_y_out
logic [w_bits-1:0] abs_exmem_y_out; 
assign abs_exmem_y_out = $signed(exmem_y_out) >= 0 ? exmem_y_out : (exmem_y_out ^ {w_bits{1'b1}}) + 8'b1;

// btb
rv32i_word btb_out;
/*****************************************************************************/

/******************************* LOGICAL UNITS *******************************/ 
// perceptron table
ptable #(.w_bits(w_bits), .hist_len(hist_len)) perceptron_table (
    .clk        (clk),
    .rst        (rst),
    .r1_index   (if_pc[5:2]),
    .perc1_out  (perc1_out),
    .r2_index   (exmem_pc[5:2]),
    .perc2_out  (perc2_out),
    .wr_en      (pt_wr_en),
    .perc2_in   (perc2_in)
);

// global history reg
shift_reg #(.width(hist_len)) ghr (
    .clk    (clk), 
    .rst    (rst),
    .load   (ghr_wr_en),
    .in     (exmem_br_en),
    .out    (global_history)
);
/*****************************************************************************/

/********************************** LOGIC ************************************/ 
// training logic
always_comb begin : TRAINING_LOGIC
    if (exmem_opcode == rv32i_types::op_br) begin
        // correct pred
        if (exmem_bp_br_en == exmem_br_en) begin
            if (abs_exmem_y_out < 37)
                pt_wr_en = 1'b1;
            else
                pt_wr_en = 1'b0;
        end

        // incorrect pred
        else 
            pt_wr_en = 1'b1;
    end
    else
        pt_wr_en = 1'b0;
end

// bp_rst logic
always_comb begin : BP_RST_LOGIC
    if (exmem_opcode == rv32i_types::op_br) begin
		// correct pred
		if (exmem_bp_br_en == exmem_br_en) begin
			if (exmem_br_en == 1'b0 || (exmem_br_en == 1'b1 && exmem_alu_out == exmem_bp_target))
				bp_rst = 1'b0;
			else
				bp_rst = 1'b1;
		end
		
		// incorrect pred
		else 
			bp_rst = 1'b1;
	end
	else 
		bp_rst = 1'b0;
end

// ghr_wr_en logic 
always_comb begin : GHR_WR_EN_LOGIC
    if (exmem_opcode == rv32i_types::op_br)
        ghr_wr_en = 1'b1;
    else
        ghr_wr_en = 1'b0;
end
/*****************************************************************************/

/******************************** EVALUATION *********************************/ 
// calculate dot product
always_comb begin
    for (int i = 0; i < hist_len; i++)
        perc1_hist_prod[i] = (global_history[i] == 1'b1) ? perc1_out[i] : (perc1_out[i] ^ {w_bits{1'b1}});
    
    perc1_hist_prod[hist_len] = perc1_out[hist_len];
end

assign if_y_out = perc1_hist_prod.sum();
assign if_bp_br_en = $signed(if_y_out) > 0 ? 1'b1 : 1'b0;
/*****************************************************************************/

/********************************* TRAINING **********************************/ 
// set new weights in perc2_in (train on perc2_out and ghr)
always_comb begin
    for (int i = 0; i < hist_len; i++)
        perc2_in[i] = perc2_out[i] + (exmem_br_en == global_history[i] ? 8'h01 : 8'hFF);
    
    perc2_in[hist_len] = perc2_out[hist_len] + (exmem_br_en == 1'b1 ? 8'h01 : 8'hFF);
end
/*****************************************************************************/


/***************************** TARGET CALCULATION ****************************/ 
// BTB
btb #(.width(32)) btb (
    .clk        (clk),
    .rst        (rst),
    .r_pc       (if_pc),
    .target_out (btb_out),
    .w_pc       (exmem_pc),
    .load       (exmem_opcode == rv32i_types::op_br),
    .target_in  (exmem_alu_out), 
    .btb_hit    (btb_hit)
);

// bp_target calculation
assign if_bp_target = (if_bp_br_en && btb_hit) ? btb_out : if_pc + 4;
/*****************************************************************************/
endmodule : pbp