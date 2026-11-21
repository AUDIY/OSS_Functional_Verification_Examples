`default_nettype none

module exfsm_sva (
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
    
endmodule

`default_nettype wire
