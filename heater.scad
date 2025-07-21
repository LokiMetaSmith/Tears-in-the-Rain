// heater.scad - Defines the heater block for side-mounting with L-brackets.
// This file is intended to be included by assembly.scad and will not render correctly on its own.

// Defines a single hole for a nozzle (bottom) and heat break (top)
module nozzle_and_heatbreak_hole() {
    translate([0, 0, -heater_block_height/2]) cylinder(h = nozzle_thread_depth + 0.1, d = nozzle_tap_dia);
    translate([0, 0, heater_block_height/2]) rotate([180, 0, 0]) cylinder(h = heatbreak_thread_depth + 0.1, d = heatbreak_tap_dia);
    cylinder(h = heater_block_height + 0.2, d = filament_path_dia, center = true);
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

// Creates tapped M3 holes on the side faces for the L-brackets
module side_tapped_holes() {
    // Left side holes
    for (z_pos = [-heater_block_height/2 + bolt_margin*2, 0, heater_block_height/2 - bolt_margin*2]) {
        translate([-block_width/2, 0, z_pos]) {
             rotate([0,-90,0])
             cylinder(d=bolt_dia_tap, h=wall_margin+0.2, center=false);
        }
    }
    // Right side holes
    for (z_pos = [-heater_block_height/2 + bolt_margin*2, 0, heater_block_height/2 - bolt_margin*2]) {
        translate([block_width/2, 0, z_pos]) {
             rotate([0,90,0])
             cylinder(d=bolt_dia_tap, h=wall_margin+0.2, center=false);
        }
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
        grid_map("mounting_hole");
        thermistor_hole_assembly();
    }
}
