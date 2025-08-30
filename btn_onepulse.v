// Debounce + one-pulse for active-low push buttons (e.g., DE2-115 KEY[n])
module btn_onepulse #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer DEBOUNCE_MS = 20
)(
    input  wire clk,
    input  wire rst_n,
    input  wire btn_n,  // active-low raw button
    output reg  pulse   // one clock-cycle pulse on each stable press
);
    localparam integer N = (CLK_HZ/1000)*DEBOUNCE_MS;

    // sync to clk & invert to active-high
    reg [1:0] sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync <= 2'b00;
        end else begin
            sync <= {sync[0], ~btn_n};
        end
    end

    // debounce with counter
    reg [31:0] cnt;
    reg db, db_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt   <= 32'd0;
            db    <= 1'b0;
            db_d  <= 1'b0;
            pulse <= 1'b0;
        end else begin
            if (sync[1] == db) begin
                cnt <= 32'd0;
            end else begin
                if (cnt >= N[31:0]) begin
                    db  <= sync[1];
                    cnt <= 32'd0;
                end else begin
                    cnt <= cnt + 32'd1;
                end
            end

            // one-pulse on rising edge of debounced signal
            db_d <= db;
            if (db == 1'b1) begin
                if (db_d == 1'b0) pulse <= 1'b1;
                else              pulse <= 1'b0;
            end else begin
                pulse <= 1'b0;
            end
        end
    end
endmodule
