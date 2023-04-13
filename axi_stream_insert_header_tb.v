`timescale 1ns / 1ps
`include "./axi_stream_insert_header.v"

module axi_stream_insert_header_tb();

    // Parameters
    localparam DATA_WD = 32;
    localparam DATA_BYTE_WD = DATA_WD / 8;
    localparam BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

    // Signals
    reg clk;
    reg rst_n;

    reg valid_in;
    reg [DATA_WD-1 : 0] data_in;
    reg [DATA_BYTE_WD-1 : 0] keep_in;
    reg last_in;
    wire ready_in;

    wire valid_out;
    wire [DATA_WD-1 : 0] data_out;
    wire [DATA_BYTE_WD-1 : 0] keep_out;
    wire last_out;
    reg ready_out;

    reg valid_insert;
    reg [DATA_WD-1 : 0] data_insert;
    reg [DATA_BYTE_WD-1 : 0] keep_insert;
    reg [BYTE_CNT_WD-1 : 0] byte_insert_cnt;
    wire ready_insert;

    // DUT
    axi_stream_insert_header #(
        .DATA_WD(DATA_WD),
        .DATA_BYTE_WD(DATA_BYTE_WD),
        .BYTE_CNT_WD(BYTE_CNT_WD)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        .keep_in(keep_in),
        .last_in(last_in),
        .ready_in(ready_in),
        .valid_out(valid_out),
        .data_out(data_out),
        .keep_out(keep_out),
        .last_out(last_out),
        .ready_out(ready_out),
        .valid_insert(valid_insert),
        .data_insert(data_insert),
        .keep_insert(keep_insert),
        .byte_insert_cnt(byte_insert_cnt),
        .ready_insert(ready_insert)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Testbench stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        data_in = 0;
        keep_in = 0;
        last_in = 0;
        ready_out = 0;
        valid_insert = 0;
        data_insert = 0;
        keep_insert = 0;
        byte_insert_cnt = 0;

        // Reset
        #10 rst_n = 1;

        // Test stimulus generation
        // Randomize the data and control signals for a comprehensive test
        repeat(1000) begin
            // Random data generation
            data_in <= $random;
            data_insert <= $random;

            // Random keep generation
            keep_in <= $random % (1 << DATA_BYTE_WD);
            keep_insert <= $random % (1 << DATA_BYTE_WD);

            // Random control signals generation
            valid_in <= $random % 2;
            valid_insert <= $random % 2;
            last_in <= $random % 2;
            ready_out <= $random % 2;

            // Cycle the clock
            #10;
        end
    end

    initial begin
        $dumpfile("wave.vcd");  
        $dumpvars(0, axi_stream_insert_header_tb);  
        #20000 $finish;
    end


endmodule