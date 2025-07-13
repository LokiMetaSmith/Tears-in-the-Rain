/*
================================================================================
 Parametric Multi-Nozzle Array Heater Block for 3D Printers
================================================================================

 Author: Gemini
 Date: July 14, 2024
 Description:
 This OpenSCAD script generates a solid aluminum heater block designed to hold
 a staggered grid of standard M6 3D printer nozzles. The design is
 fully parametric, allowing for easy customization of the grid size,
 spacing, and other critical dimensions.

 Features:
  - Staggered nozzle layout for maximum packing density.
  - Holes for standard M6 threaded nozzles (e.g., E3D V6).
  - Holes for standard M6 threaded heat breaks from the top.
  - Vertical holes for 6mm cylindrical heater cartridges.
  - A hole for a standard cartridge-style thermistor (e.g., PT100) with a
    securing M3 grub screw.
  - Mounting holes on the sides for attaching to linear rails or gantry plates.

 Instructions:
  - Adjust the parameters in the "Design Configuration" section below.
  - Press F5 to render a preview or F6 to render the final model for export.
  - The model uses simple cylinders for threaded holes. These should be
    tapped with the appropriate M6 and M3 taps after machining.

================================================================================
*/

// =============================================================================
// Design Configuration - (ADJUST THESE VALUES TO CUSTOMIZE YOUR BLOCK)
// =============================================================================

// -- Visualization --
show_colors_for_preview = true; // Set to 'false' to render the final solid model for export

// -- Grid & Block Dimensions --
grid_x = 8; // Number of nozzles in the X-direction (per row)
grid_y = 6; // Number of nozzles in the Y-direction (number of rows)
nozzle_spacing = 15; // [mm] Center-to-center distance between nozzles
wall_margin = 10; // [mm] Extra material around the outer nozzles for strength
block_height = 25; // [mm] Total height of the aluminum block

// -- Nozzle & Heat Break Dimensions (for standard M6 parts) --
nozzle_tap_dia = 5; // [mm] Drill diameter for an M6x1 tap
nozzle_thread_depth = 8; // [mm] Depth of the nozzle thread from the bottom
heatbreak_tap_dia = 5; // [mm] Drill diameter for an M6x1 tap
heatbreak_thread_depth = 6; // [mm] Depth of the heat break thread from the top
filament_path_dia = 2.5; // [mm] Diameter of the filament path through the block

// -- Heater & Thermistor Dimensions --
heater_cartridge_dia = 6; // [mm] Diameter of the heater cartridge holes
thermistor_cartridge_dia = 2; // [mm] Diameter for the thermistor (e.g., PT100)
thermistor_grub_screw_tap_dia = 2.5; // [mm] Drill diameter for an M3 tap

// -- Mounting Hole Dimensions --
mounting_hole_dia = 3.2; // [mm] Clearance hole diameter for M3 screws
num_mounting_holes = 4; // Number of mounting holes per side

// =============================================================================
// Internal Calculations (DO NOT MODIFY)
// =============================================================================

// Staggered grid requires calculating y-spacing based on an equilateral triangle
stagger_y_spacing = nozzle_spacing * sqrt(3) / 2;

// Calculate the total dimensions of the block
block_width = (grid_x - 1) * nozzle_spacing + wall_margin * 2;
block_depth = (grid_y - 1) * stagger_y_spacing + wall_margin * 2;

// =============================================================================
// Main Model Generation
// =============================================================================

$fn = 64; // Set fragment number for smooth curves

if (show_colors_for_preview) {
    // Render for visualization with colors (main block is semi-transparent)
    main_block(transparency = 0.6);
    all_nozzle_holes();
    all_heater_holes();
    thermistor_assembly();
    side_mounting_holes();
} else {
    // Render the final solid model by subtracting the holes
    difference() {
        main_block();
        all_nozzle_holes();
        all_heater_holes();
        thermistor_assembly();
        side_mounting_holes();
    }
}


// =============================================================================
// Modules
// =============================================================================

// -- Module for the main block shape --
module main_block(transparency = 0) {
    echo("Block Dimensions (WxDxH):", block_width, "x", block_depth, "x", block_height);
    color("lightgray", 1 - transparency)
    cube([block_width, block_depth, block_height], center = true);
}

