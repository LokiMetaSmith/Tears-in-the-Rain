/*
================================================================================
 Full Multi-Nozzle Print Head Assembly (Modular)
================================================================================

 Author: Gemini
 Date: July 14, 2024
 Description:
 This is the MASTER ASSEMBLY file. It defines all the global parameters and
 assembles the components by including the individual part files.

================================================================================
*/

// =============================================================================
// MASTER CONFIGURATION (Single Source of Truth)
// =============================================================================

// -- View Control --
view_mode = "full_assembly"; // ["full_assembly", "exploded_view", "heater_block_part", "water_block_top_part", "water_block_bottom_part", "bowden_plate_part"]

// -- Grid & Block Dimensions --
grid_x = 8; grid_y = 6;
nozzle_spacing = 15;
wall_margin = 10;

// -- Component Heights --
heater_block_height = 25;
water_block_height = 20;
coupler_plate_height = 6;

// -- Hardware & Feature Dimensions --
nozzle_tap_dia = 5; nozzle_thread_depth = 8;
heatbreak_tap_dia = 5; heatbreak_thread_depth = 6;
filament_path_dia = 2.5; heater_cartridge_dia = 6;
thermistor_cartridge_dia = 2; thermistor_grub_screw_tap_dia = 2.5;
heatbreak_clearance_dia = 8; water_channel_dia = 6;
port_tap_dia = 11.8; port_depth = 12;
coupler_tap_dia = 5; bolt_dia_clearance = 3.2;
bolt_dia_tap = 2.5; bolt_head_dia = 5.5;
bolt_head_depth = 3.5; bolt_margin = 5;

// =============================================================================
// Internal Calculations & File Includes
// =============================================================================

stagger_y_spacing = nozzle_spacing * sqrt(3) / 2;
block_width = (grid_x - 1) * nozzle_spacing + wall_margin * 2;
block_depth = (grid_y - 1) * stagger_y_spacing + wall_margin * 2;
water_plate_height = water_block_height / 2;
explode_gap = 15;

include <heater.scad>;
include <waterblock.scad>;
include <bowden.scad>;

// =============================================================================
// Main View Controller
// =============================================================================

$fn = 64;

if (view_mode == "full_assembly") assembly_view(exploded=false);
else if (view_mode == "exploded_view") assembly_view(exploded=true);
else if (view_mode == "heater_block_part") heater_block();
else if (view_mode == "water_block_top_part") water_block_top();
else if (view_mode == "water_block_bottom_part") water_block_bottom();
else if (view_mode == "bowden_plate_part") bowden_coupler_plate();

// =============================================================================
// Assembly View Module
// =============================================================================

module assembly_view(exploded=false) {
    // Z-offsets for each major component group
    z_heater_group = -(exploded ? explode_gap : 0);
    z_water_group = 0;
    z_bowden_group = water_block_height + (exploded ? explode_gap : 0);

    // --- Place Manufactured Parts ---
    translate([0,0,z_heater_group]) heater_block(preview=true);
    translate([0,0,z_water_group]) {
        water_block_bottom(preview=true);
        water_block_top(preview=true);
    }
    translate([0,0,z_bowden_group]) bowden_coupler_plate(preview=true);
    
    // --- Place Hardware ---
    translate([0,0,z_heater_group]) place_hardware("nozzle");
    translate([0,0,z_heater_group]) place_hardware("heater");
    translate([0,0,z_heater_group]) place_hardware("thermistor");
    translate([0,0,z_water_group]) place_hardware("heatbreak");
    translate([0,0,z_water_group]) place_hardware("assembly_bolt");
    translate([0,0,z_bowden_group]) place_hardware("coupler");
}

// =============================================================================
// HARDWARE MODELS (Defined at origin)
// =============================================================================
module hardware(type) {
    if (type=="nozzle") color("goldenrod") { cylinder(d1=7, d2=2, h=nozzle_thread_depth, $fn=6); translate([0,0,nozzle_thread_depth]) cylinder(d=5, h=5); }
    if (type=="heater") color("red") cylinder(d=heater_cartridge_dia, h=heater_block_height, center=true);
    if (type=="thermistor") color("green") rotate([0,90,0]) cylinder(d=thermistor_cartridge_dia, h=block_width, center=true);
    if (type=="heatbreak") color("silver") { cylinder(d=7, h=15); translate([0,0,-6]) cylinder(d=6, h=6); }
    if (type=="coupler") color("gold") { cylinder(d=6, h=4); translate([0,0,4]) cylinder(d=8, h=5, $fn=6); translate([0,0,9]) color("white") cylinder(d=10, h=4); }
    if (type=="assembly_bolt") color("gray", 0.7) { translate([0,0,water_block_height-bolt_head_depth]) cylinder(d=bolt_head_dia, h=bolt_head_depth); cylinder(d=bolt_dia_clearance, h=water_block_height); }
}

