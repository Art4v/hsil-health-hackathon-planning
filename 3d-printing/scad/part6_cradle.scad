// ============================================================
// Part 6: Silicone Arm Cradle (optional)
// Remote Surgical Training Arm — Jaycar Servo Edition
// ============================================================
// Print: flat (open side up), no supports, ~1.5 hr, ~35g
// ============================================================
// U-shaped cradle that holds the silicone practice arm in place
// and prevents it from rolling during needle approach.
// Bolts to the table with M4 bolts alongside the base plate.
// ============================================================

// === DIMENSIONS ===
cradle_length   = 160;    // along arm axis (X)
cradle_width    = 100;    // across (Y)
cradle_height   = 30;     // Z height of walls

// Channel for silicone arm
channel_radius  = 42;     // ~80mm diameter arm → ~40mm radius + clearance
channel_depth   = 25;     // how deep the channel cuts from the top

// M4 bolt holes for table clamping
m4_hole_dia     = 4.2;
m4_inset_x      = 10;
m4_inset_y      = 10;

// End wall thickness
end_wall        = 10;

// === MODEL ===
module arm_cradle() {
    // Simple U-shaped channel: a block with a rectangular trough cut from the top
    // The silicone arm sits in the trough and the walls prevent rolling.
    
    channel_w = 85;  // width of channel (slightly wider than ~80mm arm)
    
    difference() {
        // Outer block
        cube([cradle_length, cradle_width, cradle_height]);
        
        // Rectangular channel cut from top
        // Centred in Y, inset from ends in X
        translate([
            end_wall,
            (cradle_width - channel_w) / 2,
            cradle_height - channel_depth
        ])
            cube([cradle_length - end_wall * 2, channel_w, channel_depth + 1]);
        
        // M4 corner holes (4×)
        for (x = [m4_inset_x, cradle_length - m4_inset_x])
            for (y = [m4_inset_y, cradle_width - m4_inset_y])
                translate([x, y, -1])
                    cylinder(h = cradle_height + 2, d = m4_hole_dia, $fn = 30);
    }
}

arm_cradle();
