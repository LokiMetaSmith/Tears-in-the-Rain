/* config.scad
================================================================================
 Master Configuration File
================================================================================
 Defines all global parameters and internal calculations.
*/

// =============================================================================
// MASTER CONFIGURATION
// =============================================================================

// -- View Control --
// view_mode is usually defined in the top-level file, but we can set a default here.
// view_mode = "full_assembly"; // Commented out to avoid shadowing warning if set in assembly
generate_data = false; // Set to true to generate manufacturing data instead of rendering

// -- Gantry & Mounting Configuration --
mount_style = "side_brackets"; // ["side_brackets", "top_plate"]
mounting_plate_thickness = 3.18;
bracket_thickness = 3.18; // .125" 5052 Aluminum
bracket_height = 40;
bracket_flange_width = 15; // Increased flange width for C-bracket
carriage_separation = 60;
mgn12_spacing_x = 20; // Preserved from main
mgn12_spacing_y = 15; // Preserved from main
m3_clearance_dia = 3.2; // Preserved from main

// Pillow block dimensions (e.g., for SBR12UU) - Added from feature
pillow_block_hole_spacing_x = 36;
pillow_block_hole_spacing_y = 26;
pillow_block_bolt_dia = 5.2; // Clearance for M5 bolt

// -- Grid & Block Dimensions --
grid_x = 8;
grid_y = 6;
nozzle_spacing = 15;
wall_margin = 10;

// -- Component Heights & Thicknesses --
heater_block_height = 12.7;
water_block_top_height = 12.7;
water_block_bottom_height = 6.35;
total_water_block_height = water_block_top_height + water_block_bottom_height;

// -- Hardware & Feature Dimensions --
nozzle_tap_dia = 5;
nozzle_thread_depth = 8;
heatbreak_tap_dia = 5;
heatbreak_thread_depth = 6;
filament_path_dia = 2.5;
heater_cartridge_dia = 6;
thermistor_cartridge_dia = 2;
thermistor_grub_screw_tap_dia = 2.5;
heatbreak_clearance_dia = 8;
water_channel_dia = 8;
port_tap_dia = 11.8;
port_depth = 10;
port_clearance = 12; // Min distance from nozzle center to port center
coupler_tap_dia = 5;
bolt_dia_clearance = 3.2;
bolt_dia_tap = 2.5;
bolt_margin = 8;
bolt_head_dia = 5.5;
bolt_head_depth = 3.5;

// =============================================================================
// Internal Calculations
// =============================================================================

stagger_y_spacing = nozzle_spacing * sqrt(3) / 2;
// block_width calculation updated to match feature branch logic (removed + bracket_flange_width)
// The feature branch calculated block_width purely based on nozzles + margin.
// The brackets were then placed around it.
block_width = (grid_x - 1) * nozzle_spacing + wall_margin * 2;
block_depth = (grid_y - 1) * stagger_y_spacing + wall_margin * 2;

explode_gap = 10;
bracket_width = block_width; // Bracket length is the width of the main block

=64;
