# OpenSCAD Parts — Remote Surgical Training Arm (Jaycar Edition)

## Servo Mapping

| Original Spec | Jaycar Replacement | Used In |
|---|---|---|
| FEETECH FS5109M (base) | Jaycar YM2765 (×1) — 11 kg·cm | Base yaw |
| FEETECH FS5109M (shoulder) | Jaycar YM2763 (×1) — 13 kg·cm | Shoulder pitch |
| FEETECH FT-1018M (×1) | Jaycar YM2758 / SG90 (×1) | Needle angle (wrist) |

Note: YM2763 and YM2765 have identical body dimensions (40.7 × 19.7 × 42.9mm).
The same pockets fit both. YM2763 has higher torque (13 vs 11 kg·cm) so it goes
at the shoulder where it's needed most.

## Files

| File | Part | Print Time | Supports? |
|---|---|---|---|
| `part1_base_plate.scad` | Base plate (100×100×6mm) | ~45 min | No |
| `part2_pillar.scad` | Pillar / turntable | ~1 hr | Yes (inside pocket) |
| `part3_arm_link.scad` | Upper arm link (120mm) | ~1.25 hr | Yes (inside pocket) |
| `part4_end_effector.scad` | Needle holder bracket | ~35 min | No (print on side) |
| `part5_needle_adapter.scad` | Needle adapter cylinder | ~15 min | No |
| `part6_cradle.scad` | Silicone arm cradle | ~1.5 hr | No |

## CRITICAL: Measure Before Printing

Every file has a parameter block at the top marked `=== MEASURE ===`. Before printing,
measure your actual Jaycar servos with digital calipers and update:

1. **YM2765 body dimensions** — the listed 40.7 × 19.7 × 42.9mm are from the Jaycar 
   product page but your unit may vary by ±0.5mm
2. **YM2765 tab hole centre-to-centre** — Jaycar doesn't publish this. Hold the servo 
   up to a ruler or use calipers across the mounting ear holes. Standard servos are 
   typically 49mm but verify.
3. **YM2758 (SG90) body and ear dimensions** — measure body width, ear-to-ear span, 
   and ear hole spacing
4. **Horn bolt circle radius** — put the included plastic horn on a flat surface and 
   measure from centre to any bolt hole. This is usually 7-9mm for standard horns.

## Print Settings

- Material: PLA (PETG if available)
- Layer height: 0.2mm
- Infill: 30% gyroid
- Walls: 3 perimeters (1.2mm with 0.4mm nozzle)
- Printer: Ender 3 (220×220mm bed) — all parts fit

## Print Order (recommended)

1. **Part 5** (needle adapter) — fastest, tests your printer calibration
2. **Part 1** (base plate) — test fit YM2765 in pocket, verify M3 tab holes
3. **Part 2** (pillar) — test fit second YM2765 in top pocket
4. **Part 3** (arm link) — test fit SG90 in distal pocket
5. **Part 4** (end-effector) — test bore diameter with adapter
6. **Part 6** (cradle) — last, optional

## Assembly Sequence

1. Drop YM2765 into base plate pocket, secure with 2× M3 screws
2. Press Horn A onto YM2765 shaft, tighten centre screw
3. Bolt pillar base pad to Horn A (4× M2)
4. Drop YM2763 into pillar top pocket, secure with 2× M3 screws
5. Press Horn B onto YM2763 shaft, bolt arm link proximal end (4× M2)
6. Drop YM2758 into arm link distal pocket (ears rest on ledges), secure with M2 screws
7. Press Horn C onto YM2758 shaft, bolt end-effector bracket (4× M2)
8. Insert needle adapter into bore, tighten M3 set screw
9. Insert blunt practice needle

## Wiring (GPIO-direct, no PCA9685)

```
5V USB charger ──┬── Red wires (all 3 servos V+)
                  └── Brown wires (all 3 servos GND) ──── Pi GND pin
                  
Pi GPIO 12 ─── YM2765 signal (base yaw)
Pi GPIO 13 ─── YM2763 signal (shoulder pitch)
Pi GPIO 18 ─── YM2758 signal (needle angle)
```

Use `pigpio` library for hardware-timed PWM. Remember: servo GND and Pi GND 
must be connected together.
