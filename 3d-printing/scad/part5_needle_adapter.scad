// ============================================================
// Part 5: Needle Holder Adapter
// Remote Surgical Training Arm — Jaycar Servo Edition
// ============================================================
// Print: upright (standing on end), no supports, ~15 min, ~4g
// PRINT 2-3 SPARES — these are small and easily lost
// ============================================================
// Cylindrical insert that friction-fits into the end-effector's
// 12mm bore. Has a 2mm central bore for 18G blunt practice needle.
// Set-screw flat aligns with the end-effector's M3 set-screw hole.
// ============================================================

// === DIMENSIONS ===
outer_dia       = 11.8;   // prints slightly under 12mm for friction fit into 12.2mm bore
adapter_length  = 30;     // total length
bore_dia        = 2.0;    // central bore for 18G needle (1.27mm OD — loose fit)

// Set-screw flat: a flat recess so the M3 grub screw has a surface to grip
flat_width      = 3.0;    // width of the flat
flat_depth      = 2.0;    // how deep the flat cuts into the cylinder
flat_z          = 10;     // distance from top of adapter to centre of flat
flat_length     = 5;      // length of flat along cylinder axis

// === MODEL ===
module needle_adapter() {
    difference() {
        // Outer cylinder
        cylinder(h = adapter_length, d = outer_dia, $fn = 60);
        
        // Central bore (full length)
        translate([0, 0, -1])
            cylinder(h = adapter_length + 2, d = bore_dia, $fn = 30);
        
        // Set-screw flat (cut a flat face into the side)
        translate([
            outer_dia / 2 - flat_depth,
            -flat_width / 2,
            flat_z - flat_length / 2
        ])
            cube([flat_depth + 1, flat_width, flat_length]);
    }
}

needle_adapter();
