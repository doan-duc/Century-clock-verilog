module count_adjust_year(
    input wire clk,
    input wire rst_n,
    input wire carry_mon,
    input wire adj_en,    
    input wire adj_up,   
    input wire adj_down,
    output reg [13:0] year
);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        year <= 14'd2000;
    else begin
        if(adj_en) begin
            if(adj_up && !adj_down)
                year <= year + 14'd1;
            else if(adj_down && !adj_up)
                year <= year - 14'd1;
            else
                year <= year;
        end else begin
            if(carry_mon)
                year <= year + 14'd1;
            else
                year <= year;
        end
    end
end
endmodule
