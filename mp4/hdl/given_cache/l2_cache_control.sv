import rv32i_types::*;
import pmem_addr_mux::*;
import data_in_mux::*;
import data_write_en_mux::*;

module l2_cache_control (
    input clk,
    input rst,

    input rv32i_word mem_address,
    output logic mem_resp,
    input logic mem_read,
    input logic mem_write,

    input pmem_resp,
    output logic pmem_read,
    output logic pmem_write,

    input logic [23:0] way_out[8],
    input logic [7:0] valid_out,
    input logic [7:0] dirty_out,
    input logic [2:0] plru,
    output logic [7:0] way_load,
    output logic [7:0] valid_load,
    output logic [7:0] valid_in,
    output logic [7:0] dirty_load,
    output logic [7:0] dirty_in,
    output logic lru_load,
    output logic [2:0] mru,
	
	input logic hit,
    input [7:0] way_hit,

    output logic [2:0] way_sel,
    output pmem_addr_mux_sel_t pmem_address_sel,
    output data_in_mux_sel_t way_data_in_sel,
    output data_write_en_mux_sel_t way_write_en_sel[8]
);

int miss_count, miss_count_next;
int tot_count, tot_count_next;

enum int unsigned {
    /* List of states */
    IDLE,
    COMPARE_TAG,
    ALLOCATE,
    WRITE_BACK
} state, next_state;

function void set_defaults();
    mem_resp = 1'b0;
    pmem_read = 1'b0;
    pmem_write = 1'b0;
	way_load = '0;
	valid_load = '0;
	valid_in = '0;
    dirty_load = '0;
    dirty_in = '0;
    way_write_en_sel[0] = data_write_en_mux::idle;
	way_write_en_sel[1] = data_write_en_mux::idle;
	way_write_en_sel[2] = data_write_en_mux::idle;
	way_write_en_sel[3] = data_write_en_mux::idle;
	way_write_en_sel[4] = data_write_en_mux::idle;
	way_write_en_sel[5] = data_write_en_mux::idle;
	way_write_en_sel[6] = data_write_en_mux::idle;
	way_write_en_sel[7] = data_write_en_mux::idle;
//    for (logic [3:0] i = 0; i < 4'd8; i++) begin
//        way_load[i] = 1'b0;
//        valid_load[i] = 1'b0;
//        valid_in[i] = 1'b0;
//        dirty_load[i] = 1'b0;
//        dirty_in[i] = 1'b0;
//        way_write_en_sel[i] = data_write_en_mux::idle;
//    end
	way_data_in_sel = data_in_mux::cacheline_adaptor;
    lru_load = 1'b0;
    mru = 3'd0;
    way_sel = 3'd0;
    pmem_address_sel = pmem_addr_mux::cpu;
endfunction

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    unique case (state)
        COMPARE_TAG: begin
            if (hit) begin
                lru_load = 1'b1;
                mem_resp = 1'b1;
