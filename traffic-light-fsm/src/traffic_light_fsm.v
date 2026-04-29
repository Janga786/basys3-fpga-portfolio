// ============================================================
// Traffic Light Controller - FSM (Regular Mode)
// ============================================================
// Instead of combinational logic, use a state register and
// directly assign a 6-bit binary output for each state.
// Output format: {G1, Y1, R1, G2, Y2, R2}
//
// State | Lights           | Output
//   0   | R1=1, G2=1       | 001_100 = 6'b001100
//   1   | R1=1, Y2=1       | 001_010 = 6'b001010
//   2   | R1=1, R2=1       | 001_001 = 6'b001001
//   3   | G1=1, R2=1       | 100_001 = 6'b100001
//   4   | Y1=1, R2=1       | 010_001 = 6'b010001
//   5   | R1=1, R2=1       | 001_001 = 6'b001001
// ============================================================

module trafficlight_fsm(clk, light1, light2);
    input clk;
    output [2:0] light1;  // {G1, Y1, R1}
    output [2:0] light2;  // {G2, Y2, R2}

    reg [5:0] lights;     // {G1, Y1, R1, G2, Y2, R2}
    reg [2:0] state = 0;
    reg [31:0] cnt = 0;
    parameter cntmax = 32'd100_000_000;

    // Map internal reg to outputs
    assign light1 = lights[5:3];
    assign light2 = lights[2:0];

    // --- FSM: Output logic (combinational) ---
    always @(*) begin
        case (state)
            3'd0: lights = 6'b001_100;  // R1, G2
            3'd1: lights = 6'b001_010;  // R1, Y2
            3'd2: lights = 6'b001_001;  // R1, R2
            3'd3: lights = 6'b100_001;  // G1, R2
            3'd4: lights = 6'b010_001;  // Y1, R2
            3'd5: lights = 6'b001_001;  // R1, R2
            default: lights = 6'b001_001; // Safe default: all red
        endcase
    end

    // --- FSM: State transition (sequential) ---
    always @(posedge clk) begin
        if (cnt == cntmax) begin
            cnt <= 0;
            if (state == 3'd5)
                state <= 3'd0;
            else
                state <= state + 1;
        end
        else begin
            cnt <= cnt + 1;
        end
    end

endmodule