// -- Module to create the full array of nozzle/heatbreak holes --
module all_nozzle_holes() {
    // Center the grid on the block
    offset_x = -((grid_x - 1) * nozzle_spacing) / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;

    for (y = [0 : grid_y - 1]) {
        for (x = [0 : grid_x - 1]) {
            // Apply stagger: offset every other row
            stagger_offset = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            
            // For even-column-count grids, we need to adjust the stagger to keep it centered
            if (grid_x % 2 == 0) {
                 stagger_offset = stagger_offset - nozzle_spacing/2;
            }


            position = [
                offset_x + x * nozzle_spacing + stagger_offset,
                offset_y + y * stagger_y_spacing,
                0
            ];
            translate(position)
            nozzle_and_heatbreak_hole();
        }
    }
}


// -- Module for a single complete nozzle + heatbreak hole --
module nozzle_and_heatbreak_hole() {
    color("blue") {
        // Nozzle hole (from bottom)
        translate([0, 0, -block_height / 2 - 1])
        cylinder(h = nozzle_thread_depth + 2, d = nozzle_tap_dia, center = false);

        // Heat break hole (from top)
        translate([0, 0, block_height / 2 + 1])
        rotate([180, 0, 0])
        cylinder(h = heatbreak_thread_depth + 2, d = heatbreak_tap_dia, center = false);

        // Filament path connecting them
        cylinder(h = block_height + 2, d = filament_path_dia, center = true);
    }
}

// -- Module to create the array of heater cartridge holes --
module all_heater_holes() {
    // Heaters are placed in the center of nozzle triangles
    offset_x = -((grid_x - 1.5) * nozzle_spacing) / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2 + stagger_y_spacing/2;
    
    for (y = [0 : grid_y - 2]) {
        for (x = [0 : grid_x - 2]) {
             // Apply stagger: offset every other row
            stagger_offset = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            
            position = [
                offset_x + x * nozzle_spacing + stagger_offset,
                offset_y + y * stagger_y_spacing,
                0
            ];
            translate(position)
            heater_hole();
        }
    }
}


// -- Module for a single heater cartridge hole --
module heater_hole() {
    color("red")
    cylinder(h = block_height + 2, d = heater_cartridge_dia, center = true);
}

// -- Module for the thermistor hole and its grub screw --
module thermistor_assembly() {
    color("green") {
        // Place the thermistor near the center of the block
        thermistor_x_pos = 0;
        thermistor_y_pos = 0;
        thermistor_z_pos = 0; // Centered vertically

        // Thermistor cartridge hole
        translate([thermistor_x_pos, thermistor_y_pos, thermistor_z_pos])
        rotate([0, 90, 0]) // Orient along the X-axis
        cylinder(h = block_width + 2, d = thermistor_cartridge_dia, center = true);

        // Grub screw hole to secure the thermistor
        // Placed on the front face, intersecting the thermistor hole
        grub_screw_x = thermistor_x_pos;
        grub_screw_y = block_depth / 2 + 1; // From the front
        grub_screw_z = thermistor_z_pos;

        translate([grub_screw_x, grub_screw_y, grub_screw_z])
        rotate([-90, 0, 0])
        cylinder(h = wall_margin + 5, d = thermistor_grub_screw_tap_dia);
    }
}


// -- Module for mounting holes on both sides --
module side_mounting_holes() {
    color("purple") {
        // Holes on the right side (+X)
        for (i = [0:num_mounting_holes-1]) {
            x_pos = block_width / 2 + 1;
            y_pos = -block_depth/2 + wall_margin + i * (block_depth - 2*wall_margin)/(num_mounting_holes-1);
            z_pos = 0;
            
            translate([x_pos, y_pos, z_pos])
            rotate([0, 90, 0])
            cylinder(h = wall_margin*2+2, d = mounting_hole_dia, center=true);
        }
        
        // Holes on the left side (-X)
         for (i = [0:num_mounting_holes-1]) {
            x_pos = -block_width / 2 - 1;
            y_pos = -block_depth/2 + wall_margin + i * (block_depth - 2*wall_margin)/(num_mounting_holes-1);
            z_pos = 0;
            
            translate([x_pos, y_pos, z_pos])
            rotate([0, 90, 0])
            cylinder(h = wall_margin*2+2, d = mounting_hole_dia, center=true);
        }
    }
}
