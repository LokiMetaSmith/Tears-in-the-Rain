// Sheet Metal Bending Library for OpenSCAD
// Author: Jules
// Version: 1.1

// k-Factor: A standard value for aluminum. Can be overridden.
k_factor = 0.44;

// --- FUNCTIONS ---

// Calculates the bend allowance (the length of the arc of the bend)
// angle is the angle of the bend in degrees.
function bend_allowance(radius, thickness, angle=90) =
    (PI * (radius + k_factor * thickness) / 180) * angle;

// --- MODULES ---

// Creates a 2D flat pattern for a generic L-bracket.
// The pattern is laid out along the Y-axis.
// This module ONLY draws the outline and bend lines.
// Hole patterns must be applied by the calling script.
module flat_pattern_L_bracket(width, face1_len, face2_len, thickness, bend_radius) {

    ba = bend_allowance(bend_radius, thickness);
    total_len = face1_len + ba + face2_len;

    // --- Draw the Flat Pattern Outline ---
    square([width, total_len]);

    // --- Draw Bend Lines ---
    // These lines indicate the start and end of the bend area.
    color("red") {
        translate([0, face1_len, 0]) square([width, 0.1]);
        translate([0, face1_len + ba, 0]) square([width, 0.1]);
    }
}
