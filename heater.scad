// heater.scad - Defines the heater block with integrated side mounting wings.
// Main module to generate the heater block part.
module heater_block(preview=false) {
    difference() {
        // Main Body (no wings)
        color("lightgray", preview ? 0.7 : 1)
        cube([block_width, block_depth, heater_block_height], center=true);
        
        // Subtract all the necessary holes
        grid_map("nozzle_hole");
        grid_map("heater_hole");
        grid_map("mounting_hole"); // This now calls the side tapped holes
        thermistor_hole_assembly();
    }
}


// Creates the mounting holes for two MGN12 carriages on each side wing
module mgn12_side_mounts() {
    // Left Side Mounts
    translate([-block_width/2 - side_wing_width/2, 0, 0]) {
        for (y_pos = [-carriage_separation/2, carriage_separation/2]) {
            translate([0, y_pos, 0]) mgn12_hole_pattern();
        }
    }
    // Right Side Mounts
    translate([block_width/2 + side_wing_width/2, 0, 0]) {
        for (y_pos = [-carriage_separation/2, carriage_separation/2]) {
            translate([0, y_pos, 0]) mgn12_hole_pattern();
        }
    }
}

// Defines the 4-hole pattern for a single MGN12 carriage
module mgn12_hole_pattern() {
    for (x_pos = [-mgn12_spacing_y/2, mgn12_spacing_y/2]) {
        for (y_pos = [-mgn12_spacing_x/2, mgn12_spacing_x/2]) {
            translate([x_pos, y_pos, 0]) {
                // Use a slightly larger cylinder for subtraction to prevent artifacts
                rotate([90,0,0])
                cylinder(d=m3_clearance_dia, h=side_wing_width + 0.2, center=true);
            }
        }
    }
}

// Defines a single hole for a nozzle (bottom) and heat break (top)
module nozzle_and_heatbreak_hole() {
    translate([0, 0, -heater_block_height/2]) cylinder(h = nozzle_thread_depth + 0.1, d = nozzle_tap_dia);
    translate([0, 0, heater_block_height/2]) rotate([180, 0, 0]) cylinder(h = heatbreak_thread_depth + 0.1, d = heatbreak_tap_dia);
    cylinder(h = heater_block_height + 0.2, d = filament_path_dia, center = true);
}
// heater.scad - Defines the heater block, now with side holes for L-brackets.

module top_mounting_holes() {
    for (x_pos = [-block_width/2 + bolt_margin : block_width/2 - bolt_margin*2 : block_width/2 - bolt_margin]) {
        for (y_pos = [-block_depth/2 + bolt_margin, block_depth/2 - bolt_margin]) {
            translate([x_pos, y_pos, 0])
            cylinder(d=bolt_dia_tap, h=heater_block_height+0.2, center=true);
        }
    }
}

// Creates tapped holes on the side faces for the L-brackets
module side_tapped_holes() {
    // Left side holes
    for (y_pos = [-bracket_height/2 + bolt_margin : bracket_height/2 - bolt_margin]) {
        translate([-block_width/2, y_pos, 0]) {
             rotate([0,-90,0])
             cylinder(d=bolt_dia_tap, h=wall_margin+0.2, center=true);
        }
    }
    // Right side holes
    for (y_pos = [-bracket_height/2 + bolt_margin : bracket_height/2 - bolt_margin]) {
        translate([block_width/2, y_pos, 0]) {
             rotate([0,90,0])
             cylinder(d=bolt_dia_tap, h=wall_margin+0.2, center=true);
        }
    }
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
