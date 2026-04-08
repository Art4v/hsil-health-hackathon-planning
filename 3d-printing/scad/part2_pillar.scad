// ============================================================
// Part 2: Base Pillar / Turntable
// Remote Surgical Training Arm — Jaycar Servo Edition
// ============================================================
// Print: upright (pillar standing), supports inside servo pocket
// Time: ~1 hr, ~24g
// ============================================================
// This part bolts onto Horn A (on the base YM2765) at the bottom,
// and holds the shoulder servo (YM2763) in a pocket at the top.
// The whole pillar rotates on the base servo = yaw axis.
//
// NOTE: YM2763 and YM2765 have IDENTICAL body dimensions
// (40.7 × 19.7 × 42.9mm, 55g) — same pocket fits both.
// ============================================================

// === MEASURE YOUR YM2763 WITH CALIPERS AND UPDATE THESE ===
// (shoulder servo — sits in the top pocket)
servo_body_w   = 40.7;   // YM2763 body width (long side)
servo_body_d   = 19.7;   // YM2763 body depth (short side)
servo_body_h   = 42.9;   // YM2763 body height
servo_tab_cc   = 49.0;   // tab hole centre-to-centre — MEASURE THIS
tolerance      = 0.2;    // clearance per side

// Horn bolt pattern (standard 25T plastic horn included with servo)
// Typical 4-arm horn has holes on a ~8-10mm radius from centre
horn_bolt_circle_r = 8.5;  // radius of M2 bolt holes — MEASURE YOUR HORN
horn_center_hole   = 3.5;  // centre access hole for horn screw
m2_hole_dia        = 2.2;  // M2 through-hole with clearance

// Pillar dimensions
wall            = 2.0;    // wall thickness
pillar_w        = servo_body_w + wall * 2 + tolerance * 2;  // ~44.7mm
pillar_d        = servo_body_d + wall * 2 + tolerance * 2;  // ~24.1mm
pillar_h        = 60;     // total height — increased from 55 to accommodate taller YM2765

// Servo pocket at top
// The pocket depth needs to fit the servo body, shaft exits to one side
pocket_depth    = servo_body_h + tolerance;  // ~43.1mm

// Horn mount pad at bottom — solid base for bolting to horn
horn_pad_h      = 6;      // thickness of solid pad

// Wire pass-through
wire_hole_dia   = 6;
wire_hole_z     = 30;     // centre height from bottom

// M3 tab holes for shoulder servo (through pillar walls)
m3_hole_dia     = 3.2;

// === DERIVED ===
pocket_w = servo_body_w + tolerance * 2;
pocket_d = servo_body_d + tolerance * 2;

module pillar() {
    difference() {
        // --- Outer shell ---
        cube([pillar_w, pillar_d, pillar_h]);
        
        // --- Hollow interior (above horn pad, below servo pocket) ---
        translate([wall, wall, horn_pad_h])
            cube([
                pillar_w - wall * 2,
                pillar_d - wall * 2,
                pillar_h - horn_pad_h - wall  // leave top wall for pocket ceiling
            ]);
        
        // --- Servo pocket from top ---
        // Centred in X and Y, open at top
        translate([
            (pillar_w - pocket_w) / 2,
            (pillar_d - pocket_d) / 2,
            pillar_h - pocket_depth
        ])
            cube([pocket_w, pocket_d, pocket_depth + 1]);
        
        // --- Tab slots for shoulder servo mounting ears ---
        // Tabs extend beyond the body along the width axis
        // Left tab clearance
        translate([
            (pillar_w - servo_tab_cc) / 2 - 5,
            (pillar_d - pocket_d) / 2 - 1,
            pillar_h - pocket_depth
        ])
            cube([10, pocket_d + 2, 4]);
        
        // Right tab clearance  
        translate([
            (pillar_w + servo_tab_cc) / 2 - 5,
            (pillar_d - pocket_d) / 2 - 1,
            pillar_h - pocket_depth
        ])
            cube([10, pocket_d + 2, 4]);
        
        // --- Shaft exit slot on one side of pillar ---
        // Servo shaft needs to poke out the right side (+X)
        // Cut a slot in the right wall for shaft and gear housing
        translate([
            pillar_w - wall - 1,
            (pillar_d - 12) / 2,   // shaft housing ~12mm wide
            pillar_h - pocket_depth - 1
        ])
            cube([wall + 2, 12, 16]);  // tall enough for shaft + gear bulge
        
        // --- M3 mounting holes for shoulder servo tabs ---
        // Standard servo tabs protrude along X axis from body ends.
        // Screws go vertically (Z) down through the tab into the pillar wall.
        // Left tab hole
        translate([
            (pillar_w - servo_tab_cc) / 2,
            pillar_d / 2,
            pillar_h - pocket_depth - 1
        ])
            cylinder(h = pocket_depth + 2, d = m3_hole_dia, $fn = 30);
        
        // Right tab hole
        translate([
            (pillar_w + servo_tab_cc) / 2,
            pillar_d / 2,
            pillar_h - pocket_depth - 1
        ])
            cylinder(h = pocket_depth + 2, d = m3_hole_dia, $fn = 30);
        
        // --- Wire pass-through hole ---
        translate([
            pillar_w / 2,
            -1,
            wire_hole_z
        ])
            rotate([-90, 0, 0])
                cylinder(h = pillar_d + 2, d = wire_hole_dia, $fn = 30);
        
        // --- Horn mount holes in bottom pad ---
        // 4× M2 holes in a cross pattern matching the horn
        for (angle = [0, 90, 180, 270])
            translate([
                pillar_w / 2 + horn_bolt_circle_r * cos(angle),
                pillar_d / 2 + horn_bolt_circle_r * sin(angle),
                -1
            ])
                cylinder(h = horn_pad_h + 2, d = m2_hole_dia, $fn = 30);
        
        // Centre hole for horn screw access
        translate([pillar_w / 2, pillar_d / 2, -1])
            cylinder(h = horn_pad_h + 2, d = horn_center_hole, $fn = 30);
    }
}

pillar();
