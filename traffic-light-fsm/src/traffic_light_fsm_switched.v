// ============================================================
// Traffic Light FSM - Switch-Controlled Rush Hour
// ============================================================
// Adds a 'rush' switch input to the FSM + rush variant FSM.
// - rush = 0: Normal mode (all states have equal duration)
// - rush = 1: Rush hour mode (state 3 / G1 held for 2x)
//
// When rush=0, the second counter is bypassed and state 3
// advances after one cntmax cycle like all other states.
// ============================================================

module trafficlight_fsm_switch(clk, rush, light1, light2);
    input clk;
    input rush;               // Switch: 0 = normal, 1 = rush hour
    output [2:0] light1;
    output [2:0] light2;

    reg [5:0] lights;
    reg [2:0] state = 0;
    reg [31:0] cnt = 0;
    reg rush_cnt = 0;         // Second counter for G1 rush state
    parameter cntmax = 32'd100_000_000;

    assign light1 = lights[5:3];
    assign light2 = lights[2:0];

    // --- FSM: Output logic ---
    always @(*) begin
        case (state)
            3'd0: lights = 6'b001_100;  // R1, G2
            3'd1: lights = 6'b001_010;  // R1, Y2
            3'd2: lights = 6'b001_001;  // R1, R2
            3'd3: lights = 6'b100_001;  // G1, R2
            3'd4: lights = 6'b010_001;  // Y1, R2
            3'd5: lights = 6'b001_001;  // R1, R2
            default: lights = 6'b001_001;
        endcase
    end

    // --- FSM: State transitions ---
    always @(posedge clk) begin
        if (cnt == cntmax) begin
            cnt <= 0;
            if (state == 3'd3 && rush) begin
                // Rush hour: hold G1 state for double duration
                if (rush_cnt == 1'b1) begin
                    rush_cnt <= 0;
                    state <= 3'd4;
                end
                else begin
                    rush_cnt <= rush_cnt + 1;
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
