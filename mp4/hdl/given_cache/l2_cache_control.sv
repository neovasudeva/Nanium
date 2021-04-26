import rv32i_types::*;
import cache_out_mux::*;
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

    input logic [23:0] way_out[2],
    input logic [1:0] valid_out,
    input logic [1:0] dirty_out,
    input logic plru,
    output logic [1:0] way_load,
    output logic [1:0] valid_load,
    output logic [1:0] valid_in,
    output logic [1:0] dirty_load,
    output logic [1:0] dirty_in,
    output logic lru_load,
    output logic mru,
	
	input logic hit,
    input [1:0] way_hit,

    output cache_out_mux_sel_t way_sel,
    output pmem_addr_mux_sel_t pmem_address_sel,
    output data_in_mux_sel_t way_data_in_sel[2],
    output data_write_en_mux_sel_t way_write_en_sel[2]
);

logic lru_out;
assign lru_out = decode_plru(plru);

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
    way_load[0] = 1'b0;
    way_load[1] = 1'b0;
    valid_load[0] = 1'b0;
    valid_load[1] = 1'b0;
    valid_in[0] = 1'b0;
    valid_in[1] = 1'b0;
    dirty_load[0] = 1'b0;
    dirty_load[1] = 1'b0;
    dirty_in[0] = 1'b0;
    dirty_in[1] = 1'b0;
    lru_load = 1'b0;
    mru = 1'b0;
    way_sel = cache_out_mux::way_0;
    pmem_address_sel = pmem_addr_mux::cpu;
    way_data_in_sel[0] = data_in_mux::cacheline_adaptor;
    way_data_in_sel[1] = data_in_mux::cacheline_adaptor;
    way_write_en_sel[0] = data_write_en_mux::idle;
    way_write_en_sel[1] = data_write_en_mux::idle;
endfunction

function logic decode_plru(logic plru);
    if (plru) begin
        return 1'd0;
    end else begin
        return 1'd1;
    end
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
                if (way_hit[0]) begin
                    mru = 1'b0;
                    if (mem_write) begin
                        dirty_load[0] = 1'b1;
                        dirty_in[0] = 1'b1;
                        way_write_en_sel[0] = data_write_en_mux::cpu_write;
                        way_data_in_sel[0] = data_in_mux::bus_adaptor;
                        way_data_in_sel[1] = data_in_mux::bus_adaptor;
                    end else begin
                        way_sel = cache_out_mux::way_0;
                    end
                end else begin
                    mru = 1'b1;
                    if (mem_write) begin
                        dirty_load[1] = 1'b1;
                        dirty_in[1] = 1'b1;
                        way_write_en_sel[1] = data_write_en_mux::cpu_write;
                        way_data_in_sel[0] = data_in_mux::bus_adaptor;
                        way_data_in_sel[1] = data_in_mux::bus_adaptor;
                    end else begin
                        way_sel = cache_out_mux::way_1;
                    end
                end
            end
        end
        ALLOCATE: begin
            pmem_read = 1'b1;
            pmem_address_sel = pmem_addr_mux::cpu;
            way_data_in_sel[0] = data_in_mux::cacheline_adaptor;
            way_data_in_sel[1] = data_in_mux::cacheline_adaptor;
            way_load[lru_out] = 1'b1;
            valid_load[lru_out] = 1'b1;
            valid_in[lru_out] = 1'b1;
            dirty_load[lru_out] = 1'b1;
            dirty_in[lru_out] = 1'b0;
            way_write_en_sel[lru_out] = data_write_en_mux::load_mem;
        end
        WRITE_BACK: begin
            pmem_write = 1'b1;
            unique case (lru_out)
                0: begin
                    way_sel = cache_out_mux::way_0;
                    pmem_address_sel = pmem_addr_mux::dirty_0_write;
                end
                1: begin
                    way_sel = cache_out_mux::way_1;
                    pmem_address_sel = pmem_addr_mux::dirty_1_write;
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
     unique case (state)
        IDLE: begin
            if (mem_read | mem_write) begin
                next_state = COMPARE_TAG;
            end
        end
        COMPARE_TAG: begin
            if (hit) begin
                next_state = IDLE;
            end
            else if (~dirty_out[lru_out]) begin
                next_state = ALLOCATE;
            end
            else begin
                next_state = WRITE_BACK;
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
end

endmodule : l2_cache_control
