module l2_cache_control (
    input clk,
    input rst,

    output logic mem_resp,
    input logic mem_read,
    input logic mem_write,

    input pmem_resp,
    output logic pmem_read,
    output logic pmem_write,

    input logic [7:0] valid_out,
    input logic [7:0] dirty_out,
    input logic [2:0] plru,
    output logic [7:0] tag_load,
    output logic valid_load,
    output logic [7:0] valid_in,
    output logic dirty_load,
    output logic [7:0] dirty_in,
    output logic lru_load,
    output logic [2:0] mru,

    input logic [7:0] way_hit,

    output logic [2:0] way_sel, 
    output logic way_data_in_sel,
    output logic [7:0] data_write_en
);

int miss_count, miss_count_next;
int tot_count, tot_count_next;

logic [2:0] prev_plru;
always_ff @(posedge clk)
begin
    if (lru_load) prev_plru <= plru;

    miss_count <= rst ? 0 : miss_count_next;
	tot_count <= rst ? 0 : tot_count_next;
end

logic [2:0] way_hit_num;
always_comb begin : decode_way_hit
    case(way_hit)
        8'b00000001: way_hit_num = 3'b000;
        8'b00000010: way_hit_num = 3'b001;
        8'b00000100: way_hit_num = 3'b010;
        8'b00001000: way_hit_num = 3'b011;
        8'b00010000: way_hit_num = 3'b100;
        8'b00100000: way_hit_num = 3'b101;
        8'b01000000: way_hit_num = 3'b110;
        8'b10000000: way_hit_num = 3'b111;
        default: way_hit_num = 3'bxxx;
    endcase
end

enum int unsigned {
    /* List of states */
    IDLE,
    COMPARE_TAG,
    WRITE_BACK, 
    ALLOCATE_1, 
    ALLOCATE_2,
    ALLOCATE_3
} state, next_state;

function void set_defaults();
    mem_resp = 1'b0;
	pmem_read = 1'b0;
	pmem_write = 1'b0;
    tag_load = '0;
    valid_load = 1'b0;
    valid_in = valid_out;
    dirty_load = 1'b0;
    dirty_in = dirty_out;
    data_write_en = '0;
    way_data_in_sel = 1'b0;
    lru_load = 1'b0;
    mru = way_hit_num;
    way_sel = way_hit_num;
endfunction

always_comb
begin : state_actions
    /* Default output assignments */
    set_defaults();
    /* Actions for each state */
    case(state)
        COMPARE_TAG: begin
            if (mem_read ^ mem_write) begin
                if (way_hit != '0) begin
                    mem_resp = 1'b1;
                    if (mem_write) begin
                        dirty_load = 1'b1;
                        dirty_in[way_hit_num] = 1'b1;
                        data_write_en = way_hit;
                        way_data_in_sel = 1'b1;
                    end
                end
            end
        end

        WRITE_BACK: begin
            pmem_write = 1'b1;
            way_sel = plru;
        end

        ALLOCATE_1: begin
            mru = plru;
            lru_load = 1'b1;
            dirty_in[plru] = mem_write;
            dirty_load = 1'b1;
            valid_in[plru] = 1'b1;
            valid_load = 1'b1;
            tag_load[plru] = 1'b1;
        end

        ALLOCATE_2: begin
            way_data_in_sel = 1'b0;
            data_write_en[prev_plru] = 1'b1;
            pmem_read = 1'b1;
        end

        ALLOCATE_3: begin
            mem_resp = 1'b1;
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

	case(state)
        IDLE: begin
            next_state = COMPARE_TAG;
        end

        COMPARE_TAG: begin
            if (mem_read ^ mem_write) begin
                tot_count_next = tot_count + 1;
                if (way_hit == '0) begin
                    miss_count_next = miss_count + 1;
                    if(dirty_out[plru] & valid_out[plru]) begin
                        next_state = WRITE_BACK;
                    end else begin
                        next_state = ALLOCATE_1;
                    end
                end else begin
					next_state = IDLE;
				end
            end
        end

        WRITE_BACK: begin
            if (pmem_resp) begin
                next_state = ALLOCATE_1;
            end
        end

        ALLOCATE_1: begin
            next_state = ALLOCATE_2;
        end

        ALLOCATE_2: begin
            if (pmem_resp) next_state = ALLOCATE_3;
        end

        ALLOCATE_3: begin
            next_state = IDLE;
        end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    state <= rst? COMPARE_TAG : next_state;
end

endmodule : l2_cache_control
