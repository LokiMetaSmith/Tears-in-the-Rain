// mounting_bracket.scad - Defines a single L-bracket for vertical rail mounting.
// This file is intended to be included by assembly.scad and will not render correctly on its own.

// Defines the 4-hole pattern for a single MGN12 carriage
module mgn12_hole_pattern() {
    for (y_pos = [-mgn12_spacing_y/2, mgn12_spacing_y/2]) {
        for (z_pos = [-mgn12_spacing_x/2, mgn12_spacing_x/2]) {
            translate([0, y_pos, z_pos]) {
                rotate([0,90,0])
                cylinder(d=m3_clearance_dia, h=bracket_thickness+0.2, center=true);
            }
        }
    }
}

// Creates the mounting holes for two MGN12 carriages on the vertical flange
module mgn12_mount_holes() {
    // Position for the first carriage
    translate([0, -carriage_separation / 2, 0]) {
        mgn12_hole_pattern();
    }
    // Position for the second carriage
    translate([0, carriage_separation / 2, 0]) {
        mgn12_hole_pattern();
    }
}

// Creates clearance holes on the horizontal flange to attach to the heater block
module heater_mount_holes() {
    for(x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
         translate([x_pos, 0, 0])
         cylinder(d=m3_clearance_dia, h=bracket_thickness+0.2, center=true);
    }
}

// Main module to generate the L-bracket part.
module mounting_bracket(preview=false) {
    difference() {
        // Create the L-shape
        color("darkslategray", preview ? 0.7 : 1)
        union() {
            // Vertical flange (attaches to linear rail) - In YZ plane
            translate([0, 0, bracket_height/2])
            cube([bracket_thickness, bracket_width, bracket_height], center=true);
            
            // Horizontal flange (attaches to heater block) - In XY plane
            translate([bracket_flange_width/2, 0, bracket_thickness/2])
            cube([bracket_flange_width, bracket_width, bracket_thickness], center=true);
        }

        // Add holes to mount bracket to the heater block
        translate([bracket_flange_width/2, 0, 0])
        heater_mount_holes();

        // Add holes to mount bracket to the MGN12 carriages
        translate([bracket_thickness/2, 0, bracket_height/2])
        mgn12_mount_holes();
    }
}
