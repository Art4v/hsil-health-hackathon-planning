// ============================================================
// Part 1: Base Plate
// Remote Surgical Training Arm — Jaycar Servo Edition
// ============================================================
// Print: flat (bottom face down), no supports, ~45 min, ~30g
// ============================================================

// === MEASURE YOUR YM2765 WITH CALIPERS AND UPDATE THESE ===
servo_body_w   = 40.7;   // YM2765 body width (mm) — long side
servo_body_d   = 19.7;   // YM2765 body depth (mm) — short side
servo_body_h   = 42.9;   // YM2765 body height (mm) — NOT used for pocket depth here
servo_tab_cc   = 49.0;   // mounting tab hole centre-to-centre (mm) — MEASURE THIS
servo_tab_w    = 7.5;    // width of each mounting tab beyond body
servo_tab_h    = 2.5;    // tab thickness
tolerance      = 0.2;    // clearance per side for pocket fit

// Plate dimensions
plate_w        = 100;    // plate width (X)
plate_d        = 100;    // plate depth (Y)
plate_h        = 6;      // plate thickness (Z)

// Servo pocket — servo drops in from top, body hangs below plate
// Pocket only needs to be deep enough to capture the tabs & top of body
pocket_depth   = 4;      // depth of pocket from top surface

// Shaft position — the YM2765 output shaft is offset from body centre
// On most standard servos, shaft is ~10mm from one end of the body
shaft_offset_x = 10.0;   // shaft centre from edge of body (along width axis)

// M4 corner holes for table clamping
m4_hole_dia    = 4.2;
m4_inset       = 8;      // distance from edge to hole centre

// M3 tab mounting holes
m3_hole_dia    = 3.2;

// Cable exit slot (rear of pocket, through to bottom)
cable_slot_w   = 8;
cable_slot_d   = 6;

// === DERIVED ===
pocket_w = servo_body_w + tolerance * 2;
pocket_d = servo_body_d + tolerance * 2;

// Tab slot dimensions (slots in plate for mounting ears)
tab_slot_w = servo_tab_w + 1;  // extra clearance for tabs
tab_slot_d = servo_body_d + tolerance * 2 + 2;  // slightly wider than pocket

module base_plate() {
    difference() {
        // Main plate body
        cube([plate_w, plate_d, plate_h]);
        
        // --- Servo pocket (centred on plate) ---
        translate([
            (plate_w - pocket_w) / 2,
            (plate_d - pocket_d) / 2,
            plate_h - pocket_depth
        ])
            cube([pocket_w, pocket_d, pocket_depth + 1]);  // +1 to cut through top
        
        // --- Tab slots on each side of pocket ---
        // Tabs extend along the width axis (long side of servo)
        // Left tab slot
        translate([
            (plate_w - servo_tab_cc) / 2 - tab_slot_w / 2,
            (plate_d - tab_slot_d) / 2,
            plate_h - pocket_depth
        ])
            cube([tab_slot_w, tab_slot_d, pocket_depth + 1]);
        
        // Right tab slot
        translate([
            (plate_w + servo_tab_cc) / 2 - tab_slot_w / 2,
            (plate_d - tab_slot_d) / 2,
            plate_h - pocket_depth
        ])
            cube([tab_slot_w, tab_slot_d, pocket_depth + 1]);
        
        // --- M3 tab mounting holes (through plate) ---
        // Left tab hole
        translate([
            (plate_w - servo_tab_cc) / 2,
            plate_d / 2,
            -1
        ])
            cylinder(h = plate_h + 2, d = m3_hole_dia, $fn = 30);
        
        // Right tab hole
        translate([
            (plate_w + servo_tab_cc) / 2,
            plate_d / 2,
            -1
        ])
            cylinder(h = plate_h + 2, d = m3_hole_dia, $fn = 30);
        
        // --- M4 corner holes ---
        for (x = [m4_inset, plate_w - m4_inset])
            for (y = [m4_inset, plate_d - m4_inset])
                translate([x, y, -1])
                    cylinder(h = plate_h + 2, d = m4_hole_dia, $fn = 30);
        
        // --- Cable exit slot (rear of pocket, through entire plate) ---
        translate([
            (plate_w - cable_slot_w) / 2,
            (plate_d - pocket_d) / 2 - cable_slot_d,
            -1
        ])
            cube([cable_slot_w, cable_slot_d + pocket_d / 3, plate_h + 2]);
    }
}

base_plate();
