module clock_divider_1s #(parameter integer CLK_HZ = 50000000)(
    input wire clk, 
    input wire rst_n,
    output reg clk_1s 
);
reg [25:0] cnt;  //khai báo để biểu diễn đủ bit cho cnt
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 26'd0;
        clk_1s <= 1'b0;
    end
    else begin
        clk_1s <= 1'b0;         //mặc định gdinh là 0 
        if(cnt != CLK_HZ - 1)  //cnt tăng liên tiếp tới đủ số chu kỳ của xung clk trong 1s
            cnt <= cnt + 1'b1;
        else begin
            cnt <= 26'd0;
            clk_1s <= 1'b1;  // flag báo hiệu 1s có giá trị là 1 
        end
    end
end
endmodule