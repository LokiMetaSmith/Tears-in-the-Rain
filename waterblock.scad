/*
================================================================================
 Parametric Water Cooling Block for Multi-Nozzle Array
================================================================================

 Author: Gemini
 Date: July 14, 2024
 Description:
 This OpenSCAD script generates a water cooling block designed to sit on top
 of the multi-nozzle heater block. It provides cooling to the heat breaks
 to prevent heat from traveling up into the filament path.

 Features:
  - Mates perfectly with the "Parametric Multi-Nozzle Heater Block".
  - Clearance holes for all heat breaks in the staggered array.
  - A serpentine internal water channel that flows past each heat break.
  - Threaded inlet and outlet ports for standard fittings (e.g., G1/4).
  - Parametric design to match the grid size of the heater block.

 Instructions:
  - **CRITICAL:** Ensure the "Grid & Block Dimensions" match the values used
    in your heater block script for proper alignment.
  - Adjust water block specific parameters as needed.
  - Set 'show_internal_channels' to 'true' for a transparent view of the
    water path. Set to 'false' to render the final solid part for export.

================================================================================
*/

// =============================================================================
// Design Configuration - (ADJUST THESE VALUES)
// =============================================================================

// -- Visualization --
show_internal_channels = true; // Set to 'false' to render the final solid model

// -- Grid & Block Dimensions (MUST MATCH HEATER BLOCK SCRIPT) --
grid_x = 8; // Number of nozzles in the X-direction (per row)
grid_y = 6; // Number of nozzles in the Y-direction (number of rows)
nozzle_spacing = 15; // [mm] Center-to-center distance between nozzles
wall_margin = 10; // [mm] Extra material around the outer nozzles

// -- Water Block Specific Dimensions --
water_block_height = 20; // [mm] Total height of the water block
heatbreak_clearance_dia = 8; // [mm] Diameter of holes for heat breaks (e.g., E3D V6 is ~7mm)
water_channel_dia = 6; // [mm] Diameter of the internal water channels
port_tap_dia = 11.8; // [mm] Drill diameter for a G1/4" BSPP tap (common for PC water cooling)
port_depth = 12; // [mm] Depth of the threaded port holes

// =============================================================================
// Internal Calculations (DO NOT MODIFY)
// =============================================================================

// Staggered grid y-spacing
stagger_y_spacing = nozzle_spacing * sqrt(3) / 2;

// Calculate the total dimensions of the block to match the heater block
block_width = (grid_x - 1) * nozzle_spacing + wall_margin * 2;
block_depth = (grid_y - 1) * stagger_y_spacing + wall_margin * 2;

// =============================================================================
// Main Model Generation
// =============================================================================

$fn = 64; // Set fragment number for smooth curves

if (show_internal_channels) {
    // Render for visualization with colors
    main_water_block(transparency = 0.8);
    water_channels();
    // Also show the heatbreak clearance holes for context
    color("gray", 0.5) heatbreak_clearance_holes();
} else {
    // Render the final solid model by subtracting the holes
    difference() {
        main_water_block();
        heatbreak_clearance_holes();
        water_channels();
    }
}

// =============================================================================
// Modules
// =============================================================================

// -- Module for the main block shape --
module main_water_block(transparency = 0) {
    echo("Water Block Dimensions (WxDxH):", block_width, "x", block_depth, "x", water_block_height);
    color("darkcyan", 1 - transparency)
    translate([0, 0, water_block_height / 2])
    cube([block_width, block_depth, water_block_height], center = true);
}

// -- Module for all heat break clearance holes --
module heatbreak_clearance_holes() {
    // Use the same positioning logic as the heater block's nozzle holes
    offset_x = -((grid_x - 1) * nozzle_spacing) / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;

    for (y = [0 : grid_y - 1]) {
        for (x = [0 : grid_x - 1]) {
            stagger_offset = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            if (grid_x % 2 == 0) {
                 stagger_offset = stagger_offset - nozzle_spacing/2;
            }
            position = [
                offset_x + x * nozzle_spacing + stagger_offset,
                offset_y + y * stagger_y_spacing,
                0
            ];
            translate(position)
            cylinder(h = water_block_height + 2, d = heatbreak_clearance_dia, center = true);
        }
    }
}

// -- Module for the internal water channels and ports --
module water_channels() {
    color("aqua") {
        // --- Inlet and Outlet Ports ---
        // Inlet Port (Left Side)
        translate([-block_width / 2 - 1, -block_depth / 2 + wall_margin, 0])
        rotate([0, 90, 0])
        cylinder(h = port_depth + 2, d = port_tap_dia);

        // Outlet Port (Right Side)
        translate([block_width / 2 + 1, block_depth / 2 - wall_margin, 0])
        rotate([0, -90, 0])
        cylinder(h = port_depth + 2, d = port_tap_dia);

        // --- Serpentine Channel ---
        channel_y_offset = -(grid_y - 1) * stagger_y_spacing / 2;
        channel_x_start = -block_width / 2 + wall_margin / 2;
        channel_x_end = block_width / 2 - wall_margin / 2;

        for (y = [0 : grid_y - 1]) {
            y_pos = channel_y_offset + y * stagger_y_spacing;
            
            // Draw the main horizontal channel for this row
            // Alternate direction for serpentine flow
            start_point = (y % 2 == 0) ? [channel_x_start, y_pos, 0] : [channel_x_end, y_pos, 0];
            end_point = (y % 2 == 0) ? [channel_x_end, y_pos, 0] : [channel_x_start, y_pos, 0];
            
            hull() {
                translate(start_point) cylinder(d = water_channel_dia, h = 0.01, center = true);
                translate(end_point) cylinder(d = water_channel_dia, h = 0.01, center = true);
            }

            // Draw the vertical connector to the next row
            if (y < grid_y - 1) {
                next_y_pos = channel_y_offset + (y + 1) * stagger_y_spacing;
                connector_x = (y % 2 == 0) ? channel_x_end : channel_x_start;
                
                hull() {
                    translate([connector_x, y_pos, 0]) cylinder(d = water_channel_dia, h = 0.01, center = true);
                    translate([connector_x, next_y_pos, 0]) cylinder(d = water_channel_dia, h = 0.01, center = true);
                }
            }
        }
        
        // Connect Inlet/Outlet to the serpentine channel
        hull(){
             translate([-block_width / 2, -block_depth / 2 + wall_margin, 0]) cylinder(d=water_channel_dia, h=0.01, center=true);
             translate([channel_x_start, channel_y_offset, 0]) cylinder(d=water_channel_dia, h=0.01, center=true);
        }
        hull(){
             translate([block_width / 2, block_depth / 2 - wall_margin, 0]) cylinder(d=water_channel_dia, h=0.01, center=true);
             translate([ (grid_y % 2 == 1) ? channel_x_end : channel_x_start, channel_y_offset + (grid_y-1)*stagger_y_spacing, 0]) cylinder(d=water_channel_dia, h=0.01, center=true);
        }
    }
}
