// waterblock.scad - Defines the two-piece water block with top-facing ports.
// This file is intended to be included by assembly.scad and will not render correctly on its own.
include <helpers.scad>;
// Defines the serpentine water channel path as a solid for subtraction
module water_channels(epsilon=0.1) {
    channel_y_offset = -(grid_y - 1) * stagger_y_spacing / 2;
    channel_x_start = -block_width / 2 + wall_margin / 2;
    channel_x_end = block_width / 2 - wall_margin / 2;

    for (y = [0 : grid_y - 1]) {
        y_pos = channel_y_offset + y * stagger_y_spacing;
        start_point = (y % 2 == 0) ? [channel_x_start, y_pos, 0] : [channel_x_end, y_pos, 0];
        end_point = (y % 2 == 0) ? [channel_x_end, y_pos, 0] : [channel_x_start, y_pos, 0];
        
        minkowski() {
            hull() {
                translate(start_point) cylinder(h = epsilon, d = 0.01, center = true);
                translate(end_point) cylinder(h = epsilon, d = 0.01, center = true);
            }
            sphere(d = water_channel_dia);
        }

        if (y < grid_y - 1) {
            next_y_pos = channel_y_offset + (y + 1) * stagger_y_spacing;
            connector_x = (y % 2 == 0) ? channel_x_end : channel_x_start;
            minkowski() {
                hull() {
                    translate([connector_x, y_pos, 0]) cylinder(h = epsilon, d = 0.01, center = true);
                    translate([connector_x, next_y_pos, 0]) cylinder(h = epsilon, d = 0.01, center = true);
                }
                sphere(d = water_channel_dia);
            }
        }
    }
}

// --- Dynamic Water Port Placement ---

// Function to get a list of all nozzle center coordinates.
// This logic is duplicated from helpers.scad to avoid cross-file dependencies on functions.
function get_nozzle_positions() = [
    for (y = [0 : grid_y - 1])
        for (x = [0 : grid_x - 1])
            let (
                offset_x = -(grid_x - 1) * nozzle_spacing / 2,
                offset_y = -((grid_y - 1) * stagger_y_spacing) / 2,
                center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0,
                stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0
            )
            [offset_x + x * nozzle_spacing + stagger + center_adj, offset_y + y * stagger_y_spacing, 0]
];

// Function to find available corners for water ports.
// It checks the four main corners of the block against the nozzle positions.
function get_available_port_corners() = [
    let (
        nozzle_pos = get_nozzle_positions(),
        // Define the four corners with a margin
        corners = [
            [-block_width/2 + wall_margin, -block_depth/2 + wall_margin, 0], // Bottom-Left
            [-block_width/2 + wall_margin,  block_depth/2 - wall_margin, 0], // Top-Left
            [ block_width/2 - wall_margin, -block_depth/2 + wall_margin, 0], // Bottom-Right
            [ block_width/2 - wall_margin,  block_depth/2 - wall_margin, 0]  // Top-Right
        ],
        // Check if a nozzle is too close to a given corner
        is_occupied = [for (c = corners) len([for (n = nozzle_pos) if (norm(c-n) < port_clearance) 1]) > 0]
    )
    // Return a list of corners that are not occupied
    [for (i = [0:len(corners)-1]) if (!is_occupied[i]) corners[i]]
];

// Defines the G1/4" threaded inlet/outlet ports on the top face
module water_ports() {
    available_corners = get_available_port_corners();

    if (len(available_corners) < 2) {
        // Error state: Not enough free corners for ports. Render a visible warning cube.
        color("red") translate([0,0,water_block_top_height]) cube(10, center=true);
        echo("ERROR: Could not find two free corners for water ports!");
    } else {
        // Place inlet at the first available corner
        translate(available_corners[0])
            cylinder(h = water_block_top_height + 0.2, d = port_tap_dia, center=true);

        // Place outlet at the second available corner
        translate(available_corners[1])
            cylinder(h = water_block_top_height + 0.2, d = port_tap_dia, center=true);
    }
}

// Creates simple clearance holes for the main assembly bolts to pass through the bottom plate
module main_assembly_bolt_clearance() {
    for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
        translate([x_pos, -block_depth/2 + bracket_flange_width/2, 0])
        cylinder(d=bolt_dia_clearance, h=total_water_block_height+0.2, center=true);
        
        translate([x_pos, block_depth/2 - bracket_flange_width/2, 0])
        cylinder(d=bolt_dia_clearance, h=total_water_block_height+0.2, center=true);
    }
}

// Creates counterbored clearance holes for the main assembly bolts in the top plate
module main_assembly_bolt_counterbored_clearance() {
    for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
        // Holes on the negative Y side
        translate([x_pos, -block_depth/2 + bracket_flange_width/2, 0]) {
             cylinder(d=bolt_dia_clearance, h=total_water_block_height+0.2, center=true); // Clearance hole
             translate([0,0,total_water_block_height/2]) rotate([180,0,0]) cylinder(d=bolt_head_dia, h=bolt_head_depth); // Counterbore
        }
        // Holes on the positive Y side
        translate([x_pos, block_depth/2 - bracket_flange_width/2, 0]) {
             cylinder(d=bolt_dia_clearance, h=total_water_block_height+0.2, center=true); // Clearance hole
             translate([0,0,total_water_block_height/2]) rotate([180,0,0]) cylinder(d=bolt_head_dia, h=bolt_head_depth); // Counterbore
        }
    }
}

// Top Plate
module water_block_top(preview=false) {
    difference() {
        color("darkcyan", preview ? 0.8 : 1)
        translate([0,0,water_block_bottom_height + water_block_top_height/2])
        cube([block_width, block_depth, water_block_top_height], center=true);
        
        translate([0,0,water_block_bottom_height]) water_channels();
        union(){
            // Holes that go through the entire water block assembly
            grid_map("heatbreak_clearance");
            main_assembly_bolt_counterbored_clearance(); // Use counterbored holes for the top plate

            // Features specific to the top plate, positioned relative to its center
            translate([0,0, water_block_bottom_height + water_block_top_height/2]) {
                grid_map("coupler_hole"); // For bowden couplers
                water_ports(); // For G1/4 fittings
            }
        }
    }
}

// Bottom Plate
module water_block_bottom(preview=false) {
     difference() {
        color("teal", preview ? 0.8 : 1)
        translate([0,0,water_block_bottom_height/2])
        cube([block_width, block_depth, water_block_bottom_height], center=true);
        
        translate([0,0,water_block_bottom_height]) water_channels();
        union(){
            grid_map("heatbreak_clearance");
            main_assembly_bolt_clearance();
        }
    }
}
