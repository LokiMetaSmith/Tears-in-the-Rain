// c_bracket.scad - Defines a bracket for mounting to pillow block linear rails.
include <manufacturing_helpers.scad>;

// --- Original Hole Modules (for 3D rendering) ---
module pillow_block_mount_holes() {
    for (y_pos = [-pillow_block_hole_spacing_y/2, pillow_block_hole_spacing_y/2]) {
        for (x_pos = [-pillow_block_hole_spacing_x/2, pillow_block_hole_spacing_x/2]) {
            translate([x_pos, y_pos, 0]) {
                cylinder(d=pillow_block_bolt_dia, h=bracket_thickness+0.2, center=true);
            }
        }
    }
}
module heater_mount_holes() {
    hole_positions_x = [-block_width/4, 0, block_width/4];
    for(x_pos = hole_positions_x) {
         translate([x_pos, 0, 0])
         rotate([0,90,0])
         cylinder(d=bolt_dia_clearance, h=bracket_thickness+0.2, center=true);
    }
}

// --- Main Module ---
module c_bracket(preview=false) {
    if(generate_data) {
        part_name = "C-Bracket";

        // Pillow Block Mount Holes
        pillow_block_centers = [
            for(x_sign = [-1, 1])
                [x_sign * carriage_separation / 2, bracket_flange_width, bracket_height]
        ];
        for(center = pillow_block_centers) {
            for (y_pos = [-pillow_block_hole_spacing_y/2, pillow_block_hole_spacing_y/2]) {
                for (x_pos = [-pillow_block_hole_spacing_x/2, pillow_block_hole_spacing_x/2]) {
                    pos = center + [x_pos, y_pos, 0];
                    echo_hole(part_name, "Pillow Block Mount", pos, pillow_block_bolt_dia);
                }
            }
        }

        // Heater Block Mount Holes
        heater_hole_positions = [ for(x_pos = [-block_width/4, 0, block_width/4]) [x_pos, 0, 0] ];
        for(pos = heater_hole_positions) {
            echo_hole(part_name, "Heater Block Mount", pos, bolt_dia_clearance);
        }

    } else {
        difference() {
            color("darkslategray", preview ? 0.7 : 1)
            union() {
                translate([0, 0, bracket_height/2])
                cube([block_width, bracket_thickness, bracket_height], center=true);

                translate([0, bracket_flange_width/2, bracket_height - bracket_thickness/2])
                cube([block_width, bracket_flange_width, bracket_thickness], center=true);
            }

            translate([ -carriage_separation / 2, bracket_flange_width, bracket_height])
            pillow_block_mount_holes();

            translate([ carriage_separation / 2, bracket_flange_width, bracket_height])
            pillow_block_mount_holes();

            translate([0, 0, 0])
            heater_mount_holes();
        }
    }
}
