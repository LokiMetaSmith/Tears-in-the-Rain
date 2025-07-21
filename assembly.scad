/*
================================================================================
 Full Print Head Assembly (Vertical Mount)
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
bracket_flange_width = 30;
carriage_separation = 60;
mgn12_spacing_x = 20;
mgn12_spacing_y = 15;
m3_clearance_dia = 3.2;

// -- Hardware & Feature Dimensions --
nozzle_tap_dia = 5; nozzle_thread_depth = 8;
heatbreak_tap_dia = 5; heatbreak_thread_depth = 6;
filament_path_dia = 2.5; heater_cartridge_dia = 6;
thermistor_cartridge_dia = 2; thermistor_grub_screw_tap_dia = 2.5;
heatbreak_clearance_dia = 8; water_channel_dia = 6;
port_tap_dia = 11.8; port_depth = 10;
coupler_tap_dia = 5; bolt_dia_clearance = 3.2;
bolt_dia_tap = 2.5; bolt_head_dia = 5.5;
bolt_head_depth = 3.5; bolt_margin = 5;

// =============================================================================
// Internal Calculations & File Includes
// =============================================================================

stagger_y_spacing = nozzle_spacing * sqrt(3) / 2;
block_width = (grid_x - 1) * nozzle_spacing + wall_margin * 2;
block_depth = (grid_y - 1) * stagger_y_spacing + wall_margin * 2;
explode_gap = 15;

include <heater.scad>;
include <waterblock.scad>;
include <mounting_bracket.scad>;
include <helpers.scad>;

// =============================================================================
// Main View Controller & Assembly
// =============================================================================

$fn=64;

module assembly_view(exploded=false) {
    gap = exploded ? explode_gap : 0;

    // --- Heater Block & Brackets Group ---
    translate([0,0, -total_water_block_height - gap]) {
        // Heater Block
        translate([0,0, heater_block_height/2]) {
            heater_block(preview=true);
            place_hardware("heater");
            place_hardware("thermistor");
        }
        place_hardware("nozzle");

        // Mounting Brackets
        // Front Bracket
        rotate([0,0,90])
        translate([ -block_depth/2, 0,0]) {
            mounting_bracket(preview=true);
        }
        // Back Bracket
        rotate([0,0,-90])
        translate([-block_depth/2, 0,0]) {
            mirror([0,1,0]) mounting_bracket(preview=true);
        }
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
}

if (view_mode == "mounting_bracket_part") mounting_bracket();
else if (view_mode == "heater_block_part") heater_block();
else if (view_mode == "water_block_top_part") water_block_top();
else if (view_mode == "water_block_bottom_part") water_block_bottom();
else assembly_view(view_mode == "exploded_view");
