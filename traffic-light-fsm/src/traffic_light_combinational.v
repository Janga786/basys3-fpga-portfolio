// ============================================================
// Traffic Light Controller - Combinational Logic
// ============================================================
// 6 states (000-101) cycling with equal durations.
// Uses a 3-bit counter 'in' (a,b,c) and combinational
// assign statements derived from K-map simplification.
//
// Truth Table:
//  a b c | G1 Y1 R1 | G2 Y2 R2
//  0 0 0 |  0  0  1 |  1  0  0   (Road2 green, Road1 red)
//  0 0 1 |  0  0  1 |  0  1  0   (Road2 yellow, Road1 red)
//  0 1 0 |  0  0  1 |  0  0  1   (Both red momentarily)
//  0 1 1 |  1  0  0 |  0  0  1   (Road1 green, Road2 red)
//  1 0 0 |  0  1  0 |  0  0  1   (Road1 yellow, Road2 red)
//  1 0 1 |  0  0  1 |  0  0  1   (Both red momentarily)
//
// K-map simplified Boolean equations:
//  G1 = bc            Y1 = a~c          R1 = ~a~c + ~bc
//  G2 = ~a~b~c        Y2 = ~a~bc        R2 = a + b
// ============================================================

module trafficlight(clk, light1, light2);
    input clk;
    output [2:0] light1;  // {G1, Y1, R1}
    output [2:0] light2;  // {G2, Y2, R2}

    reg [2:0] in = 3'b000;  // 3-bit state counter {a, b, c}
    reg [31:0] cnt = 0;
    parameter cntmax = 32'd100_000_000;  // ~1 sec at 100 MHz

    // Rename for clarity: in[2]=a, in[1]=b, in[0]=c
    wire a, b, c;
    assign a = in[2];
    assign b = in[1];
    assign c = in[0];

    // --- Combinational light outputs (K-map results) ---
    assign light1[2] = b & c;                   // G1 = bc
    assign light1[1] = a & ~c;                  // Y1 = a~c
    assign light1[0] = (~a & ~c) | (~b & c);    // R1 = ~a~c + ~bc

    assign light2[2] = ~a & ~b & ~c;            // G2 = ~a~b~c
    assign light2[1] = ~a & ~b & c;             // Y2 = ~a~bc
    assign light2[0] = a | b;                   // R2 = a + b

    // --- Counter and state sequencer ---
    always @(posedge clk) begin
        if (cnt == cntmax) begin
            cnt <= 0;
            if (in == 3'b101)   // After state 5, wrap to state 0
                in <= 3'b000;
            else
                in <= in + 1;
        end
        else begin
            cnt <= cnt + 1;
        end
    end

endmodule
