module top_level(
    input  wire clk,
    input  wire [3:0]  button,       
    input  wire [17:0] SW,        
    output wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7
);
    // Clock & Reset
    wire rst_n = button[3];          // press button3 to reset (active-low -> 0)

    // 1Hz pulse
    wire clk_1s;
    clock_divider_1s #(.CLK_HZ(50_000_000)) u_div (
        .clk(clk), .rst_n(rst_n), .clk_1s(clk_1s)
    );

    // Buttons -> one-pulse
    wire sel_pulse, up_pulse, down_pulse;
    btn_onepulse u_sel  (.clk(clk), .rst_n(rst_n), .btn_n(button[2]), .pulse(sel_pulse));
    btn_onepulse u_up   (.clk(clk), .rst_n(rst_n), .btn_n(button[1]), .pulse(up_pulse));
    btn_onepulse u_down (.clk(clk), .rst_n(rst_n), .btn_n(button[0]), .pulse(down_pulse));

    // Mode switch
    wire sw_mode = SW[0];  // 0=time, 1=date

    // Adjust controller (select + routing)
    wire [1:0] idx;
    wire adjust_active;
    wire en_sec,en_min,en_hour,en_day,en_mon,en_year;
    wire adj_sec_up,adj_sec_down,adj_min_up,adj_min_down,adj_hour_up,adj_hour_down;
    wire adj_day_up,adj_day_down,adj_mon_up,adj_mon_down,adj_year_up,adj_year_down;

    adjust_select u_adj (
        .clk(clk), .rst_n(rst_n),
        .sw_mode(sw_mode),
        .sel_pulse(sel_pulse), .up_pulse(up_pulse), .down_pulse(down_pulse),
        .idx(idx),
        .en_sec(en_sec), .en_min(en_min), .en_hour(en_hour),
        .en_day(en_day), .en_mon(en_mon), .en_year(en_year),
        .adj_sec_up(adj_sec_up),   .adj_sec_down(adj_sec_down),
        .adj_min_up(adj_min_up),   .adj_min_down(adj_min_down),
        .adj_hour_up(adj_hour_up), .adj_hour_down(adj_hour_down),
        .adj_day_up(adj_day_up),   .adj_day_down(adj_day_down),
        .adj_mon_up(adj_mon_up),   .adj_mon_down(adj_mon_down),
        .adj_year_up(adj_year_up), .adj_year_down(adj_year_down)
    );

    // Counters
    wire [5:0] sec, min;
    wire [4:0] hour, day;
    wire [3:0] mon;
    wire [13:0] year;
    wire carry_sec, carry_min, carry_hour, carry_day, carry_mon;

    count_adjust_sec u_sec (
        .clk(clk), .rst_n(rst_n),
        .t_1s(clk_1s),
        .adj_en(en_sec), .adj_up(adj_sec_up), .adj_down(adj_sec_down),
        .sec(sec), .carry_sec(carry_sec)
    );

    count_adjust_min u_min (
        .clk(clk), .rst_n(rst_n),
        .carry_sec(carry_sec),
        .adj_en(en_min), .adj_up(adj_min_up), .adj_down(adj_min_down),
        .min(min), .carry_min(carry_min)
    );

    count_adjust_hour u_hour (
        .clk(clk), .rst_n(rst_n),
        .carry_min(carry_min),
        .adj_en(en_hour), .adj_up(adj_hour_up), .adj_down(adj_hour_down),
        .hour(hour), .carry_hour(carry_hour)
    );

    count_adjust_day u_day (
        .clk(clk), .rst_n(rst_n),
        .carry_hour(carry_hour),
        .adj_en(en_day), .adj_up(adj_day_up), .adj_down(adj_day_down),
        .mon(mon), .year(year),
        .day(day), .carry_day(carry_day)
    );

    count_adjust_month u_mon (
        .clk(clk), .rst_n(rst_n),
        .carry_day(carry_day),
        .adj_en(en_mon), .adj_up(adj_mon_up), .adj_down(adj_mon_down),
        .carry_mon(carry_mon), .mon(mon)
    );

    count_adjust_year u_year (
        .clk(clk), .rst_n(rst_n),
        .carry_mon(carry_mon),
        .adj_en(en_year), .adj_up(adj_year_up), .adj_down(adj_year_down),
        .year(year)
    );

    wire blink;
    clock_blink u_blink (.clk(clk), .rst_n(rst_n), .en(1'b1), .event_clk1s(clk_1s), .blink(blink));

    wire [3:0] s0,s1,m0,m1,h0,h1;
    wire [3:0] d0,d1,mo0,mo1;

    bcd_0_99 u_bcd_sec  (.digit(sec),              .digit0(s0),  .digit1(s1));        // 0..59
    bcd_0_99 u_bcd_min  (.digit(min),              .digit0(m0),  .digit1(m1));        // 0..59
    bcd_0_99 u_bcd_hour (.digit({2'b00,hour}),     .digit0(h0),  .digit1(h1));        // 0..23
    bcd_0_99 u_bcd_day  (.digit({2'b00,day}),      .digit0(d0),  .digit1(d1));        // 1..31
    bcd_0_99 u_bcd_mon  (.digit({3'b000,mon}),     .digit0(mo0), .digit1(mo1));       // 1..12

    // YEAR -> 4 digits (YYYY = y3 y2 y1 y0)
    reg [6:0] y_lo, y_hi;
    always @(year) begin
        y_lo = year % 14'd100;
        y_hi = year / 14'd100;
    end
    wire [3:0] y0,y1,y2,y3;
    bcd_0_99 u_bcd_ylo (.digit(y_lo), .digit0(y0), .digit1(y1)); // ones,tens
    bcd_0_99 u_bcd_yhi (.digit(y_hi), .digit0(y2), .digit1(y3)); // hundreds,thousands

    // Choose digits per mode
    // TIME: HEX5..HEX0 = H1 H0 M1 M0 S1 S0 ; HEX7..HEX6 blank
    // DATE: HEX7..HEX0 = Y3 Y2 Y1 Y0 M1 M0 D1 D0
    wire [3:0] dHEX7 = (sw_mode) ? y3  : 4'd15; // 15 -> blank code later
    wire [3:0] dHEX6 = (sw_mode) ? y2  : 4'd15;
    wire [3:0] dHEX5 = (sw_mode) ? y1  : h1;
    wire [3:0] dHEX4 = (sw_mode) ? y0  : h0;
    wire [3:0] dHEX3 = (sw_mode) ? mo1 : m1;
    wire [3:0] dHEX2 = (sw_mode) ? mo0 : m0;
    wire [3:0] dHEX1 = (sw_mode) ? d1  : s1;
    wire [3:0] dHEX0 = (sw_mode) ? d0  : s0;

    // Blink mask (1=on, 0=off). Active-low display uses "blank" = 7'b1111111
    reg [7:0] en_mask;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_mask <= 8'hFF;
        end else begin
            en_mask <= 8'hFF;
            if (blink == 1'b0) begin
                if (sw_mode == 1'b0) begin
                    // TIME: 0=HH,1=MM,2=SS
                    if (idx == 2'd0)      en_mask[5:4] <= 2'b00;  // HH
                    else if (idx == 2'd1) en_mask[3:2] <= 2'b00;  // MM
                    else                  en_mask[1:0] <= 2'b00;  // SS
                    en_mask[7:6] <= 2'b00; // tắt 2 HEX trên ở time mode
                end else begin
                    // DATE: 0=DD,1=MM,2=YYYY
                    if (idx == 2'd0)      en_mask[1:0] <= 2'b00;   // DD
                    else if (idx == 2'd1) en_mask[3:2] <= 2'b00;   // MM
                    else                  en_mask[7:4] <= 4'b0000; // YYYY
                end
            end
        end
    end

    // 7-seg encode (active-low)
    wire [6:0] seg7,seg6,seg5,seg4,seg3,seg2,seg1,seg0;
    wire [6:0] seg7r,seg6r,seg5r,seg4r,seg3r,seg2r,seg1r,seg0r;
    bcd_to_7seg u7 (.hex_digit(dHEX7), .seg_data(seg7r));
    bcd_to_7seg u6 (.hex_digit(dHEX6), .seg_data(seg6r));
    bcd_to_7seg u5 (.hex_digit(dHEX5), .seg_data(seg5r));
    bcd_to_7seg u4 (.hex_digit(dHEX4), .seg_data(seg4r));
    bcd_to_7seg u3 (.hex_digit(dHEX3), .seg_data(seg3r));
    bcd_to_7seg u2 (.hex_digit(dHEX2), .seg_data(seg2r));
    bcd_to_7seg u1 (.hex_digit(dHEX1), .seg_data(seg1r));
    bcd_to_7seg u0 (.hex_digit(dHEX0), .seg_data(seg0r));

    wire [6:0] blank = 7'b1111111;
    assign HEX7 = en_mask[7] ? seg7r : blank;
    assign HEX6 = en_mask[6] ? seg6r : blank;
    assign HEX5 = en_mask[5] ? seg5r : blank;
    assign HEX4 = en_mask[4] ? seg4r : blank;
    assign HEX3 = en_mask[3] ? seg3r : blank;
    assign HEX2 = en_mask[2] ? seg2r : blank;
    assign HEX1 = en_mask[1] ? seg1r : blank;
    assign HEX0 = en_mask[0] ? seg0r : blank;
endmodule
