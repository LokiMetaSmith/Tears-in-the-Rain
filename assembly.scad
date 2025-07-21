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
bracket_height = 80;
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
heatbreak_clearance_dia = 8; water_channel_dia = 8;
port_tap_dia = 11.8; port_depth = 10;
coupler_tap_dia = 5; bolt_dia_clearance = 3.2;
bolt_dia_tap = 2.5; bolt_margin = 8;
bolt_head_dia = 5.5;
bolt_head_depth = 3.5;

// =============================================================================
// Internal Calculations
// =============================================================================

stagger_y_spacing = nozzle_spacing * sqrt(3) / 2;
block_width = (grid_x - 1) * nozzle_spacing + wall_margin * 2;
block_depth = (grid_y - 1) * stagger_y_spacing + wall_margin * 2;
explode_gap = 10;

// =============================================================================
// HELPER MODULES (Defined before includes)
// =============================================================================

module hardware(type) {
    if (type=="nozzle") color("goldenrod") { cylinder(d=6, h=-nozzle_thread_depth); translate([0,0,-nozzle_thread_depth]) cylinder(d1=7, d2=2, h=-5, $fn=6); }
    if (type=="heater") color("red") cylinder(d=heater_cartridge_dia, h=heater_block_height, center=true);
    if (type=="thermistor") color("green") rotate([0,90,0]) cylinder(d=thermistor_cartridge_dia, h=block_width, center=true);
    if (type=="heatbreak") color("silver") { cylinder(d=7, h=total_water_block_height); translate([0,0,-heatbreak_thread_depth]) cylinder(d=6, h=heatbreak_thread_depth); }
    if (type=="coupler") color("gold") { cylinder(d=6, h=4); translate([0,0,4]) cylinder(d=8, h=5, $fn=6); translate([0,0,9]) color("white") cylinder(d=10, h=4); }
    if (type=="main_assembly_bolt") color("gray", 0.7) {
        translate([0,0,total_water_block_height + heater_block_height/2]) {
             cylinder(d=bolt_head_dia, h=3); // Nut
             translate([0,0,-3]) cylinder(d=m3_clearance_dia, h=-(total_water_block_height+heater_block_height+bracket_thickness)); // Bolt shaft
        }
    }
}

module place_hardware(type) {
    offset_x = -(grid_x - 1) * nozzle_spacing / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;
    center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0;
    
    if (type=="thermistor") hardware("thermistor");
    else if (type=="nozzle" || type=="heatbreak" || type=="coupler") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            pos = [offset_x + x * nozzle_spacing + stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
            translate(pos) hardware(type);
        }
    }
    else if (type=="heater") {
        for (y = [0 : grid_y - 2]) for (x = [0 : grid_x - 1]) {
            y_pos = offset_y + y*stagger_y_spacing + stagger_y_spacing/2;
            x_pos = offset_x + x*nozzle_spacing + nozzle_spacing/2 + center_adj;
            translate([x_pos, y_pos, 0]) hardware("heater");
        }
    }
    else if (type=="main_assembly_bolt") {
        for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
            translate([x_pos, -block_depth/2 + bracket_flange_width/2, 0]) hardware("main_assembly_bolt");
            translate([x_pos, block_depth/2 - bracket_flange_width/2, 0]) hardware("main_assembly_bolt");
        }
    }
}

// =============================================================================
// File Includes
// =============================================================================

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
    translate([0,0, -total_water_block_height - gap]) {
        heater_block(preview=true);
        place_hardware("heater");
        place_hardware("thermistor");
        place_hardware("nozzle");

        // Mounting Brackets
        translate([0, -block_depth/2, -heater_block_height/2]) {
            mounting_bracket(preview=true);
        }
        translate([0, block_depth/2, -heater_block_height/2]) {
            mirror([0,1,0]) mounting_bracket(preview=true);
        }
    }

    // --- Group 2: Water Block ---
    translate([0,0,0]) {
        translate([0,0,-gap]) water_block_bottom(preview=true);
        translate([0,0,gap]) water_block_top(preview=true);
        place_hardware("heatbreak");
    }
    
    // --- Group 3: Couplers & Main Assembly Bolts ---
    translate([0,0,gap*2]) {
        translate([0,0,total_water_block_height]) {
            place_hardware("coupler");
            place_hardware("main_assembly_bolt");
        }
    }
}

// --- View Selection ---
if (view_mode == "heater_block_part") heater_block();
else if (view_mode == "water_block_top_part") water_block_top();
else if (view_mode == "water_block_bottom_part") water_block_bottom();
else if (view_mode == "mounting_bracket_part") mounting_bracket();
else assembly_view(view_mode == "exploded_view");
