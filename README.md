# Đồng Hồ Thế Kỷ (Verilog)

Đồng hồ/lịch số **chính xác theo lịch** được hiện thực bằng **Verilog**, hướng tới chạy trên các bo mạch FPGA. Dự án cung cấp các bộ đếm giây/phút/giờ/ngày/tháng/năm, tạo xung 1 Hz từ clock hệ thống, chỉnh thời gian bằng nút nhấn (kèm khử dội và one‑pulse), và giải mã hiển thị 7‑segment.

---

## ✨ Tính năng

* **Chuỗi thời gian & lịch đầy đủ**: giây → phút → giờ → ngày → tháng → năm.
* **Chỉnh thời gian bằng nút nhấn** (có khử dội & xung một nhịp one‑pulse); chọn trường cần chỉnh.
* **Chia clock 1 Hz** từ clock hệ thống tần số cao.
* **Xuất 7‑segment** qua chuyển BCD (trợ giúp 0–99) + BCD→7SEG.
* **Nháy/blink** để báo trường đang được chỉnh.

## 🧱 Tổng quan module

Các module Verilog được nhóm theo chức năng:

* **Top‑level**

  * `top_level.v`: ghép nối toàn bộ khối con, map I/O ra chân bo mạch.

* **Giữ thời gian & chỉnh**

  * `clock_divider_1s.v`: tạo xung kích hoạt 1 Hz từ clock hệ thống.
  * `count_adjust_sec.v`, `count_adjust_min.v`, `count_adjust_hour.v`.
  * `count_adjust_day.v`, `count_adjust_month.v`, `count_adjust_year.v` (quy tắc lịch: số ngày/tháng, năm nhuận).
  * `adjust_select.v`: chọn trường (sec/min/hour/day/month/year) để chỉnh.

* **Tương tác người dùng / UX**

  * `btn_onepulse.v`: chuyển nút cơ khí thành xung 1 chu kỳ sạch.
  * `clock_blink.v`: tạo tín hiệu nháy để chớp trường đang chỉnh.

* **Hiển thị**

  * `bcd_0_99.v`: tách giá trị thành hàng chục/hàng đơn vị (2 chữ số).
  * `bcd_to_7seg.v`: ánh xạ BCD → 7 thanh (a–g).

> ⚙️ **TODO**: nếu dùng nhiều LED 7‑seg cần quét/mux, thêm module scan driver và mô tả tại đây.

## 🗂️ Gợi ý cấu trúc dự án

```
century-clock-verilog/
├─ adjust_select.v
├─ bcd_0_99.v
├─ bcd_to_7seg.v
├─ btn_onepulse.v
├─ clock_blink.v
├─ clock_divider_1s.v
├─ count_adjust_day.v
├─ count_adjust_hour.v
├─ count_adjust_min.v
├─ count_adjust_month.v
├─ count_adjust_sec.v
├─ count_adjust_year.v
└─ top_level.v   # đặt module này làm top khi tổng hợp
```

## ⚙️ Cách hoạt động (pipeline)

1. **`clock_divider_1s`** lấy clock hệ thống → sinh tick 1 Hz (⚙️ **TODO**: xác nhận tần số clock vào và hằng chia).
2. **Bộ đếm** (`count_adjust_*`) tăng theo tick 1 Hz và tạo carry sang trường kế; ở **chế độ chỉnh**, trường được chọn sẽ tăng theo nút nhấn.
3. **Logic lịch** trong `day/month/year` đảm bảo đúng 28/29/30/31 ngày và năm nhuận.
4. **Hiển thị**: giá trị đi qua `bcd_0_99` và `bcd_to_7seg` để ra 7‑seg; `clock_blink` có thể tắt/nháy trường đang chỉnh.

## 🙌 Ghi công

* Tác giả: Doan Sinh Duc
* Môn học/Dự án: Digital design
