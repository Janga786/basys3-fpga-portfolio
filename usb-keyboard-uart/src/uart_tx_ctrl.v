module UART_tx_ctrl (ready, uart_tx, send, clk, data);
    input send, clk;
    input [7:0] data;
    output ready, uart_tx;
    parameter baud = 9600;
    parameter bit_index_max = 10;
    localparam [31:0] baud_timer = 100000000 / baud;
    localparam RDY = 2'b00, LOAD_BIT = 2'b01, SEND_BIT = 2'b10;
    reg [1:0] state = RDY;
    reg [31:0] timer = 0;
    reg [9:0] txData;
    reg [3:0] bitIndex;
    reg txBit = 1'b1;

    always @(posedge clk)
    begin
        case (state)
        RDY:
        begin
            bitIndex <= 1'b0;
            timer <= 14'b0;
            txBit <= 1'b1;
            if (send == 1'b1) begin
                txData <= {1'b1, data, 1'b0};
                state <= LOAD_BIT;
            end
        end

        LOAD_BIT:
        begin
            if (timer == baud_timer) begin
                timer <= 14'b0;
                state <= SEND_BIT;
                txBit <= txData[bitIndex];
                bitIndex <= bitIndex + 1;
            end
            else
                timer <= timer + 1;
        end

        SEND_BIT:
        begin
            if (bitIndex == bit_index_max)
                state <= RDY;
            else
                state <= LOAD_BIT;
        end

        default:
            state <= RDY;
        endcase
    end

    assign uart_tx = txBit;
    assign ready = (state == RDY);
endmodule
