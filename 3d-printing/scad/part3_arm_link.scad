// ============================================================
// Part 3: Upper Arm Link
// Remote Surgical Training Arm — Jaycar Servo Edition
// ============================================================
// Print: flat (wide face down), supports inside SG90 pocket
// Time: ~1.25 hr, ~20g
// ============================================================
// Proximal end: bolts to Horn B on shoulder YM2763
// Distal end: holds YM2758 (SG90 micro servo) for needle angle
// The SG90 mounts via its ear flanges sitting on top of the pocket.
// Shaft points downward (perpendicular to arm plane).
// ============================================================

// === HORN PARAMETERS (same 25T horn as YM2763/YM2765) ===
horn_bolt_circle_r = 8.5;  // M2 bolt hole radius on horn — MEASURE
horn_center_hole   = 3.5;  // horn screw access hole
m2_hole_dia        = 2.2;

// === SG90 (YM2758) DIMENSIONS — MEASURE WITH CALIPERS ===
sg90_body_w     = 22.8;   // body width (not including ears)
sg90_body_d     = 12.2;   // body depth
sg90_body_h     = 22.5;   // body height (below ears)
sg90_ear_w      = 32.5;   // total width including both mounting ears
sg90_ear_h      = 2.5;    // ear thickness
sg90_ear_z      = 16.0;   // height from bottom of body to bottom of ears
sg90_tab_cc     = 28.0;   // ear hole centre-to-centre — MEASURE
sg90_shaft_offset = 5.5;  // shaft centre offset from body centre (along width)
sg90_tolerance  = 0.2;    // per-side clearance

// === ARM LINK DIMENSIONS ===
arm_length      = 120;    // total length
arm_w_prox      = 25;     // proximal width (horn mount end)
arm_w_dist      = 35;     // distal width — wider to accommodate SG90 ear span (32.5mm)
arm_h           = 18;     // height/thickness
wall            = 2.0;    // wall thickness
step_start      = 80;     // X position where arm starts widening to distal width

// Horn mount pad at proximal end
horn_pad_len    = 10;     // length of solid section for horn bolts
horn_pad_h      = 4;      // extra solid pad thickness above hollow

// SG90 pocket at distal end
// The SG90 drops into a pocket with ears resting on top edges
sg90_pocket_len = sg90_body_d + sg90_tolerance * 2;  // pocket along arm length axis
sg90_pocket_w   = sg90_body_w + sg90_tolerance * 2;  // pocket across arm width
sg90_pocket_h   = sg90_ear_z + sg90_tolerance;       // depth below ears

// Ear slot dimensions (for the flanges to sit on)
// Ears overhang — slot is full width of distal section
ear_slot_w      = sg90_ear_w + sg90_tolerance * 2;
ear_slot_d      = sg90_ear_h + sg90_tolerance;

// Cable channel
cable_w         = 5;
cable_h         = 5;

// Zip-tie slots
zip_w           = 8;
zip_h           = 3;

module arm_link() {
    difference() {
        union() {
            // --- Proximal section (narrow) ---
            cube([step_start, arm_w_prox, arm_h]);
            
            // --- Distal section (wide, for SG90 ears) ---
            translate([step_start, -(arm_w_dist - arm_w_prox) / 2, 0])
                cube([arm_length - step_start, arm_w_dist, arm_h]);
        }
        
        // --- Hollow interior in proximal section ---
        translate([horn_pad_len, wall, wall])
            cube([
                step_start - horn_pad_len - wall,
                arm_w_prox - wall * 2,
                arm_h - wall * 2
            ]);
        
        // --- Hollow interior in distal section (up to SG90 pocket) ---
        translate([step_start + wall, -(arm_w_dist - arm_w_prox) / 2 + wall, wall])
            cube([
                arm_length - step_start - sg90_pocket_len - wall * 3,
                arm_w_dist - wall * 2,
                arm_h - wall * 2
            ]);
        
        // --- Horn mount holes at proximal end (X=0 face) ---
        for (angle = [0, 90, 180, 270])
            translate([
                -1,
                arm_w_prox / 2 + horn_bolt_circle_r * cos(angle),
                arm_h / 2 + horn_bolt_circle_r * sin(angle)
            ])
                rotate([0, 90, 0])
                    cylinder(h = horn_pad_len + 2, d = m2_hole_dia, $fn = 30);
        
        // Horn centre screw access
        translate([-1, arm_w_prox / 2, arm_h / 2])
            rotate([0, 90, 0])
                cylinder(h = horn_pad_len + 2, d = horn_center_hole, $fn = 30);
        
        // --- SG90 pocket at distal end ---
        // Centred in the wider distal section
        dist_centre_y = -(arm_w_dist - arm_w_prox) / 2 + arm_w_dist / 2;
        
        translate([
            arm_length - wall - sg90_pocket_len,
            dist_centre_y - sg90_pocket_w / 2,
            -1
        ])
            cube([sg90_pocket_len, sg90_pocket_w, sg90_pocket_h + 1]);
        
        // --- Ear slots at ear height ---
        translate([
            arm_length - wall - sg90_pocket_len - wall,
            dist_centre_y - ear_slot_w / 2,
            sg90_pocket_h - 1
        ])
            cube([sg90_pocket_len + wall * 2 + 2, ear_slot_w, ear_slot_d + 1]);
        
        // --- SG90 mounting tab holes (vertical through top into ears) ---
        translate([
            arm_length - wall - sg90_pocket_len / 2,
            dist_centre_y - sg90_tab_cc / 2,
            -1
        ])
            cylinder(h = arm_h + 2, d = m2_hole_dia, $fn = 30);
        
        translate([
            arm_length - wall - sg90_pocket_len / 2,
            dist_centre_y + sg90_tab_cc / 2,
            -1
        ])
            cylinder(h = arm_h + 2, d = m2_hole_dia, $fn = 30);
        
        // --- Shaft exit hole through bottom ---
        translate([
            arm_length - wall - sg90_pocket_len / 2 + sg90_shaft_offset,
            dist_centre_y,
            -1
        ])
            cylinder(h = wall + 2, d = 10, $fn = 30);
        
        // --- Cable channel along bottom interior ---
        translate([horn_pad_len / 2, (arm_w_prox - cable_w) / 2, -1])
            cube([step_start - horn_pad_len / 2, cable_w, cable_h + 1]);
        
        // Continue cable channel into distal section
        translate([step_start, dist_centre_y - cable_w / 2, -1])
            cube([arm_length - step_start - sg90_pocket_len, cable_w, cable_h + 1]);
        
        // --- Zip-tie slots at 1/3 and 2/3 length ---
        translate([arm_length / 3 - zip_w / 2, -1, -1])
            cube([zip_w, arm_w_prox + 2, zip_h + 1]);
        
        translate([arm_length * 2 / 3 - zip_w / 2, 
                   -(arm_w_dist - arm_w_prox) / 2 - 1, -1])
            cube([zip_w, arm_w_dist + 2, zip_h + 1]);
    }
}

arm_link();
