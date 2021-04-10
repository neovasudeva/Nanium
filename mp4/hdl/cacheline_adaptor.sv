module cacheline_adaptor
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);

// enums for state machine
enum {WAIT, PREP_READ, READ0, READ1, READ2, READ3, PREP_WRITE, WRITE0, WRITE1, WRITE2, WRITE3, READY} state, next_state;

// send address
assign address_o = address_i;

// logic to contain data burst (READ)
logic [255:0] read_word;
assign line_o = read_word;


always @(posedge clk) begin
	// reset asserted
	if (~reset_n) begin
		read_word <= 256'h0;
		state <= WAIT;
	end
	
	// DATA MUST BE UPDATED ON CLOCK CYCLE
	else begin
		state = next_state;
		case (state) 
			READ0:
				if (resp_i)
					read_word[63:0] <= burst_i;
			READ1:
				if (resp_i) 
					read_word[127:64] <= burst_i;
			READ2:
				if (resp_i) 
					read_word[191:128] <= burst_i;
			READ3:
				if (resp_i) 
					read_word[255:192] = burst_i;
			WRITE0:
				//if (resp_i) 
					burst_o <= line_i[63:0];
			WRITE1:
				if (resp_i) 
					burst_o <= line_i[127:64];
			WRITE2:
				if (resp_i) 
					burst_o <= line_i[191:128];
			WRITE3:
				if (resp_i) 
					burst_o <= line_i[255:192];
		endcase
	end
end


// next state logic
always_comb begin 
	next_state = state;
	case (state)
		WAIT: begin
			if (read_i) 
				next_state = PREP_READ;
			else if (write_i)
				next_state = WRITE0; //PREP_WRITE;
		end
		PREP_READ:
			if (resp_i)
				next_state = READ0;
		/*
		PREP_WRITE:
			if (resp_i)
				next_state = WRITE0;*/
		READ0: 
			next_state = READ1;
		READ1:
			next_state = READ2;
		READ2:
			next_state = READ3;
		READ3:
			next_state = READY;
		WRITE0:
			if (resp_i)
				next_state = WRITE1;
		WRITE1:
			next_state = WRITE2;
		WRITE2:
			next_state = WRITE3;
		WRITE3:
			next_state = READY;
		READY:
			next_state = WAIT;
	endcase
end

// state output logic
always_comb begin
	// default signals
	read_o = 1'b0;
	write_o = 1'b0;
	resp_o = 1'b0;
	
	// actual outputs
	case (state)
		PREP_READ:
			read_o = 1'b1;
		READ0, READ1, READ2://, READ3: 
			read_o = 1'b1;
		/*
		PREP_WRITE:
			write_o = 1'b1;*/
		WRITE0, WRITE1, WRITE2, WRITE3:
			write_o = 1'b1;
		READY: 
			resp_o = 1'b1;
	endcase
end

endmodule : cacheline_adaptor
