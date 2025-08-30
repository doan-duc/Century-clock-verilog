module count_adjust_day(
    input wire clk,
    input wire rst_n,
    input wire carry_hour,
    input wire adj_en,
    input wire adj_up,
    input wire adj_down,

    input wire [3:0] mon, // truyền tháng mấy
    input wire [13:0] year,// truyền năm bnh
    output reg [4:0] day, // bộ đếm 0 ... 31
    output reg carry_day // cary tới tháng
);

reg [4:0] max_day;
reg is_leap_year; 
//Tính toán năm nhuận
always @(year) begin 
    if((year % 14'd400) == 14'd0) is_leap_year = 1'b1;
    else if ((year % 14'd100) == 14'd0) is_leap_year = 1'b0;
    else if ((year % 14'd4) == 14'd0) is_leap_year = 1'b1;
    else is_leap_year = 1'b0;
end
always @(mon or is_leap_year) begin
    case(mon)
        4'd1, 4'd3, 4'd5, 4'd7, 4'd8, 4'd10, 4'd12: max_day = 5'd31;
        4'd4, 4'd6, 4'd9, 4'd11                   : max_day = 5'd30;
        4'd2                                      : max_day = (is_leap_year ? 5'd29 : 5'd28);
        default                                   : max_day = 5'd31;
    endcase
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        carry_day <= 1'b0;
        day <= 5'd1;
    end else begin
        carry_day <= 1'b0;
        if (day < 5'd1 || day > max_day) begin
            day <= 5'd1;
        end else begin
            if(adj_en) begin
                if(adj_up && !adj_down) begin
                    if(day == max_day) 
                        day <= 5'd1;
                    else 
                        day <= day + 5'd1;
                end else if(adj_down && !adj_up) begin
                    if(day == 5'd1)
                        day <= max_day;
                    else
                        day <= day - 5'd1;
                end else 
                    day <= day;
            end else begin
                if(carry_hour) begin
                    if(day == max_day) begin
                        day <= 5'd1;
                        carry_day <= 1'b1;
                    end else
                        day <= day + 5'd1;
                end else 
                    day <= day;
            end
        end
    end
end
endmodule
