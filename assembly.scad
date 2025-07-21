/*
================================================================================
 Full Print Head Assembly (L-Bracket Mount)
================================================================================
*/

// =============================================================================
// MASTER CONFIGURATION
// =============================================================================

// -- View Control --
view_mode = "full_assembly"; // ["full_assembly", "exploded_view", "mounting_bracket_part"]

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
bracket_height = 100;
bracket_width = 120;
bracket_flange_width = 40;
carriage_separation = 60;
mgn12_spacing_x = 20;
mgn12_spacing_y = 15;
m3_clearance_dia = 3.2;

// ... (Other hardware dimensions) ...

// =============================================================================
// File Includes
// =============================================================================

include <heater.scad>;
include <waterblock.scad>;
include <mounting_bracket.scad>;

// =============================================================================
// HELPER MODULES
// =============================================================================
// (All helper modules are now complete and defined before use)
include <helpers.scad>;

// =============================================================================
// Main View Controller & Assembly
// =============================================================================

$fn=64;

module assembly_view(exploded=false) {
    gap = exploded ? explode_gap : 0;

    // --- Heater Block Group ---
    translate([0,0,-gap]) {
        translate([0,0,-heater_block_height/2]) {
            heater_block(preview=true);
            place_hardware("heater");
            place_hardware("thermistor");
        }
        translate([0,0,-heater_block_height]) place_hardware("nozzle");
    }

    // --- Water Block Group ---
    translate([0,0,0]) {
        translate([0,0,-gap/2]) water_block_bottom(preview=true);
        translate([0,0,gap/2]) water_block_top(preview=true);
        place_hardware("heatbreak");
        translate([0,0,gap/2]) place_hardware("assembly_bolt");
    }
    
    // --- Couplers ---
    translate([0,0,gap*2]) {
        translate([0,0,total_water_block_height]) place_hardware("coupler");
    }

    // --- Mounting Brackets ---
    // Left Bracket
    translate([-block_width/2 - bracket_thickness/2, 0, -heater_block_height/2]) {
        mounting_bracket(preview=true);
    }
    // Right Bracket
    translate([block_width/2 + bracket_thickness/2, 0, -heater_block_height/2]) {
        mirror([1,0,0]) mounting_bracket(preview=true);
    }
}

if (view_mode == "mounting_bracket_part") mounting_bracket();
else assembly_view(view_mode == "exploded_view");
