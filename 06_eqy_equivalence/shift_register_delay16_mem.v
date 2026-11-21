`default_nettype none

module shift_register_delay16 (
    input  wire       clk    ,
    input  wire [7:0] indata ,
    output wire [7:0] outdata
);

    reg [3:0] addr = {4{1'b0}};
    reg [7:0] mem [15:0];
    reg [7:0] reg_out = {8{1'b0}};

    integer i;

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            mem[i] = {8{1'b0}};
        end
    end

    always @(posedge clk) begin
        addr <= addr + 1'b1;
    end

    always @(posedge clk) begin
        mem[addr] <= indata;
    end

    always @(posedge clk) begin
        reg_out <= mem[addr + 1];
    end

    assign outdata = reg_out;

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
