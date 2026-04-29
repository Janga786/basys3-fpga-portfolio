// ============================================================
// Traffic Light FSM - Rush Hour with Second Counter
// ============================================================
// Same 6-state FSM as FSM variant, but a second counter is added
// specifically for state 3 (G1=1, R2=1). When in rush hour
// mode, state 3 is held for 2 clock cycles (double duration)
// before advancing to state 4.
//
// The second counter 'rush_cnt' counts how many times cntmax
// has been reached while in state 3. It advances to state 4
// only after rush_cnt reaches 1 (i.e., 2 full periods).
// ============================================================

module trafficlight_fsm_rush(clk, light1, light2);
    input clk;
    output [2:0] light1;
    output [2:0] light2;

    reg [5:0] lights;
    reg [2:0] state = 0;
    reg [31:0] cnt = 0;
    reg rush_cnt = 0;             // Second counter for G1 rush state
    parameter cntmax = 32'd100_000_000;

    assign light1 = lights[5:3];
    assign light2 = lights[2:0];

    // --- FSM: Output logic ---
    always @(*) begin
        case (state)
            3'd0: lights = 6'b001_100;  // R1, G2
            3'd1: lights = 6'b001_010;  // R1, Y2
            3'd2: lights = 6'b001_001;  // R1, R2
            3'd3: lights = 6'b100_001;  // G1, R2  <-- held for 2x
            3'd4: lights = 6'b010_001;  // Y1, R2
            3'd5: lights = 6'b001_001;  // R1, R2
            default: lights = 6'b001_001;
        endcase
    end

    // --- FSM: State transitions with rush counter ---
    always @(posedge clk) begin
        if (cnt == cntmax) begin
            cnt <= 0;
            if (state == 3'd3) begin
                // In the G1 state: use second counter for double duration
                if (rush_cnt == 1'b1) begin
                    rush_cnt <= 0;
                    state <= 3'd4;   // Done with extended green, advance
                end
                else begin
                    rush_cnt <= rush_cnt + 1;
                    // Stay in state 3 for another cycle
                end
            end
            else if (state == 3'd5) begin
                state <= 3'd0;
            end
            else begin
                state <= state + 1;
            end
        end
        else begin
            cnt <= cnt + 1;
        end
    end

endmodule
