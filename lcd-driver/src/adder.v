module adder(clk, A, B, cm1, data, OV);
    input clk, cm1; // clock and adder/subtractor switch input (cm1 also acts as +1 for 2's complement)
    input [2:0] A; // 3 bit input
    input [2:0] B; // 3 bit input
    output reg OV; // overflow flag register
    output [3:0] data; // data to display on 7 seg display
    reg [2:0] S_reg; // register to store sum output
    reg c2final; // verified output of c2

    wire [2:0] AA; // input A based on cm1 switch (add/sub)
    wire c0, c1, c2; // intermediary carry outs between Full Adders
    wire [2:0] S; // Sums of each FA
    wire overflow; // overflow flag wire (later used for lighting led)

    // A input manipulated based on cm1 selected mode
    assign AA[0] = A[0] ^ cm1;
    assign AA[1] = A[1] ^ cm1;
    assign AA[2] = A[2] ^ cm1;

    // Carry out logic for each full adder
    assign c0 = ((AA[0] | B[0]) & cm1) | (AA[0] & B[0]);
    assign c1 = ((AA[1] | B[1]) & c0)  | (AA[1] & B[1]);
    assign c2 = ((AA[2] | B[2]) & c1)  | (AA[2] & B[2]);

    // Sum logic for each FA
    assign S[0] = AA[0] ^ B[0] ^ cm1;
    assign S[1] = AA[1] ^ B[1] ^ c0;
    assign S[2] = AA[2] ^ B[2] ^ c1;

    assign overflow = c1 ^ c2; // Overflow logic derived in class

    assign data = {c2final, S_reg}; // output from sums concatenated with c2 for the validated sign

    always @(posedge clk) begin // make changes each rising clock edge
        S_reg    <= S; // store sum result in a register
        OV       <= overflow; // store overflow result in a register
        c2final  <= (~overflow & S[2]) | (overflow & ~S[2] & c2); // validate sign output
    end

endmodule
