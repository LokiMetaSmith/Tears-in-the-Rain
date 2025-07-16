/*
================================================================================
 Full Multi-Nozzle Print Head Assembly (Side-Mount DFM)
================================================================================

 Author: Gemini
 Date: July 14, 2024
 Description:
 This master assembly has been redesigned for a more compact and rigid
 side-mount configuration. The gantry mounting plate has been eliminated,
 and mounting wings have been integrated directly into the heater block.

================================================================================
*/

// =============================================================================
// MASTER CONFIGURATION (Single Source of Truth)
// =============================================================================

// -- View Control --
view_mode = "full_assembly"; // ["full_assembly", "exploded_view", "heater_block_part", "water_block_top_part", "water_block_bottom_part"]

// -- Grid & Block Dimensions --
grid_x = 8; grid_y = 6;
nozzle_spacing = 15;
wall_margin = 10;

// -- Component Heights & Thicknesses --
heater_block_height = 12.7;
water_block_top_height = 12.7;
water_block_bottom_height = 6.35;
total_water_block_height = water_block_top_height + water_block_bottom_height;

// -- Gantry & Mounting Configuration (Integrated into Heater Block) --
side_wing_width = 25; // How far the mounting wings extend from the side
carriage_separation = 60; // Distance between the centers of the two MGN12 blocks on one side
mgn12_spacing_x = 20; // Standard for MGN12H
mgn12_spacing_y = 15; // Standard for MGN12H
m3_clearance_dia = 3.2;
m3_bolt_head_dia = 5.5;
m3_bolt_head_depth = 3.5;

// -- Hardware & Feature Dimensions --
nozzle_tap_dia = 5; nozzle_thread_depth = 8;
heatbreak_tap_dia = 5; heatbreak_thread_depth = 6;
filament_path_dia = 2.5; heater_cartridge_dia = 6;
thermistor_cartridge_dia = 2; thermistor_grub_screw_tap_dia = 2.5;
heatbreak_clearance_dia = 8; water_channel_dia = 6;
port_tap_dia = 11.8; port_depth = 10; // Reduced to fit within bottom plate
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

// =============================================================================
// Main View Controller
// =============================================================================

$fn = 64;

if (view_mode == "full_assembly") assembly_view(exploded=false);
else if (view_mode == "exploded_view") assembly_view(exploded=true);
else if (view_mode == "heater_block_part") heater_block();
else if (view_mode == "water_block_top_part") water_block_top();
else if (view_mode == "water_block_bottom_part") water_block_bottom();

// =============================================================================
// Assembly View Module
// =============================================================================

module assembly_view(exploded=false) {
    gap1 = exploded ? explode_gap : 0;
    gap2 = exploded ? explode_gap * 2 : 0;

    // Group 1: Heater Block
    translate([0, 0, -gap1]) {
        translate([0, 0, -heater_block_height / 2]) {
            heater_block(preview=true);
            place_hardware("heater");
            place_hardware("thermistor");
        }
        translate([0, 0, -heater_block_height]) place_hardware("nozzle");
    }

    // Group 2: Water Block
    translate([0, 0, 0]) {
        water_block_bottom(preview=true);
        translate([0,0,gap1]) water_block_top(preview=true);
        place_hardware("heatbreak");
        translate([0,0,gap1]) place_hardware("assembly_bolt");
        translate([0,0,gap1]) place_hardware("coupler");
    }
}

// =============================================================================
// HARDWARE MODELS & PLACEMENT LOGIC
// =============================================================================

