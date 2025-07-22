/*
================================================================================
 Full Multi-Nozzle Print Head Assembly (Final Corrected)
================================================================================

 Author: Gemini
 Date: July 14, 2024
 Description:
 This is the MASTER ASSEMBLY file. It defines all global parameters, helper
 modules, and assembles the components from the included part files. This version
 corrects all structural and scope-related errors.

================================================================================
*/

// =============================================================================
// MASTER CONFIGURATION
// =============================================================================

// -- View Control --
view_mode = "exploded_view"; // ["full_assembly", "exploded_view", "heater_block_part", "water_block_top_part", "water_block_bottom_part", "mounting_bracket_part"]

// -- Grid & Block Dimensions --
grid_x = 8; grid_y = 6;
nozzle_spacing = 15;
wall_margin = 10;

// -- Component Heights & Thicknesses --
heater_block_height = 12.7;
water_block_top_height = 12.7;
water_block_bottom_height = 6.35;
total_water_block_height = water_block_top_height + water_block_bottom_height;

// -- Gantry & Mounting Bracket Configuration --
bracket_thickness = 3.18; // .125" 5052 Aluminum
bracket_height = 40;

bracket_flange_width = 10;
carriage_separation = 60;
mgn12_spacing_x = 20;
mgn12_spacing_y = 15;
m3_clearance_dia = 3.2;

// -- Hardware & Feature Dimensions --
nozzle_tap_dia = 5; nozzle_thread_depth = 8;
heatbreak_tap_dia = 5; heatbreak_thread_depth = 6;
filament_path_dia = 2.5; heater_cartridge_dia = 6;
thermistor_cartridge_dia = 2; thermistor_grub_screw_tap_dia = 2.5;
heatbreak_clearance_dia = 8; water_channel_dia = 8;
port_tap_dia = 11.8; port_depth = 10;
port_clearance = 12; // Min distance from nozzle center to port center
coupler_tap_dia = 5; bolt_dia_clearance = 3.2;
bolt_dia_tap = 2.5; bolt_margin = 8;
bolt_head_dia = 5.5;
bolt_head_depth = 3.5;

// =============================================================================
// Internal Calculations
// =============================================================================

stagger_y_spacing = nozzle_spacing * sqrt(3) / 2;
block_width = (grid_x - 1) * nozzle_spacing + wall_margin * 2 + bracket_flange_width;
block_depth = (grid_y - 1) * stagger_y_spacing + wall_margin * 2 + bracket_flange_width;
explode_gap = 10;
bracket_width = block_width;//120;

// =============================================================================
// File Includes
// =============================================================================
include <helpers.scad>;
include <heater.scad>;
include <waterblock.scad>;
include <mounting_bracket.scad>;

// =============================================================================
// Main View Controller & Assembly
// =============================================================================

$fn=64;

module assembly_view(exploded=false) {
    gap = exploded ? explode_gap : 0;

    // --- Group 1: Heater Block & Brackets ---
    translate([0,0, -heater_block_height/2 - gap]) {
        heater_block(preview=true);
        translate([0,0,-gap*3/2])
        place_hardware("heater",preview=true);
        translate([0,0,-gap*2])
        place_hardware("thermistor",preview=true);
        translate([0,0,-gap*3])
        place_hardware("nozzle",preview=true);

        // Mounting Brackets
        translate([0, -block_depth/2-bracket_thickness,-(heater_block_height/2+bracket_thickness)]) {
            mounting_bracket(preview=true);
        }
        translate([0, block_depth/2+bracket_thickness, -(heater_block_height/2+bracket_thickness)]) {
            mirror([0,1,0]) mounting_bracket(preview=true);
        }
    }

    // --- Group 2: Water Block ---
    translate([0,0,0]) {
        translate([0,0,-gap/2]) water_block_bottom(preview=true);
        translate([0,0,gap/2]) water_block_top(preview=true);
        place_hardware("heatbreak",preview=true);
    }
    
    // --- Group 3: Couplers & Main Assembly Bolts ---
    translate([0,0,gap*2]) {
        translate([0,0,0]) {
            place_hardware("coupler",preview=true);
            place_hardware("main_assembly_bolt",preview=true);
        }
    }
}

// --- View Selection ---
if (view_mode == "heater_block_part") heater_block();
else if (view_mode == "water_block_top_part") water_block_top();
else if (view_mode == "water_block_bottom_part") water_block_bottom();
else if (view_mode == "mounting_bracket_part") mounting_bracket();
else if (view_mode == "full_assembly") assembly_view(exploded = false);
else assembly_view(exploded = true);
