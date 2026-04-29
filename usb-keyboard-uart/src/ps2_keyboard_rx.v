module USB_keyboard(ps2data, ps2clk, data, ready);
    input ps2data, ps2clk;
    output reg [7:0] data;
    output reg ready;

    parameter RDY=2'b00, RECEIVE=2'b01, PARITY=2'b10, STOP=2'b11;

    reg [2:0] state = RDY;
    reg [7:0] received;
    reg prty;
    integer index = 0;

    always @(negedge ps2clk) begin
        case (state)
        RDY:
            if (ps2data == 1'b0) begin
                state <= RECEIVE;
                ready <= 1'b0;
                index <= 0;
            end
        RECEIVE:
        begin
            if (index == 7) state <= PARITY;
            received[index] <= ps2data;
            index <= index + 1;
        end
        PARITY:
        begin
            prty <= ps2data;
            state <= STOP;
        end
        STOP:
            if (ps2data == 1'b1) begin
                state <= RDY;
                ready <= 1'b1;
                if (prty != ~(^received)) data <= 8'h00;
                else data <= received;
            end
        endcase
    end
endmodule
