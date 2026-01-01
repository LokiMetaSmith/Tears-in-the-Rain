// DXF Export Master File
//
// This file generates a 2D DXF-ready flat pattern for the C-Bracket.
// Open this file in OpenSCAD and press F6 to render the 2D projection.
// Then, go to File > Export > Export as DXF.

include <assembly.scad>;
include <sheet_metal_lib.scad>;

// --- Bend Configuration ---
bend_radius = 1; // Inner radius of the bend

// --- Part Dimensions (from assembly.scad for clarity) ---
part_width = bracket_width;
part_thickness = bracket_thickness;
face1_height = bracket_height; // The vertical plate
face2_flange = bracket_flange_width; // The top flange

// --- Calculations ---
// The length of the flat sections of the faces.
// This is the dimension from the edge to the start of the bend tangent line.
face1_flat_len = face1_height - bend_radius - part_thickness;
face2_flat_len = face2_flange - bend_radius - part_thickness;
ba = bend_allowance(bend_radius, part_thickness);

// --- 2D Projection ---
projection(cut = false) {

    // Union to combine the outline and the holes into one shape
    union() {
        // 1. Draw the base flat pattern from the library
        flat_pattern_L_bracket(
            width = part_width,
            face1_len = face1_flat_len,
            face2_len = face2_flat_len,
            thickness = part_thickness,
            bend_radius = bend_radius
        );

        // 2. Add holes to the vertical face (Face 1)
        // This face starts at Y=0. Its center is at X = part_width/2.
        heater_hole_positions_x = [-block_width/4, 0, block_width/4];
        for(x_pos = heater_hole_positions_x) {
            // Position holes along the center of the face
            translate([part_width/2 + x_pos, face1_flat_len/2, 0])
            circle(d=bolt_dia_clearance);
        }

        // 3. Add holes to the top flange (Face 2)
        // This face starts at Y = face1_flat_len + ba.
        pillow_block_centers = [
            for(x_sign = [-1, 1])
                [part_width/2 + (x_sign * carriage_separation / 2), face1_flat_len + ba + face2_flat_len/2, 0]
        ];
        for(center=pillow_block_centers) {
            for (y_hole = [-pillow_block_hole_spacing_y/2, pillow_block_hole_spacing_y/2]) {
                for (x_hole = [-pillow_block_hole_spacing_x/2, pillow_block_hole_spacing_x/2]) {
                    translate(center)
                    translate([x_hole, y_hole, 0])
                    circle(d=pillow_block_bolt_dia);
                }
            }
        }
    }
}
