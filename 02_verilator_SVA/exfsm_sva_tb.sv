`default_nettype none

module exfsm_sva_tb ();

    timeunit 1ns / 1ps;

    reg clk = 1'b0;
    reg start = 1'b0;
    reg areset_n = 1'b0;

    wire [1:0] state;
    wire a;
    wire b;
    wire c;

    integer start_count = '0;

    exfsm_sva dut (
        .clk(clk),
        .start(start),
        .areset_n(areset_n),
        .state(state),
        .a(a),
        .b(b),
        .c(c)
    );

    initial begin
        $dumpfile("exfsm_sva.vcd");
        $dumpvars(0, exfsm_sva_tb);

        #500 $finish(0);
    end

    initial begin
        forever begin
            #1 clk <= ~clk;
        end
    end

    always @(posedge clk) begin
        if (start_count == 50) begin
            start_count <= '0;
        end else begin
            start_count <= start_count + 1;
        end
    end

    always @(posedge clk) begin
        if (start_count == 50) begin
            start <= 1'b1;
        end else begin
            start <= 1'b0;
        end
    end

    initial begin
        #1 areset_n <= 1'b1;
        #405 areset_n <= 1'b0;
        #4 areset_n <= 1'b1;
    end

    /**************************************************************************
        SystemVerilog Assertions
    **************************************************************************/
    `ifdef SVA
        a_start_pulse_width: assert property (
            @(posedge clk) $rose(start) |=> $fell(start)
        );

        a_start2a: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(start) |-> ##1 $rose(a))
        );

        a_a_pulse_width: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(a) |-> ##1 $fell(a))
        );

        a_a2b: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(a) |=> ##1 $rose(b))
        );

        a_b_pulse_width: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(b) |=> $fell(b))
        );

        a_b2c: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(b) |-> ##[2:3] $rose(c))
        );

        a_c_pulse_width: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(c) |=> $fell(c))
        );

        a_start2a_past: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(a) |-> $past(start))
        );

        a_a2b_past: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(b) |-> $past(a, 2))
        );

        a_b2c_past: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(c) |-> $past(b, 3))
        );

        a_total: assert property (
            @(posedge clk) disable iff (!areset_n) ($rose(start) |=> a ##2 b ##3 c)
        );

    `endif // SVA
    
endmodule

`default_nettype wire
