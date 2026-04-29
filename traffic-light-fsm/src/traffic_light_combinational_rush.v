// ============================================================
// Traffic Light Controller - Rush Hour (Combinational)
// ============================================================
// A switch selects between regular (6 states) and rush hour
// (7 states) mode. In rush hour, G1 stays on for 2 cycles
// (states 011 and 100 both have G1=1, R2=1).
//
// Rush Hour Truth Table:
//  a b c | G1 Y1 R1 | G2 Y2 R2
//  0 0 0 |  0  0  1 |  1  0  0
//  0 0 1 |  0  0  1 |  0  1  0
//  0 1 0 |  0  0  1 |  0  0  1
//  0 1 1 |  1  0  0 |  0  0  1
//  1 0 0 |  1  0  0 |  0  0  1  <-- added state (G1 extended)
//  1 0 1 |  0  1  0 |  0  0  1
//  1 1 0 |  0  0  1 |  0  0  1
//
// K-map simplified (don't care at 111):
//  G1 = bc + a~b~c     Y1 = ac          R1 = ~a~b + b~c
//  G2 = ~a~b~c         Y2 = ~a~bc       R2 = a + b
// ============================================================

module trafficlight_rush(clk, rush, light1, light2);
    input clk;
    input rush;           // Switch: 0 = regular, 1 = rush hour
    output [2:0] light1;  // {G1, Y1, R1}
    output [2:0] light2;  // {G2, Y2, R2}

    reg [2:0] in = 3'b000;
    reg [31:0] cnt = 0;
    parameter cntmax = 32'd100_000_000;

    wire a, b, c;
    assign a = in[2];
    assign b = in[1];
    assign c = in[0];

    // --- Mux between regular and rush-hour logic ---

    // Regular mode equations (combinational variant):
    wire G1_reg = b & c;
    wire Y1_reg = a & ~c;
    wire R1_reg = (~a & ~c) | (~b & c);

    // Rush hour mode equations:
    wire G1_rush = (b & c) | (a & ~b & ~c);
    wire Y1_rush = a & c;
    wire R1_rush = (~a & ~b) | (b & ~c);

    // These are the same in both modes:
    wire G2_out = ~a & ~b & ~c;
    wire Y2_out = ~a & ~b & c;
    wire R2_out = a | b;

    // Select based on rush switch
    assign light1[2] = rush ? G1_rush : G1_reg;   // G1
    assign light1[1] = rush ? Y1_rush : Y1_reg;   // Y1
    assign light1[0] = rush ? R1_rush : R1_reg;   // R1
    assign light2[2] = G2_out;                     // G2
    assign light2[1] = Y2_out;                     // Y2
    assign light2[0] = R2_out;                     // R2

    // --- Counter and state sequencer ---
    // Regular: 6 states (000-101), Rush: 7 states (000-110)
    always @(posedge clk) begin
        if (cnt == cntmax) begin
            cnt <= 0;
            if (!rush && in == 3'b101)       // Regular: wrap after state 5
                in <= 3'b000;
            else if (rush && in == 3'b110)   // Rush: wrap after state 6
                in <= 3'b000;
            else
                in <= in + 1;
        end
        else begin
            cnt <= cnt + 1;
        end
    end

endmodule
