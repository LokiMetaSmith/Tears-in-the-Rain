// mounting_plate.scad - Defines the gantry mounting plate.

// Main module to generate the gantry plate part.
module mounting_plate(preview=false) {
    difference() {
        // Main Plate Body
        color("darkslategray", preview ? 0.7 : 1)
        cube([plate_width, plate_depth, plate_thickness], center=true);

        // Holes to mount the plate to the MGN12 carriages
        mgn12_mount_holes();

        // Holes to mount the heater block to this plate
        heater_block_mount_holes();
    }
}

// Creates the mounting holes for two MGN12 carriages
module mgn12_mount_holes() {
    // Position for the first carriage (left)
    translate([-carriage_separation / 2, 0, 0]) {
        for (x_pos = [-mgn12_spacing_x/2, mgn12_spacing_x/2]) {
            for (y_pos = [-mgn12_spacing_y/2, mgn12_spacing_y/2]) {
                translate([x_pos, y_pos, 0]) {
                    // Counterbore for screw head on top
                    translate([0,0, plate_thickness/2 - m3_bolt_head_depth])
                    cylinder(d=m3_bolt_head_dia, h=m3_bolt_head_depth+1);
                    // Clearance hole for M3 screw
                    cylinder(d=m3_clearance_dia, h=plate_thickness+2, center=true);
                }
            }
        }
    }
    // Position for the second carriage (right)
    translate([carriage_separation / 2, 0, 0]) {
        for (x_pos = [-mgn12_spacing_x/2, mgn12_spacing_x/2]) {
            for (y_pos = [-mgn12_spacing_y/2, mgn12_spacing_y/2]) {
                translate([x_pos, y_pos, 0]) {
                    translate([0,0, plate_thickness/2 - m3_bolt_head_depth])
                    cylinder(d=m3_bolt_head_dia, h=m3_bolt_head_depth+1);
                    cylinder(d=m3_clearance_dia, h=plate_thickness+2, center=true);
                }
            }
        }
    }
}

// Creates the tapped holes to attach the heater block
module heater_block_mount_holes() {
    for (y_pos = [-block_depth/2 + bolt_margin*2 : bolt_margin*2 : block_depth/2 - bolt_margin*2]) {
        translate([0, y_pos, 0]) {
            cylinder(d=bolt_dia_tap, h=plate_thickness+2, center=true);
        }
    }
}
