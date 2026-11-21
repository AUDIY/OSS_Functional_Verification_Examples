`default_nettype none

module exfsm_formal (
    input  wire clk,
    input  wire start,
    input  wire areset_n,
    output wire [1:0] state,
    output wire a,
    output wire b,
    output wire c
);

    localparam WAIT = 2'd0;
    localparam OUTA = 2'd1;
    localparam OUTB = 2'd2;
    localparam OUTC = 2'd3;

    reg [1:0] r_state = 2'd0; 
    reg r_a = 1'b0;
    reg r_b = 1'b0;
    reg r_c = 1'b0;

    reg [1:0] a_b_count = 2'd0;
    reg [1:0] b_c_count = 2'd1;

    always @(posedge clk or negedge areset_n) begin
        if (!areset_n) begin
            r_state <= WAIT;
            r_a <= 1'b0;
            r_b <= 1'b0;
            r_c <= 1'b0;
            a_b_count <= 2'd0;
            b_c_count <= 2'd0;
        end else begin
            case (r_state)
                WAIT: begin
                    if (start) begin
                        r_state <= OUTA;
                        r_a <= 1'b1;
                        r_b <= 1'b0;
                        r_c <= 1'b0;
                        a_b_count <= 2'd0;
                        b_c_count <= 2'd0;
                    end else begin
                        r_state <= WAIT;
                        r_a <= 1'b0;
                        r_b <= 1'b0;
                        r_c <= 1'b0;
                        a_b_count <= 2'd0;
                        b_c_count <= 2'd0;
                    end
                end
                OUTA: begin
                    r_state <= OUTB;
                    r_a <= 1'b0;
                    r_b <= 1'b0;
                    r_c <= 1'b0;
                    a_b_count <= a_b_count + 2'd1;
                    b_c_count <= 2'd0;
                end
                OUTB:begin
                    if (a_b_count < 2'd1) begin
                        r_state <= OUTB;
                        r_a <= 1'b0;
                        r_b <= 1'b0;
                        r_c <= 1'b0;
                        a_b_count <= a_b_count + 2'd1;
                        b_c_count <= 2'd0;
                    end else begin
                        r_state <= OUTC;
                        r_a <= 1'b0;
                        r_b <= 1'b1;
                        r_c <= 1'b0;
                        a_b_count <= 2'd0;
                        b_c_count <= 2'd0;
                    end
                end
                OUTC: begin
                    if (b_c_count < 2'd2) begin
                        r_state <= OUTC;
                        r_a <= 1'b0;
                        r_b <= 1'b0;
                        r_c <= 1'b0;
                        a_b_count <= 2'd0;
                        b_c_count <= b_c_count + 2'd1;
                    end else begin
                        r_state <= WAIT;
                        r_a <= 1'b0;
                        r_b <= 1'b0;
                        r_c <= 1'b1;
                        a_b_count <= 2'd0;
                        b_c_count <= 2'd0;
                    end
                end 
                default: begin
                    r_state <= WAIT;
                    r_a <= 1'b0;
                    r_b <= 1'b0;
                    r_c <= 1'b0;
                    a_b_count <= 2'd0;
                    b_c_count <= 2'd0;
                end 
            endcase
        end
    end

    assign state = r_state;
    assign a = r_a;
    assign b = r_b;
    assign c = r_c;

    `ifdef FORMAL

        reg [2:0] formal_cnt = 3'd0;
        reg formal_en = 1'b0;

        always @(posedge clk ) begin
            // SVA: $rose(start) |=> $fell(start)
            if ($past(start, 1)) begin
                formal_start_pulse_width: assume($fell(start));
            end
        end

        always @(posedge clk) begin
            if (!areset_n) begin
                formal_cnt <= 3'd0;
                formal_en <= 1'b0;
            end else begin
                // To prevent false positive
                if (formal_cnt <= 3'd6) begin
                    formal_cnt <= formal_cnt + 1'b1;
                end else begin
                    formal_cnt <= formal_cnt;
                end 

                if (formal_cnt == 3'd6) begin
                    formal_en <= 1'b1;
                end

                if (formal_en) begin
                    // SVA: ((state == WAIT) && $rose(start)) |-> ##1 $rose(a)
                    if ($rose(a)) begin
                        a_start2a: assert($past(start, 1) && ($past(state, 1) == WAIT));
                    end

                    // SVA: $rose(a) |-> ##1 $fell(a)
                    if ($past(a, 1)) begin
                        a_a_pulse_width: assert($fell(a));
                    end

                    // SVA: $rose(a) |=> ##1 $rose(b)
                    if ($past(a, 2)) begin
                        a_a2b: assert($rose(b));
                    end

                    // SVA: $rose(b) |=> $fell(b)
                    if ($past(b, 1)) begin
                        a_b_pulse_width: assert($fell(b));
                    end

                    // SVA: $rose(b) |-> #3 $rose(c)
                    if ($past(b, 3)) begin
                        a_b2c: assert($rose(c));
                    end

                    // SVA: $rose(c) |=> $fell(c)
                    if ($past(c, 1)) begin
                        a_c_pulse_width: assert($fell(c));
                    end

                    // SVA: $rose(a) |-> $past(start)
                    if ($rose(a)) begin
                        a_start2a_past: assert($past(start, 1));
                    end

                    // SVA: $rose(b) |-> $past(a, 2)
                    if ($rose(b)) begin
                        a_a2b_past: assert($past(a, 2));
                    end

                    // SVA: $rose(c) |-> $past(b, 3)
                    if ($rose(c)) begin
                        a_b2c_past: assert($past(b, 3));
                    end

                    // SVA: $rose(start) |=> a ##2 b ##3 c
                    if ($rose(c)) begin
                        a_total: assert($past(start, 6) && $past(a, 5) && $past(b, 3));
                    end
                end
            end
        end
    `endif // FORMAL
    
endmodule

`default_nettype wire
