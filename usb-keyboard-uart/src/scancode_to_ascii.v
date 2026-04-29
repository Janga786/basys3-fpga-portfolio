module scancode_to_ascii(scan_code, ascii);
    input [7:0] scan_code;
    output reg [7:0] ascii;

    always @(*) begin
        case (scan_code)
            8'h1C: ascii = 8'h61; 8'h32: ascii = 8'h62; 8'h21: ascii = 8'h63;
            8'h23: ascii = 8'h64; 8'h24: ascii = 8'h65; 8'h2B: ascii = 8'h66;
            8'h34: ascii = 8'h67; 8'h33: ascii = 8'h68; 8'h43: ascii = 8'h69;
            8'h3B: ascii = 8'h6A; 8'h42: ascii = 8'h6B; 8'h4B: ascii = 8'h6C;
            8'h3A: ascii = 8'h6D; 8'h31: ascii = 8'h6E; 8'h44: ascii = 8'h6F;
            8'h4D: ascii = 8'h70; 8'h15: ascii = 8'h71; 8'h2D: ascii = 8'h72;
            8'h1B: ascii = 8'h73; 8'h2C: ascii = 8'h74; 8'h3C: ascii = 8'h75;
            8'h2A: ascii = 8'h76; 8'h1D: ascii = 8'h77; 8'h22: ascii = 8'h78;
            8'h35: ascii = 8'h79; 8'h1A: ascii = 8'h7A;
            8'h45: ascii = 8'h30; 8'h16: ascii = 8'h31; 8'h1E: ascii = 8'h32;
            8'h26: ascii = 8'h33; 8'h25: ascii = 8'h34; 8'h2E: ascii = 8'h35;
            8'h36: ascii = 8'h36; 8'h3D: ascii = 8'h37; 8'h3E: ascii = 8'h38;
            8'h46: ascii = 8'h39;
            8'h29: ascii = 8'h20; 8'h5A: ascii = 8'h0D; 8'h66: ascii = 8'h08;
            8'h0D: ascii = 8'h09;
            8'h49: ascii = 8'h2E; 8'h41: ascii = 8'h2C; 8'h4C: ascii = 8'h3B;
            8'h4E: ascii = 8'h2D; 8'h55: ascii = 8'h3D; 8'h54: ascii = 8'h5B;
            8'h5B: ascii = 8'h5D; 8'h4A: ascii = 8'h2F; 8'h5D: ascii = 8'h5C;
            8'h52: ascii = 8'h27; 8'h0E: ascii = 8'h60;
            default: ascii = 8'h00;
        endcase
    end
endmodule
