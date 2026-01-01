// mounting_plate.scad - Defines the top gantry mounting plate.
include <config.scad>;

module mounting_plate(preview=false) {
    difference() {
        color("darkslategray", preview ? 0.7 : 1)
        cube([block_width, block_depth, mounting_plate_thickness], center=true);

        // Clearance holes for bolts going down to heater block
        top_mounting_holes_clearance();
        
        // Holes to mount this plate to the MGN12 carriages
        mgn12_mount_holes();
    }
}

module top_mounting_holes_clearance() {
    for (x_pos = [-block_width/2 + bolt_margin : block_width/2 - bolt_margin*2 : block_width/2 - bolt_margin]) {
        for (y_pos = [-block_depth/2 + bolt_margin, block_depth/2 - bolt_margin]) {
            translate([x_pos, y_pos, 0])
            cylinder(d=m3_clearance_dia, h=mounting_plate_thickness+0.2, center=true);
        }
    }
}

module mgn12_mount_holes() {
    for (y_pos = [-carriage_separation/2, carriage_separation/2]) {
        translate([0, y_pos, 0]) {
            for (x_pos = [-mgn12_spacing_x/2, mgn12_spacing_x/2]) {
                translate([x_pos, 0, 0])
                cylinder(d=m3_clearance_dia, h=mounting_plate_thickness+0.2, center=true);
            }
        }
    }
}
