module count_adjust_month(
    input  wire clk,
    input  wire rst_n,
    input  wire carry_day,
    input  wire adj_en,    
    input  wire adj_up,    
    input  wire adj_down,    

    output reg        carry_mon,
    output reg [3:0]  mon
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        carry_mon <= 1'b0;
        mon       <= 4'd1;
    end else begin
        carry_mon <= 1'b0;
        if (mon < 4'd1 || mon > 4'd12) begin
            mon <= 4'd1;
        end else begin
            if (adj_en) begin
                if (adj_up && !adj_down) begin
                    if (mon == 4'd12) begin
                        mon <= 4'd1;
                    end else begin
                        mon <= mon + 4'd1;
                    end
                end else begin
                    if (adj_down && !adj_up) begin
                        if (mon == 4'd1) begin
                            mon <= 4'd12;
                        end else begin
                            mon <= mon - 4'd1;
                        end
                    end else begin
                        mon <= mon;
                    end
                end
            end else begin
                if (carry_day) begin
                    if (mon == 4'd12) begin
                        mon <= 4'd1;
                        carry_mon <= 1'b1;
                    end else begin
                        mon <= mon + 4'd1;
                    end
                end else begin
                    mon <= mon;
                end
            end
        end
    end
end
endmodule
