// Top: PS/2 keyboard input → ASCII translation → UART output.
    input clk, PS2Clk, PS2Data;
    output RsTx;
    output [15:0] led;

    wire [7:0] kb_data;
    wire kb_ready;
    reg ready_prev = 0;
    reg [7:0] scan_code = 0;
    wire [7:0] ascii_out;
    reg uart_send = 0;
    wire uart_ready;
    reg [7:0] uart_data = 0;
    reg [7:0] last_scan = 0;
    reg break_flag = 0;

    localparam IDLE = 2'b00, WAIT_TX = 2'b01;
    reg [1:0] state = IDLE;

    USB_keyboard kb1(.ps2data(PS2Data), .ps2clk(PS2Clk), .data(kb_data), .ready(kb_ready));
    scancode_to_ascii converter(.scan_code(scan_code), .ascii(ascii_out));
    UART_tx_ctrl #(9600) uart(.clk(clk), .send(uart_send), .data(uart_data),
        .uart_tx(RsTx), .ready(uart_ready));

    always @(posedge clk) begin
        ready_prev <= kb_ready;
        uart_send <= 1'b0;

        if (ready_prev == 1'b0 && kb_ready == 1'b1) begin
            if (kb_data == 8'hF0)
                break_flag <= 1'b1;
            else if (break_flag)
                break_flag <= 1'b0;
            else begin
                scan_code <= kb_data;
                last_scan <= kb_data;
            end
        end

        case (state)
        IDLE:
            if (ready_prev == 1'b0 && kb_ready == 1'b1 && kb_data != 8'hF0 && !break_flag)
                state <= WAIT_TX;
        WAIT_TX:
        begin
            if (uart_ready && ascii_out != 8'h00) begin
                uart_data <= ascii_out;
                uart_send <= 1'b1;
            end
            state <= IDLE;
        end
        endcase
    end

    assign led = {last_scan, ascii_out};
endmodule
