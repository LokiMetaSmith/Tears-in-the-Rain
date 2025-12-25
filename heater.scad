// heater.scad - Defines the heater block for bottom-mounting with L-brackets.
// This file is intended to be included by assembly.scad and will not render correctly on its own.

include <config.scad>;
include <helpers.scad>;
include <hardware.scad>;

// Creates clearance holes for the main assembly bolts to pass through
module main_assembly_bolt_clearance() {
    for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
        translate([x_pos, -block_depth/2 + bracket_flange_width/2, 0])
        cylinder(d=m3_clearance_dia, h=heater_block_height+0.2, center=true);
        
        translate([x_pos, block_depth/2 - bracket_flange_width/2, 0])
        cylinder(d=m3_clearance_dia, h=heater_block_height+0.2, center=true);
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
        main_assembly_bolt_clearance();
        thermistor_hole_assembly();
    }
}