//                for (logic [3:0] i = 0; i < 4'd8; i++) begin
//                    if (way_hit[i]) begin
//                        mru = i[2:0];
//                        if (mem_write) begin
//                            dirty_load[i] = 1'b1;
//                            dirty_in[i] = 1'b1;
//                            way_write_en_sel[i] = data_write_en_mux::load_mem;
//                            way_data_in_sel = data_in_mux::bus_adaptor;
//                        end else begin
//                            way_sel = i[2:0];
//                        end
//                        break;
//                    end
//                end
				unique case (way_hit)
					8'b00000001: begin
						mru = 3'd0;
                        if (mem_write) begin
                            dirty_load[0] = 1'b1;
                            dirty_in[0] = 1'b1;
                            way_write_en_sel[0] = data_write_en_mux::load_mem;
                            way_data_in_sel = data_in_mux::bus_adaptor;
                        end else begin
                            way_sel = 3'd0;
                        end
					end
					8'b00000010: begin
						mru = 3'd1;
                        if (mem_write) begin
                            dirty_load[1] = 1'b1;
                            dirty_in[1] = 1'b1;
                            way_write_en_sel[1] = data_write_en_mux::load_mem;
                            way_data_in_sel = data_in_mux::bus_adaptor;
                        end else begin
                            way_sel = 3'd1;
                        end
					end
					8'b00000100: begin
						mru = 3'd2;
                        if (mem_write) begin
                            dirty_load[2] = 1'b1;
                            dirty_in[2] = 1'b1;
                            way_write_en_sel[2] = data_write_en_mux::load_mem;
                            way_data_in_sel = data_in_mux::bus_adaptor;
                        end else begin
                            way_sel = 3'd2;
                        end
					end
					8'b00001000: begin
						mru = 3'd3;
                        if (mem_write) begin
                            dirty_load[3] = 1'b1;
                            dirty_in[3] = 1'b1;
                            way_write_en_sel[3] = data_write_en_mux::load_mem;
                            way_data_in_sel = data_in_mux::bus_adaptor;
                        end else begin
                            way_sel = 3'd3;
                        end
					end
					8'b00010000: begin
						mru = 3'd4;
                        if (mem_write) begin
                            dirty_load[4] = 1'b1;
                            dirty_in[4] = 1'b1;
                            way_write_en_sel[4] = data_write_en_mux::load_mem;
                            way_data_in_sel = data_in_mux::bus_adaptor;
                        end else begin
                            way_sel = 3'd4;
                        end
					end
					8'b00100000: begin
						mru = 3'd5;
                        if (mem_write) begin
                            dirty_load[5] = 1'b1;
                            dirty_in[5] = 1'b1;
                            way_write_en_sel[5] = data_write_en_mux::load_mem;
                            way_data_in_sel = data_in_mux::bus_adaptor;
                        end else begin
                            way_sel = 3'd5;
                        end
					end
					8'b01000000: begin
						mru = 3'd6;
                        if (mem_write) begin
                            dirty_load[6] = 1'b1;
                            dirty_in[6] = 1'b1;
                            way_write_en_sel[6] = data_write_en_mux::load_mem;
                            way_data_in_sel = data_in_mux::bus_adaptor;
                        end else begin
                            way_sel = 3'd6;
                        end
					end
					8'b10000000: begin
						mru = 3'd7;
                        if (mem_write) begin
                            dirty_load[7] = 1'b1;
                            dirty_in[7] = 1'b1;
                            way_write_en_sel[7] = data_write_en_mux::load_mem;
                            way_data_in_sel = data_in_mux::bus_adaptor;
                        end else begin
                            way_sel = 3'd7;
                        end
					end
					default: ;
				endcase
            end
        end
        ALLOCATE: begin
            pmem_read = 1'b1;
            pmem_address_sel = pmem_addr_mux::cpu;
            way_data_in_sel = data_in_mux::cacheline_adaptor;
            way_load[plru] = 1'b1;
            valid_load[plru] = 1'b1;
            valid_in[plru] = 1'b1;
            dirty_load[plru] = 1'b1;
            dirty_in[plru] = 1'b0;
            way_write_en_sel[plru] = data_write_en_mux::load_mem;
        end
        WRITE_BACK: begin
            pmem_write = 1'b1;
            way_sel = plru;
            unique case (plru)
                3'd0: begin
                    pmem_address_sel = pmem_addr_mux::dirty_0_write;
                end
                3'd1: begin
                    pmem_address_sel = pmem_addr_mux::dirty_1_write;
                end
                3'd2: begin
                    pmem_address_sel = pmem_addr_mux::dirty_2_write;
                end
                3'd3: begin
                    pmem_address_sel = pmem_addr_mux::dirty_3_write;
                end
                3'd4: begin
                    pmem_address_sel = pmem_addr_mux::dirty_4_write;
                end
                3'd5: begin
                    pmem_address_sel = pmem_addr_mux::dirty_5_write;
                end
                3'd6: begin
                    pmem_address_sel = pmem_addr_mux::dirty_6_write;
                end
                3'd7: begin
                    pmem_address_sel = pmem_addr_mux::dirty_7_write;
                end
                default: ;
            endcase
        end
        default: ;
    endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
     next_state = state;
	 
	 miss_count_next = miss_count;
	 tot_count_next = tot_count;
	 
     unique case (state)
        IDLE: begin
            if (mem_read | mem_write) begin
                next_state = COMPARE_TAG;
				tot_count_next = tot_count + 1;
            end
        end
        COMPARE_TAG: begin
            if (hit) begin
                next_state = IDLE;
            end
            else if (~dirty_out[plru]) begin
                next_state = ALLOCATE;
				miss_count_next = miss_count + 1;
            end
            else begin
                next_state = WRITE_BACK;
				miss_count_next = miss_count + 1;
            end
        end
        ALLOCATE: begin
            if (pmem_resp) begin
                next_state = COMPARE_TAG;
            end
		end
        WRITE_BACK: begin
            if (pmem_resp) begin
                next_state = ALLOCATE;
            end
        end
        default: ;
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    if (rst) state <= IDLE;
    else state <= next_state;
	
	miss_count <= rst ? 0 : miss_count_next;
	tot_count <= rst ? 0 : tot_count_next;
end

endmodule : l2_cache_control
