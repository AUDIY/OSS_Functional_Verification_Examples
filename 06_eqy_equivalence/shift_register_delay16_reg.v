`default_nettype none

module shift_register_delay16 (
    input  wire clk,
    input  wire [7:0] indata,
    output wire [7:0] outdata
);

    reg [7:0] storage [15:0];
    integer i, j;

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            storage[i] = {8{1'b0}};
        end
    end

    always @(posedge clk) begin
        storage[0] <= indata;

        for (j = 1; j < 16; j = j + 1) begin
            storage[j] <= storage[j - 1];
        end
    end

    assign outdata = storage[15];

    `ifdef FORMAL
        reg       formal_en = 1'b0;
        reg [4:0] count     = {5{1'b0}};

        always @(posedge clk) begin
            if (count == 5'b10000) begin
                count <= count;
            end else begin
                count <= count + 1'b1;
            end
        end

        always @(posedge clk) begin
            if (count == 5'b10000) begin
                formal_en <= 1'b1;
            end else begin
                formal_en <= 1'b0;
            end
        end
        
        always @(posedge clk) begin
            if (formal_en) begin
                a_delay: assert(
                    outdata == $past(indata, 16)
                ); 
            end
        end
    `endif // FORMAL
    
endmodule

`default_nettype wire
