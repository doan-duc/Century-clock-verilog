---

# Century Clock (Verilog)

A **digital clock/calendar** (accurate to calendar rules) implemented in **Verilog**, designed to run on FPGA boards. The project provides counters for seconds/minutes/hours/days/months/years, generates a 1 Hz pulse from the system clock, supports time adjustment via push-buttons (with debounce and one-pulse logic), and decodes values for 7-segment display.

---

## ✨ Features

* **Full time & calendar chain**: second → minute → hour → day → month → year.
* **Time adjustment via buttons** (with debounce & one-pulse); select the field to adjust.
* **Clock divider to 1 Hz** from a high-frequency system clock.
* **7-segment output** through BCD conversion (0–99 helper) + BCD→7SEG.
* **Blinking** to indicate the field currently being adjusted.

## 🧱 Module Overview

Modules are grouped by functionality:

* **Top-level**

  * `top_level.v`: integrates all sub-blocks, maps I/O to FPGA pins.

* **Time keeping & adjustment**

  * `clock_divider_1s.v`: generates 1 Hz tick from system clock.
  * `count_adjust_sec.v`, `count_adjust_min.v`, `count_adjust_hour.v`.
  * `count_adjust_day.v`, `count_adjust_month.v`, `count_adjust_year.v` (calendar rules: days/months, leap years).
  * `adjust_select.v`: selects which field (sec/min/hour/day/month/year) to adjust.

* **User interaction / UX**

  * `btn_onepulse.v`: converts a mechanical button press into a clean one-cycle pulse.
  * `clock_blink.v`: generates blinking signal to highlight the field being adjusted.

* **Display**

  * `bcd_0_99.v`: splits value into tens/ones (2 digits).
  * `bcd_to_7seg.v`: maps BCD → 7-segment outputs (a–g).

> ⚙️ **TODO**: If multiple 7-segment LEDs are used, add a scan/mux driver module and describe it here.

## 🗂️ Suggested Project Structure

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
└─ top_level.v   # set this as the top module when synthesizing
```

## ⚙️ How It Works (pipeline)

1. **`clock_divider_1s`** takes the system clock → generates a 1 Hz tick (⚙️ **TODO**: confirm input clock frequency and divider constant).
2. **Counters** (`count_adjust_*`) increment on each 1 Hz tick and propagate carry to the next field; in **adjust mode**, the selected field increments on button press.
3. **Calendar logic** in `day/month/year` ensures correct 28/29/30/31 days and leap years.
4. **Display**: values pass through `bcd_0_99` and `bcd_to_7seg` to drive the 7-segment; `clock_blink` can hide/blink the currently adjusted field.

## 🙌 Credits

* Author: Doan Sinh Duc
* Course/Project: Digital Design

---
