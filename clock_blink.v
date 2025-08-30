module clock_blink #(parameter integer CLK_HZ = 50000000)(
    input wire clk, rst_n,
    input wire en,
    input wire event_clk1s, //truyền xung clk_1s vào chớp nháy mỗi 1s
    output reg blink 
);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        blink <= 1'b0;
    else if(en && event_clk1s) 
        blink <= ~blink; // đảo mỗi 1s (1s tắt 1s bật)
    else 
        blink <= blink;
end
endmodule