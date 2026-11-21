`default_nettype none

class exrandom;
    rand int a, x, y, z;

    // Example of Constrained Random
    constraint c1{
        a inside {[-100:100]};
        x inside {[-100:100]};
        y inside {[-100:100]};
        z inside {[-100:100]};

        x != 0;
        y != 0;
        z != 0;

        (x * y) > z;                       
        ((x / y) <= 1) && ((x / y) >= -1);
        (y % 2) == 1;
        (x + y + z) > a;
    }
endclass //exrandom

module random_example_tb ();

    initial begin
        exrandom ex = new();

        $display("");
        $display("======================================");
        $display("        Generated Random Number       ");
        $display("======================================");

        repeat (10) begin
            if (ex.randomize()) begin
                $display("a = %4d, x = %4d, y = %4d, z = %4d", ex.a, ex.x, ex.y, ex.z);
            end else begin
                $fatal(0, "Error: Randomize Failed!");
            end
        end

        $display("");

        $finish();
    end
    
endmodule

`default_nettype wire
