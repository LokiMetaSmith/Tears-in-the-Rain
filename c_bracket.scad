// c_bracket.scad - Defines a bracket for mounting to pillow block linear rails.
// This file is intended to be included by assembly.scad.

// Creates the 4-hole pattern for a standard pillow block (e.g., SBR12UU)
module pillow_block_mount_holes() {
    for (y_pos = [-pillow_block_hole_spacing_y/2, pillow_block_hole_spacing_y/2]) {
        for (x_pos = [-pillow_block_hole_spacing_x/2, pillow_block_hole_spacing_x/2]) {
            translate([x_pos, y_pos, 0]) {
                cylinder(d=pillow_block_bolt_dia, h=bracket_thickness+0.2, center=true);
            }
        }
    }
}

// Creates clearance holes on the vertical plate to mount to the heater block
module heater_mount_holes() {
    hole_positions_x = [-block_width/4, 0, block_width/4];
    for(x_pos = hole_positions_x) {
         translate([x_pos, 0, 0])
         rotate([0,90,0])
         cylinder(d=bolt_dia_clearance, h=bracket_thickness+0.2, center=true);
    }
}

// Main module to generate the bracket part.
module c_bracket(preview=false) {
    difference() {
        // Create the bracket shape
        color("darkslategray", preview ? 0.7 : 1)
        union() {
            // Vertical Plate (attaches to heater block)
            translate([0, 0, bracket_height/2])
            cube([block_width, bracket_thickness, bracket_height], center=true);

            // Top Flange (attaches to pillow block)
            translate([0, bracket_flange_width/2, bracket_height - bracket_thickness/2])
            cube([block_width, bracket_flange_width, bracket_thickness], center=true);
        }

        // --- Subtract Holes ---

        // Holes on Top Flange for Pillow Blocks
        translate([ -carriage_separation / 2, bracket_flange_width, bracket_height])
        pillow_block_mount_holes();

        translate([ carriage_separation / 2, bracket_flange_width, bracket_height])
        pillow_block_mount_holes();

        // Holes on Vertical Plate for mounting to heater block
        translate([0, 0, 0])
        heater_mount_holes();
    }
}