module hardware(type) {
    if (type=="nozzle") color("goldenrod") { cylinder(d=6, h=-nozzle_thread_depth); translate([0,0,-nozzle_thread_depth]) cylinder(d1=7, d2=2, h=-5, $fn=6); }
    if (type=="heater") color("red") cylinder(d=heater_cartridge_dia, h=heater_block_height, center=true);
    if (type=="thermistor") color("green") rotate([0,90,0]) cylinder(d=thermistor_cartridge_dia, h=block_width, center=true);
    if (type=="heatbreak") color("silver") { cylinder(d=7, h=total_water_block_height); translate([0,0,-heatbreak_thread_depth]) cylinder(d=6, h=heatbreak_thread_depth); }
    if (type=="coupler") color("gold") { cylinder(d=6, h=4); translate([0,0,4]) cylinder(d=8, h=5, $fn=6); translate([0,0,9]) color("white") cylinder(d=10, h=4); }
    if (type=="assembly_bolt") color("gray", 0.7) {
        translate([0,0,total_water_block_height]) cylinder(d=bolt_head_dia, h=bolt_head_depth);
        translate([0,0,total_water_block_height]) cylinder(d=bolt_dia_clearance, h=-total_water_block_height);
    }
}

module grid_map(type) {
    offset_x = -(grid_x - 1) * nozzle_spacing / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;
    center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0;
    
    if (type=="nozzle_hole" || type=="heatbreak_clearance" || type=="coupler_hole") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            pos = [offset_x + x * nozzle_spacing + stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
            translate(pos) {
                if (type=="nozzle_hole") nozzle_and_heatbreak_hole();
                else if (type=="heatbreak_clearance") cylinder(h=total_water_block_height+0.2, d=heatbreak_clearance_dia, center=true);
                else if (type=="coupler_hole") cylinder(h=water_block_top_height+0.2, d=coupler_tap_dia, center=true);
            }
        }
    }
    if (type=="heater_hole") {
        for (y = [0 : grid_y - 2]) for (x = [0 : grid_x - 1]) {
            y_pos = offset_y + y*stagger_y_spacing + stagger_y_spacing/2;
            x_pos = offset_x + x*nozzle_spacing + nozzle_spacing/2 + center_adj;
            translate([x_pos, y_pos, 0]) heater_hole();
        }
    }
    if (type=="assembly_bolt_top" || type=="assembly_bolt_bottom") {
        for (x_pos = [-block_width/2 + bolt_margin : bolt_margin*2 : block_width/2 - bolt_margin]) for (y_side = [-1, 1]) {
            pos = [x_pos, y_side * (block_depth/2 - bolt_margin), 0];
            translate(pos) bolt_hole(type=="assembly_bolt_top");
        }
        for (y_pos = [-block_depth/2 + bolt_margin*2 : bolt_margin*2 : block_depth/2 - bolt_margin*2]) for (x_side = [-1, 1]) {
            pos = [x_side * (block_width/2 - bolt_margin), y_pos, 0];
            translate(pos) bolt_hole(type=="assembly_bolt_top");
        }
    }
    if (type=="mounting_hole") {
        mgn12_side_mounts();
    }
}

module bolt_hole(is_top) {
    if (is_top) {
        translate([0,0,water_block_bottom_height]) {
             cylinder(h=water_block_top_height+0.2, d=bolt_dia_clearance, center=true);
             translate([0,0,water_block_top_height - bolt_head_depth]) cylinder(h=bolt_head_depth+0.1, d=bolt_head_dia);
        }
    } else {
        translate([0,0,water_block_bottom_height/2]) cylinder(h=water_block_bottom_height+0.2, d=bolt_dia_tap, center=true);
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
    else if (type=="assembly_bolt") {
        for (x_pos = [-block_width/2 + bolt_margin : bolt_margin*2 : block_width/2 - bolt_margin]) for (y_side = [-1, 1]) {
            translate([x_pos, y_side*(block_depth/2-bolt_margin),0]) hardware("assembly_bolt");
        }
        for (y_pos = [-block_depth/2 + bolt_margin*2 : bolt_margin*2 : block_depth/2 - bolt_margin*2]) for (x_side = [-1, 1]) {
            translate([x_side*(block_width/2-bolt_margin),y_pos,0]) hardware("assembly_bolt");
        }
    }
}
