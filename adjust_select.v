// - sw_mode=0: Giờ -> Phút -> Giây
// - sw_mode=1: Ngày -> Tháng -> Năm
// Mỗi lần nhấn nút sel_pulse sẽ chuyển sang mục tiếp theo.
module adjust_select(
    input  wire clk,
    input  wire rst_n,
    input  wire sw_mode,     // 0=time, 1=date
    input  wire sel_pulse,   // xung 1 chu kỳ để chuyển mục
    input  wire up_pulse,    // xung 1 chu kỳ nút UP
    input  wire down_pulse,  // xung 1 chu kỳ nút DOWN

    output reg [1:0] idx,     // 0=HH/DD, 1=MM/MM, 2=SS/YYYY
    output reg en_sec, // Enable chỉnh cho từng counter
    output reg en_min,
    output reg en_hour,
    output reg en_day,
    output reg en_mon,
    output reg en_year,
    output reg adj_sec_up,  output reg adj_sec_down,
    output reg adj_min_up,  output reg adj_min_down,
    output reg adj_hour_up, output reg adj_hour_down,
    output reg adj_day_up,  output reg adj_day_down,
    output reg adj_mon_up,  output reg adj_mon_down,
    output reg adj_year_up, output reg adj_year_down
);
    // Lưu mode trước để khi đổi mode thì reset idx về 0 của mode mới
    reg sw_mode_d;

    // 1) Cập nhật idx theo sel_pulse và reset idx khi đổi mode
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sw_mode_d <= 1'b0;
            idx       <= 2'd0;    // bắt đầu tại giờ (hoặc ngày khi chuyển qua date)
        end else begin
            if (sw_mode != sw_mode_d) begin
                sw_mode_d <= sw_mode;
                idx       <= 2'd0;  // khi đổi mode: về mục đầu của mode mới
            end else begin
                sw_mode_d <= sw_mode_d;
                if (sel_pulse == 1'b1) begin
                    if (idx == 2'd2) begin
                        idx <= 2'd0;
                    end else begin
                        idx <= idx + 2'd1;
                    end
                end else begin
                    idx <= idx; // giữ nguyên
                end
            end
        end
    end

    // 2) Giải mã en_* (chỉ 1 cái bật theo mode + idx)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_sec  <= 1'b0; en_min  <= 1'b0; en_hour <= 1'b0;
            en_day  <= 1'b0; en_mon  <= 1'b0; en_year <= 1'b0;
        end else begin
            // mặc định 0
            en_sec  <= 1'b0; en_min  <= 1'b0; en_hour <= 1'b0;
            en_day  <= 1'b0; en_mon  <= 1'b0; en_year <= 1'b0;

            if (sw_mode == 1'b0) begin
                // TIME: 0=HH, 1=MM, 2=SS
                if (idx == 2'd0) begin
                    en_hour <= 1'b1;
                end else if (idx == 2'd1) begin
                    en_min  <= 1'b1;
                end else begin
                    en_sec  <= 1'b1;
                end
            end else begin
                // DATE: 0=DD, 1=MM, 2=YYYY
                if (idx == 2'd0) begin
                    en_day  <= 1'b1;
                end else if (idx == 2'd1) begin
                    en_mon  <= 1'b1;
                end else begin
                    en_year <= 1'b1;
                end
            end
        end
    end

    // 3) Giải mã xung UP/DOWN cho từng counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adj_sec_up  <= 1'b0; adj_sec_down  <= 1'b0;
            adj_min_up  <= 1'b0; adj_min_down  <= 1'b0;
            adj_hour_up <= 1'b0; adj_hour_down <= 1'b0;
            adj_day_up  <= 1'b0; adj_day_down  <= 1'b0;
            adj_mon_up  <= 1'b0; adj_mon_down  <= 1'b0;
            adj_year_up <= 1'b0; adj_year_down <= 1'b0;
        end else begin
            // mặc định 0 mỗi chu kỳ
            adj_sec_up  <= 1'b0; adj_sec_down  <= 1'b0;
            adj_min_up  <= 1'b0; adj_min_down  <= 1'b0;
            adj_hour_up <= 1'b0; adj_hour_down <= 1'b0;
            adj_day_up  <= 1'b0; adj_day_down  <= 1'b0;
            adj_mon_up  <= 1'b0; adj_mon_down  <= 1'b0;
            adj_year_up <= 1'b0; adj_year_down <= 1'b0;

            if (sw_mode == 1'b0) begin
                // TIME
                if (idx == 2'd0) begin
                    if (up_pulse == 1'b1) begin
                        adj_hour_up <= 1'b1;
                    end else begin
                        if (down_pulse == 1'b1) begin
                            adj_hour_down <= 1'b1;
                        end else begin
                            adj_hour_up   <= 1'b0;
                            adj_hour_down <= 1'b0;
                        end
                    end
                end else if (idx == 2'd1) begin
                    if (up_pulse == 1'b1) begin
                        adj_min_up <= 1'b1;
                    end else begin
                        if (down_pulse == 1'b1) begin
                            adj_min_down <= 1'b1;
                        end else begin
                            adj_min_up   <= 1'b0;
                            adj_min_down <= 1'b0;
                        end
                    end
                end else begin
                    if (up_pulse == 1'b1) begin
                        adj_sec_up <= 1'b1;
                    end else begin
                        if (down_pulse == 1'b1) begin
                            adj_sec_down <= 1'b1;
                        end else begin
                            adj_sec_up   <= 1'b0;
                            adj_sec_down <= 1'b0;
                        end
                    end
                end
            end else begin
                // DATE
                if (idx == 2'd0) begin
                    if (up_pulse == 1'b1) begin
                        adj_day_up <= 1'b1;
                    end else begin
                        if (down_pulse == 1'b1) begin
                            adj_day_down <= 1'b1;
                        end else begin
                            adj_day_up   <= 1'b0;
                            adj_day_down <= 1'b0;
                        end
                    end
                end else if (idx == 2'd1) begin
                    if (up_pulse == 1'b1) begin
                        adj_mon_up <= 1'b1;
                    end else begin
                        if (down_pulse == 1'b1) begin
                            adj_mon_down <= 1'b1;
                        end else begin
                            adj_mon_up   <= 1'b0;
                            adj_mon_down <= 1'b0;
                        end
                    end
                end else begin
                    if (up_pulse == 1'b1) begin
                        adj_year_up <= 1'b1;
                    end else begin
                        if (down_pulse == 1'b1) begin
                            adj_year_down <= 1'b1;
                        end else begin
                            adj_year_up   <= 1'b0;
                            adj_year_down <= 1'b0;
                        end
                    end
                end
            end
        end
    end
endmodule
