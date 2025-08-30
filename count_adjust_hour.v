module count_adjust_hour(
    input wire clk, 
    input wire rst_n,
    input wire carry_min,
    input wire adj_en,
    input wire adj_up,
    input wire adj_down,

    output reg [4:0] hour, //bộ đếm 0 ... 23
    output reg carry_hour //carry tới ngày
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        carry_hour <= 1'b0;
        hour <= 5'd0;
    end else begin
        carry_hour <= 1'b0;
        if(adj_en) begin
            if(adj_up && !adj_down) begin
                if(hour == 5'd23)
                    hour <= 5'd0;
                else 
                    hour <= hour + 5'd1;
            end else if(adj_down && !adj_up) begin
                if(hour == 5'd0)
                    hour <= 5'd23;
                else
                    hour <= hour - 5'd1;
            end else
                hour <= hour;
        end else begin
            if(carry_min) begin
                if(hour == 5'd23) begin
                    hour <= 5'd0; //reset sau khi tới 23h
                    carry_hour <= 1'b1;
                end else
                    hour <= hour + 5'd1;
            end else
                hour <= hour;
        end
    end
end
endmodule