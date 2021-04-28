module btb_tb ();
`timescale 1ns/10ps

logic clk;
logic rst;
logic [31:0] r_pc;
logic [31:0] target_out;
logic [31:0] w_pc;
logic load;
logic [31:0] target_in;
logic btb_hit;

always begin : CLOCK_GENERATION
    #10000;
    clk = ~clk;
end

initial begin
    clk = 0;
    rst = 1;
    @(posedge clk);
    rst = 0;

    @(posedge clk);

    // different set, different way
    // set 4, way 4 = 600d600d
    r_pc = 32'h0000001D;    // set 7
    w_pc = 32'h00000010;    // set 4
    load = 1'b1;
    target_in = 32'h600d600d;

    @(posedge clk);

    // same set, same way
    // set 3, way 4 = deadbeef
    // target_out = deadbeef
    // plru = 3'b101
    r_pc = 32'h0000002D;    // set 3
    w_pc = 32'h0000002D;    // set 3
    load = 1'b1;
    target_in = 32'hdeadbeef;

    @(posedge clk);

    // same set, different way
    // set 3, way 1 = feebfeeb 
    // target out = deadbeef
    // plru = 3'b011
    r_pc = 32'h0000002D;    // set 3
    w_pc = 32'h1000002D;    // set 3
    load = 1'b1;
    target_in = 32'hfeebfeeb;

    @(posedge clk);

    // write to existing tag
    // set 3 way 1 = 00badbad
    r_pc = 32'h0000002D;    // set 3
    w_pc = 32'h1000002D;    // set 3
    load = 1'b1;
    target_in = 32'h00badbad;

    @(posedge clk);
    #5000;

    $finish;
end

// dut
btb btb(.*);

endmodule 