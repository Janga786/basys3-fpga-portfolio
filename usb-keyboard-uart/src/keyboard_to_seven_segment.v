module USB_keyboard_app(clk, PS2Clk, PS2Data, led);
    input clk, PS2Clk, PS2Data;
    output [15:0] led;

    localparam PRESS=2'b00, EXTEND=2'b01, RLS=2'b10, CHECK=2'b11;

    reg [1:0] state = PRESS;
    reg [23:0] received;
    wire [7:0] data;
    reg [7:0] ledreg = 0;
    wire ready;
    reg ready_prev;

    USB_keyboard kb1(.ps2data(PS2Data), .ps2clk(PS2Clk), .data(data), .ready(ready));

    always @(posedge clk) begin
        ready_prev <= ready;
        case (state)
        PRESS:
            if (ready_prev == 0 && ready == 1) begin
                received[23:16] <= data;
                state <= EXTEND;
            end
        EXTEND:
            if (ready_prev == 0 && ready == 1) begin
                received[15:8] <= data;
                state <= RLS;
            end
        RLS:
            if (received[15:8] != 8'hF0)
                state <= EXTEND;
            else if (ready_prev == 0 && ready == 1) begin
                received[7:0] <= data;
                state <= CHECK;
            end
        CHECK:
        begin
            case (received[7:0])
                8'h16: ledreg[0] <= ~ledreg[0];
                8'h1E: ledreg[1] <= ~ledreg[1];
                8'h26: ledreg[2] <= ~ledreg[2];
                8'h25: ledreg[3] <= ~ledreg[3];
                8'h2E: ledreg[4] <= ~ledreg[4];
                8'h36: ledreg[5] <= ~ledreg[5];
                8'h3D: ledreg[6] <= ~ledreg[6];
                8'h3E: ledreg[7] <= ~ledreg[7];
            endcase
            state <= PRESS;
        end
        endcase
    end

    assign led = {received[7:0], ledreg};
endmodule
