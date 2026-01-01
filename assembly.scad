/* assembly.scad
================================================================================
 Full Multi-Nozzle Print Head Assembly
================================================================================

 Author: Gemini (Refactored by Jules)
 Date: July 22, 2025
 Description:
 This is the MASTER ASSEMBLY file. It includes configuration and components.
*/

// =============================================================================
// File Includes
// =============================================================================
include <config.scad>;
include <positions.scad>; // Added from feature
include <helpers.scad>;
include <heater.scad>;
include <waterblock.scad>;
// include <mounting_bracket.scad>; // REPLACED by c_bracket.scad
include <c_bracket.scad>; // Added from feature
include <mounting_plate.scad>;
include <hardware.scad>; // Preserved from main, though feature might use helpers instead

// =============================================================================
// Main View Controller & Assembly
// =============================================================================

// View Selection Default
view_mode = "full_assembly"; // Default if not passed by command line

module assembly_view(exploded=false) {
    gap = exploded ? explode_gap : 0;

    // --- Main Assembly Stack ---
    // This is a group so we can move the brackets with it easily.
    // group() { // 'group()' is not a standard module, assuming union or implicit
    union() {
        // --- Group 1: Heater Block ---
        translate([0,0, -heater_block_height/2 - gap]) {
            heater_block(preview=true);
            translate([0,0,-gap*3/2])
            place_hardware("heater",preview=true);
            translate([0,0,-gap*2])
            place_hardware("thermistor",preview=true);
            translate([0,0,-gap*3])
            place_hardware("nozzle",preview=true);

            // OLD BRACKET LOGIC (Commented out)
            /*
            if (mount_style == "side_brackets") {
                translate([0, -block_depth/2-bracket_thickness,-(heater_block_height/2+bracket_thickness)]) {
                    mounting_bracket(preview=true);
                }
                translate([0, block_depth/2+bracket_thickness, -(heater_block_height/2+bracket_thickness)]) {
                    mirror([0,1,0]) mounting_bracket(preview=true);
                }
            }
            */
        }

        // --- Group 2: Water Block ---
        translate([0,0,0]) {
            translate([0,0,-gap/2]) water_block_bottom(preview=true);
            translate([0,0,gap/2]) water_block_top(preview=true);
            place_hardware("heatbreak",preview=true);
            // place_hardware("assembly_bolt",preview=true); // Check if this exists in helpers/hardware
        }
        
        // --- Group 3: Couplers & Bolts ---
        translate([0,0,gap*2]) {
            place_hardware("coupler",preview=true);
            place_hardware("main_assembly_bolt",preview=true);
        }
    }

    // --- Mounting Brackets (Conditional) ---
    // NEW C-BRACKET LOGIC
    if (mount_style == "side_brackets") {
        // Place left bracket (-Y side), mirrored to face outward
        translate([0, -block_depth/2, -heater_block_height/2]) {
            mirror([0,1,0]) c_bracket(preview=true);
        }
        // Place right bracket (+Y side), facing outward by default
        translate([0, block_depth/2, -heater_block_height/2]) {
            c_bracket(preview=true);
        }
    }

    // --- Top Mounting Plate (Conditional) ---
    if (mount_style == "top_plate") {
        translate([0,0, total_water_block_height/2 + mounting_plate_thickness/2 + gap*3])
        mounting_plate(preview=true);
    }
}

// --- View Selection ---
if (view_mode == "heater_block_part") heater_block();
else if (view_mode == "water_block_top_part") water_block_top();
else if (view_mode == "water_block_bottom_part") water_block_bottom();
else if (view_mode == "c_bracket_part") c_bracket();
else if (view_mode == "mounting_plate_part") mounting_plate();
else if (view_mode == "full_assembly") assembly_view(exploded = false);
else assembly_view(exploded = true);
