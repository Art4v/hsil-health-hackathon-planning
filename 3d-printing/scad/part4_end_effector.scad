// ============================================================
// Part 4: End-Effector / Needle Holder Bracket
// Remote Surgical Training Arm — Jaycar Servo Edition
// ============================================================
// Print: on its side (bore horizontal) to avoid supports in bore
// Time: ~35 min, ~9g
// ============================================================
// Top face bolts to Horn C on the YM2758 (SG90) shaft.
// Contains a 12mm bore angled at 25° from vertical for the
// needle adapter. Bore centre is offset 15mm from servo axis
// so the needle tip traces an arc when the angle servo rotates.
// ============================================================

// === HORN PARAMETERS (SG90 included horn — typically same 25T) ===
horn_bolt_circle_r = 7.0;   // SG90 horn bolt circle — often smaller, MEASURE
horn_center_hole   = 3.5;   // horn screw access
m2_hole_dia        = 2.2;

// === BRACKET DIMENSIONS ===
bracket_w       = 45;    // X dimension — widened to contain angled bore
bracket_d       = 32;    // Y dimension (matches arm width area)
bracket_h       = 30;    // Z height

// Horn mount pad on top face
horn_pad_h      = 6;     // solid pad thickness at top

// Tool socket bore
bore_dia        = 12.2;  // print oversize — PLA shrinks ~0.2mm → final ~12.0mm ID
bore_depth      = 20;    // bore depth
bore_angle      = 25;    // degrees from vertical (= from Z axis)
bore_offset_y   = 15;    // bore centre offset from servo rotation axis (Y direction)
// Bore entry point shifted right (+X) so the angled bore stays inside the body
// At 25°, the bore drifts sin(25°)*bore_depth = ~8.5mm in X over 20mm depth
bore_entry_x    = 27;    // bore entry X on bottom face — shifted from centre

// M3 set-screw hole for tool retention
set_screw_dia   = 3.0;   // M3 tap-tight in PLA
set_screw_z     = 10;    // distance from bore opening (= from bottom of bracket)

// Vein alignment ridge on bottom face
ridge_h         = 1;
ridge_l         = 10;
ridge_w         = 1;

module end_effector() {
    difference() {
        union() {
            // --- Main body ---
            cube([bracket_w, bracket_d, bracket_h]);
            
            // --- Vein alignment ridge on bottom ---
            translate([
                (bracket_w - ridge_l) / 2,
                bore_offset_y - ridge_w / 2,
                -ridge_h
            ])
                cube([ridge_l, ridge_w, ridge_h]);
        }
        
        // --- Angled bore for needle adapter ---
        // Bore axis is angled 25° from Z (vertical) in the XZ plane
        // Bore enters from the bottom face, angling toward -X
        // Entry point shifted right so bore stays inside body
        translate([bore_entry_x, bore_offset_y, -1])
            rotate([0, -bore_angle, 0])
                cylinder(h = bore_depth + 2, d = bore_dia, $fn = 60);
        
        // --- M3 set-screw hole (perpendicular to bore) ---
        // Enters from the side of the bracket
        // Positioned at set_screw_z from the bore opening (bottom face)
        translate([
            -1,
            bore_offset_y,
            set_screw_z
        ])
            rotate([0, 90, 0])
                cylinder(h = bracket_w + 2, d = set_screw_dia, $fn = 30);
        
        // --- Horn mount holes on top face ---
        // 4× M2 in cross pattern, centred on bracket top
        // The servo rotation axis aligns with the bracket centre
        for (angle = [0, 90, 180, 270])
            translate([
                bracket_w / 2 + horn_bolt_circle_r * cos(angle),
                bracket_d / 2 + horn_bolt_circle_r * sin(angle),
                bracket_h - horn_pad_h - 1
            ])
                cylinder(h = horn_pad_h + 2, d = m2_hole_dia, $fn = 30);
        
        // Horn centre screw access
        translate([bracket_w / 2, bracket_d / 2, bracket_h - horn_pad_h - 1])
            cylinder(h = horn_pad_h + 2, d = horn_center_hole, $fn = 30);
    }
}

end_effector();
