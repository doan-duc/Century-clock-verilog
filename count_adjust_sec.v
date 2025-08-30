module count_adjust_sec(
    input wire clk, 
    input wire rst_n,
    input wire t_1s, // xung 1 T/s
    input wire adj_en,
    input wire adj_up,
    input wire adj_down,

    output reg [5:0] sec, //bộ đếm 0 ... 59
    output reg carry_sec //=1 khi hết 1 chu kỳ giây, =0 trong suốt chu kỳ
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sec <= 6'd0;
        carry_sec <= 1'b0;
    end else begin
        carry_sec <= 1'b0;
        if(adj_en) begin
            if(adj_up && !adj_down) begin
                if(sec == 6'd59)
                    sec <= 6'd0;
                else 
                    sec <= sec + 6'd1;
            end else if(adj_down && !adj_up) begin
                if(sec == 6'd0)
                    sec <= 6'd59;
                else
                    sec <= sec - 6'd1;
            end else 
                sec <= sec;
        end else begin
            if(t_1s) begin
                if(sec == 6'd59) begin
                    sec <= 6'd0; //reset sau khi tới giây 59
                    carry_sec <= 1'b1;
                end else 
                    sec <= sec + 6'd1;
            end else
                sec <= sec;
        end
    end
end
endmodule 