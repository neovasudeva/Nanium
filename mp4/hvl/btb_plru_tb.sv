module btb_plru_tb ();
`timescale 1ns/10ps

logic clk;
logic rst;
logic read;                     
logic load;
logic [2:0] r_index;  
logic [2:0] w_index;  
logic [1:0] r_mru;              
logic [1:0] plru;       

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
    // plru = 2'b11;
    // data[0] = 3'b101;
    // data[7] = 3'b101;
    read = 1'b1;
    load = 1'b1;
    r_index = 3'b000;   // set 0
    w_index = 3'b111;   // set 7
    r_mru = 2'b11;      // way 3

    @(posedge clk);

    // same set, same way
    // plru = 2'b11;
    // data[1] = 3'b101;
    read = 1'b1;
    load = 1'b1;
    r_index = 3'b001;
    w_index = 3'b001;
    r_mru = 2'b11;      // way 3

    @(posedge clk);

    // same set, different way
    // plru = 2'b11;
    // data[2] = 3'b101;
    read = 1'b1;
    load = 1'b1;
    r_index = 3'b010;
    w_index = 3'b010;
    r_mru = 2'b00;      // way 0

    @(posedge clk);

    // btb miss
    // data[2] should NOT be 3'b111, should be 3'b101
    read = 1'b0;
    load = 1'b0;
    r_index = 3'b010;
    w_index = 3'b010;
    r_mru = 2'b00;      //way 0

    @(posedge clk);
    #5000;

    $finish;
end

// dut
btb_plru btb_plru(.*);

endmodule 