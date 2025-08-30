module bcd_to_7seg(
    input wire [3:0] hex_digit,
    output reg [6:0] seg_data
);

    always @(hex_digit) begin
        case (hex_digit)
            4'b0000: seg_data = 7'b1000000; // 0
            4'b0001: seg_data = 7'b1111001; // 1
            4'b0010: seg_data = 7'b0100100; // 2
            4'b0011: seg_data = 7'b0110000; // 3
            4'b0100: seg_data = 7'b0011001; // 4
            4'b0101: seg_data = 7'b0010010; // 5
            4'b0110: seg_data = 7'b0000010; // 6
            4'b0111: seg_data = 7'b1111000; // 7
            4'b1000: seg_data = 7'b0000000; // 8
            4'b1001: seg_data = 7'b0010000; // 9
            default: seg_data = 7'b1111111; // Invalid input
        endcase
    end

endmodule
