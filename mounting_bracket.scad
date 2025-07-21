// mounting_bracket.scad - Defines a single L-bracket for gantry mounting.
// This part is designed to be manufactured from bent sheet metal.

module mounting_bracket(preview=false) {
    difference() {
        // Create the L-shape from two cubes
        color("darkslategray", preview ? 0.7 : 1)
        union() {
            // Vertical flange (attaches to heater block)
            translate([0, bracket_thickness/2, 0])
            cube([bracket_width, bracket_thickness, bracket_height], center=true);
            
            // Horizontal flange (attaches to MGN12 carriages)
            translate([0, bracket_flange_width/2, -bracket_height/2 + bracket_thickness/2])
            cube([bracket_width, bracket_flange_width, bracket_thickness], center=true);
        }

        // Add holes to mount bracket to the heater block
        heater_mount_holes();

        // Add holes to mount bracket to the MGN12 carriages
        mgn12_mount_holes();
    }
}

// Creates clearance holes to attach the bracket to the heater block
module heater_mount_holes() {
    for(z_pos = [-bracket_height/2 + bolt_margin*2, 0, bracket_height/2 - bolt_margin*2]) {
         translate([0,0,z_pos])
         rotate([0,90,0])
         cylinder(d=m3_clearance_dia, h=bracket_thickness+0.2, center=true);
    }
}

// Creates the mounting holes for two MGN12 carriages
module mgn12_mount_holes() {
    // Position for the first carriage
    translate([0, bracket_flange_width/2, -bracket_height/2 + bracket_thickness/2]) {
        for(x_pos = [-carriage_separation/2, carriage_separation/2]) {
            translate([x_pos, 0, 0])
            mgn12_hole_pattern();
        }
    }
}

// Defines the 4-hole pattern for a single MGN12 carriage
module mgn12_hole_pattern() {
    for (x_pos = [-mgn12_spacing_x/2, mgn12_spacing_x/2]) {
        for (y_pos = [-mgn12_spacing_y/2, mgn12_spacing_y/2]) {
            translate([x_pos, y_pos, 0]) {
                cylinder(d=m3_clearance_dia, h=bracket_thickness+0.2, center=true);
            }
        }
    }
}
