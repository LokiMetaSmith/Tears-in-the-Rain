// heater.scad - Defines the heater block for bottom-mounting with L-brackets.
// This file is intended to be included by assembly.scad and will not render correctly on its own.

// Defines a single through-hole for a nozzle and heatbreak, to be tapped from the top.
include <helpers.scad>;
module nozzle_and_heatbreak_hole() {
    // A single cylinder for the tap drill hole. Goes all the way through.
    // The nozzle and heatbreak use the same M6 thread, so one diameter is sufficient.
    cylinder(h = heater_block_height + 0.2, d = nozzle_tap_dia, center = true);
}

// Defines a single hole for a heater cartridge
module heater_hole() {
    cylinder(h = heater_block_height + 0.2, d = heater_cartridge_dia, center = true);
}

// Defines the hole for the thermistor and its grub screw
module thermistor_hole_assembly() {
    rotate([0,90,0]) cylinder(h=block_width+0.2, d=thermistor_cartridge_dia, center=true);
    translate([0, -block_depth/2, 0]) rotate([90,0,0]) cylinder(h=wall_margin+0.1, d=thermistor_grub_screw_tap_dia);
}

// Creates tapped holes on the top surface for the main assembly bolts
module main_assembly_bolt_tapped_holes() {
    bolt_thread_depth = 8; // How deep the bolts thread into the heater block
    for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
        // Holes on the negative Y side
        translate([x_pos, -block_depth/2 + bracket_flange_width/2, heater_block_height/2])
        rotate([180,0,0]) // Model threads from the top face
        cylinder(d=bolt_dia_tap, h=bolt_thread_depth, center=false);

        // Holes on the positive Y side
        translate([x_pos, block_depth/2 - bracket_flange_width/2, heater_block_height/2])
        rotate([180,0,0]) // Model threads from the top face
        cylinder(d=bolt_dia_tap, h=bolt_thread_depth, center=false);
    }
}

// Creates tapped holes on the sides for mounting the C-brackets
module bracket_mounting_holes() {
    hole_depth = 8;
    hole_positions_x = [-block_width/4, 0, block_width/4];

    // Holes on the -y side
    for (x_pos = hole_positions_x) {
        translate([x_pos, -block_depth/2, 0])
        rotate([0, 90, 0])
        cylinder(d=bolt_dia_tap, h=hole_depth);
    }
    // Holes on the +y side
    for (x_pos = hole_positions_x) {
        translate([x_pos, block_depth/2, 0])
        rotate([0, -90, 0])
        cylinder(d=bolt_dia_tap, h=hole_depth);
    }
}

// Main module to generate the heater block part.
module heater_block(preview=false) {
    difference() {
        // Main Body (simple rectangle)
        color("lightgray", preview ? 0.7 : 1)
        cube([block_width, block_depth, heater_block_height], center=true);

        // Subtract all the necessary holes
        grid_map("nozzle_hole");
        grid_map("heater_hole");
        main_assembly_bolt_tapped_holes(); // Use tapped holes instead of clearance
        thermistor_hole_assembly();
        bracket_mounting_holes(); // Add side holes for brackets
    }
}