// =============================================================================
// UNIVERSAL GRID & HARDWARE PLACEMENT
// =============================================================================
module grid_map(type, height_override=0) {
    offset_x = -((grid_x - 1) * nozzle_spacing) / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;
    
    if (type=="nozzle_hole" || type=="heatbreak_clearance" || type=="coupler_hole") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : (grid_x % 2 == 0 ? -nozzle_spacing / 2 : 0);
            pos = [offset_x + x * nozzle_spacing + stagger, offset_y + y * stagger_y_spacing, 0];
            translate(pos)
                if (type=="nozzle_hole") nozzle_and_heatbreak_hole();
                else if (type=="heatbreak_clearance") cylinder(h=water_block_height+2, d=heatbreak_clearance_dia, center=true);
                else if (type=="coupler_hole") cylinder(h=coupler_plate_height+2, d=coupler_tap_dia, center=true);
        }
    }
    if (type=="heater_hole") {
        for (y = [0 : grid_y - 2]) {
            for (x = [0 : grid_x - 2]) {
                heater_y_pos = offset_y + stagger_y_spacing/2 + y * stagger_y_spacing;
                heater_stagger_offset = (y % 2 == 1) ? (nozzle_spacing / 2) : nozzle_spacing;
                heater_x_pos = offset_x - nozzle_spacing/2 + x * nozzle_spacing + heater_stagger_offset;
                pos = [heater_x_pos, heater_y_pos, 0];
                translate(pos) heater_hole();
            }
        }
    }
    if (type=="assembly_bolt_top" || type=="assembly_bolt_bottom") {
        for (x_pos = [-block_width/2 + bolt_margin : bolt_margin*2 : block_width/2 - bolt_margin]) for (y_side = [-1, 1]) {
            pos = [x_pos, y_side * (block_depth/2 - bolt_margin), 0];
            translate(pos) bolt_hole(type=="assembly_bolt_top", height_override);
        }
        for (y_pos = [-block_depth/2 + bolt_margin*2 : bolt_margin*2 : block_depth/2 - bolt_margin*2]) for (x_side = [-1, 1]) {
            pos = [x_side * (block_width/2 - bolt_margin), y_pos, 0];
            translate(pos) bolt_hole(type=="assembly_bolt_top", height_override);
        }
    }
    if (type=="mounting_hole") {
        for (y_pos = [-block_depth/2 + bolt_margin*2 : bolt_margin*2 : block_depth/2 - bolt_margin*2]) {
            translate([block_width/2, y_pos, 0]) rotate([0,90,0]) cylinder(h=wall_margin+1, d=bolt_dia_tap);
            translate([-block_width/2, y_pos, 0]) rotate([0,-90,0]) cylinder(h=wall_margin+1, d=bolt_dia_tap);
        }
    }
}

module bolt_hole(is_top, h_override) {
    h = h_override > 0 ? h_override : water_plate_height;
    if (is_top) {
        cylinder(h=h+2, d=bolt_dia_clearance, center=true);
        if (h_override==0) translate([0,0,h-bolt_head_depth]) cylinder(h=bolt_head_depth, d=bolt_head_dia);
    } else {
        cylinder(h=h+2, d=bolt_dia_tap, center=true);
    }
}

module place_hardware(type) {
    offset_x = -((grid_x - 1) * nozzle_spacing) / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;
    
    if (type=="thermistor") {
        hardware("thermistor");
    } else if (type=="nozzle" || type=="heatbreak" || type=="coupler") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : (grid_x % 2 == 0 ? -nozzle_spacing / 2 : 0);
            pos = [offset_x + x * nozzle_spacing + stagger, offset_y + y * stagger_y_spacing, 0];
            z_offset = (type=="nozzle") ? -heater_block_height/2 : ( (type=="heatbreak") ? -water_plate_height : 0);
            translate(pos + [0,0,z_offset]) hardware(type);
        }
    } else if (type=="heater") {
        for (y = [0 : grid_y - 2]) for (x = [0 : grid_x - 2]) {
            pos = [offset_x - nozzle_spacing/2 + x*nozzle_spacing + ((y%2==1)?nozzle_spacing/2:nozzle_spacing), offset_y + stagger_y_spacing/2 + y*stagger_y_spacing, 0];
            translate(pos) hardware("heater");
        }
    } else if (type=="assembly_bolt") {
        for (x_pos = [-block_width/2 + bolt_margin : bolt_margin*2 : block_width/2 - bolt_margin]) for (y_side = [-1, 1]) {
            translate([x_pos, y_side*(block_depth/2-bolt_margin),0]) hardware("assembly_bolt");
        }
        for (y_pos = [-block_depth/2 + bolt_margin*2 : bolt_margin*2 : block_depth/2 - bolt_margin*2]) for (x_side = [-1, 1]) {
            translate([x_side*(block_width/2-bolt_margin),y_pos,0]) hardware("assembly_bolt");
        }
    }
}
