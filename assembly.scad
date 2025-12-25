/* assembly.scad
================================================================================
 Full Multi-Nozzle Print Head Assembly (Refactored)
================================================================================

 Author: Gemini
 Date: July 22, 2025
 Description:
 This is the MASTER ASSEMBLY file. It includes configuration and components.
*/

// =============================================================================
// File Includes
// =============================================================================
include <config.scad>;
include <hardware.scad>;
include <helpers.scad>;
include <heater.scad>;
include <waterblock.scad>;
include <mounting_bracket.scad>;
include <mounting_plate.scad>;

// =============================================================================
// Main View Controller & Assembly
// =============================================================================

module assembly_view(exploded=false) {
    gap = exploded ? explode_gap : 0;

    // --- Group 1: Heater Block & Side Brackets ---
    translate([0,0, -heater_block_height/2 - gap]) {
        heater_block(preview=true);
        translate([0,0,-gap*3/2])
        place_hardware("heater",preview=true);
        translate([0,0,-gap*2])
        place_hardware("thermistor",preview=true);
        translate([0,0,-gap*3])
        place_hardware("nozzle",preview=true);

        // Mounting Brackets (Conditional)
        if (mount_style == "side_brackets") {
            translate([0, -block_depth/2-bracket_thickness,-(heater_block_height/2+bracket_thickness)]) {
                mounting_bracket(preview=true);
            }
            translate([0, block_depth/2+bracket_thickness, -(heater_block_height/2+bracket_thickness)]) {
                mirror([0,1,0]) mounting_bracket(preview=true);
            }
        }
    }

    // --- Group 2: Water Block ---
    translate([0,0,0]) {
        translate([0,0,-gap/2]) water_block_bottom(preview=true);
        translate([0,0,gap/2]) water_block_top(preview=true);
        place_hardware("heatbreak",preview=true);
        place_hardware("assembly_bolt",preview=true); // Added visual bolts
    }
    
    // --- Group 3: Couplers & Top Mount ---
    translate([0,0,gap*2]) {
        place_hardware("coupler",preview=true);
        
        // Bolts are only for side brackets in this design
        if (mount_style == "side_brackets") {
            place_hardware("main_assembly_bolt",preview=true);
        }
        // Add top plate if selected. Positioned above the water block.
        if (mount_style == "top_plate") {
            translate([0,0, total_water_block_height + mounting_plate_thickness/2])
            mounting_plate(preview=true);
        }
    }
}

// --- View Selection ---
if (view_mode == "heater_block_part") heater_block();
else if (view_mode == "water_block_top_part") water_block_top();
else if (view_mode == "water_block_bottom_part") water_block_bottom();
else if (view_mode == "mounting_bracket_part") mounting_bracket();
else if (view_mode == "mounting_plate_part") mounting_plate();
else if (view_mode == "full_assembly") assembly_view(exploded = false);
else assembly_view(exploded = true);
