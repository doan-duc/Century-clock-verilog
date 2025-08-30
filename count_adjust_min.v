module count_adjust_min(
    input wire clk, 
    input wire rst_n,
    input wire carry_sec,
    input wire adj_en,
    input wire adj_up,
    input wire adj_down,

    output reg [5:0] min, //bộ đếm 0 ... 59
    output reg carry_min //carry tới giờ
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        carry_min <= 1'b0;
        min <= 6'd0;
    end else begin
        carry_min <= 1'b0;
        if(adj_en) begin
            if(adj_up && !adj_down) begin
                if(min == 6'd59)
                    min <= 6'd0;
                else 
                    min <= min + 6'd1;
            end else if(adj_down && !adj_up) begin
                if(min == 6'd0)
                    min <= 6'd59;
                else 
                    min <= min - 6'd1;
            end else
                min <= min;
        end else begin
            if(carry_sec) begin
                if(min == 6'd59) begin
                    min <= 6'd0; //reset sau khi tới phút 59
                    carry_min <= 1'b1;
                end else
                    min <= min + 6'd1;
            end else
                min <= min;
        end
    end
end
endmodule