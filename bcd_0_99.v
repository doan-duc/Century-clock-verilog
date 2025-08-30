module bcd_0_99(
    input wire [6:0] digit,
    output reg [3:0] digit0, //ones
    output reg [3:0] digit1 //tens
);
    always @(digit) begin
        if (digit > 7'd99) begin      // kẹp phạm vi (tránh BCD sai)
           digit1 = 4'd9; 
           digit0 = 4'd9;
        end
        else if(digit >= 7'd90) begin
            digit1 = 4'd9;
            digit0 = digit - 7'd90;
        end
        else if(digit >= 7'd80) begin
            digit1 = 4'd8;
            digit0 = digit - 7'd80;
        end
        else if(digit >= 7'd70) begin
            digit1 = 4'd7;
            digit0 = digit - 7'd70;
        end
        else if(digit >= 7'd60) begin
            digit1 = 4'd6;
            digit0 = digit - 7'd60;
        end
        else if(digit >= 7'd50) begin
            digit1 = 4'd5;
            digit0 = digit - 7'd50;
        end
        else if(digit >= 7'd40) begin
            digit1 = 4'd4;
            digit0 = digit - 7'd40;
        end
        else if(digit >= 7'd30) begin
            digit1 = 4'd3;
            digit0 = digit - 7'd30;
        end
        else if(digit >= 7'd20) begin
            digit1 = 4'd2;
            digit0 = digit - 7'd20;
        end
        else if(digit >= 7'd10) begin
            digit1 = 4'd1;
            digit0 = digit - 7'd10;
        end
        else begin
            digit1 = 4'd0;
            digit0 = digit;
        end
    end
endmodule