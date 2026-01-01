// waterblock.scad - Defines the two-piece water block.
include <config.scad>;
include <positions.scad>;
include <helpers.scad>;
include <manufacturing_helpers.scad>;

// --- Dynamic Water Port Placement Logic ---
function get_available_port_corners() = [
    let (
        nozzle_pos = get_nozzle_positions(),
        corners = [
            [-block_width/2 + wall_margin, -block_depth/2 + wall_margin, 0],
            [-block_width/2 + wall_margin,  block_depth/2 - wall_margin, 0],
            [ block_width/2 - wall_margin, -block_depth/2 + wall_margin, 0],
            [ block_width/2 - wall_margin,  block_depth/2 - wall_margin, 0]
        ],
        is_occupied = [for (c = corners) len([for (n = nozzle_pos) if (norm(c-n) < port_clearance) 1]) > 0]
    )
    [for (i = [0:len(corners)-1]) if (!is_occupied[i]) corners[i]]
];

// --- Original Hole Modules (for 3D rendering) ---
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
module water_ports() {
    available_corners = get_available_port_corners();
    if (len(available_corners) >= 2) {
        translate(available_corners[0]) cylinder(h = water_block_top_height + 0.2, d = port_tap_dia, center=true);
        translate(available_corners[1]) cylinder(h = water_block_top_height + 0.2, d = port_tap_dia, center=true);
    } else {
        color("red") translate([0,0,water_block_top_height]) cube(10, center=true);
        echo("ERROR: Could not find two free corners for water ports!");
    }
}
module main_assembly_bolt_clearance() {
    for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
        translate([x_pos, -block_depth/2 + bracket_flange_width/2, 0]) cylinder(d=bolt_dia_clearance, h=total_water_block_height+0.2, center=true);
        translate([x_pos, block_depth/2 - bracket_flange_width/2, 0]) cylinder(d=bolt_dia_clearance, h=total_water_block_height+0.2, center=true);
    }
}
module main_assembly_bolt_counterbored_clearance() {
    for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
        translate([x_pos, -block_depth/2 + bracket_flange_width/2, 0]) {
             cylinder(d=bolt_dia_clearance, h=total_water_block_height+0.2, center=true);
             translate([0,0,total_water_block_height/2]) rotate([180,0,0]) cylinder(d=bolt_head_dia, h=bolt_head_depth);
        }
        translate([x_pos, block_depth/2 - bracket_flange_width/2, 0]) {
             cylinder(d=bolt_dia_clearance, h=total_water_block_height+0.2, center=true);
             translate([0,0,total_water_block_height/2]) rotate([180,0,0]) cylinder(d=bolt_head_dia, h=bolt_head_depth);
        }
    }
}

// --- Main Modules ---
module water_block_top(preview=false) {
    if (generate_data) {
        part_name = "Water Block Top";
        nozzle_pos = get_nozzle_positions();
        for(pos = nozzle_pos) echo_hole(part_name, "Heatbreak Clearance Thru-Hole", pos, heatbreak_clearance_dia);
        for(pos = nozzle_pos) echo_hole(part_name, "Bowden Coupler", pos, coupler_tap_dia, "M6x1.0");
        bolt_positions = [ for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) for (y_sign = [-1, 1]) [x_pos, y_sign * (block_depth/2 - bracket_flange_width/2), 0] ];
        for(pos = bolt_positions) echo_hole(part_name, "Main Assembly Bolt (CBore)", pos, bolt_dia_clearance, "N/A", bolt_head_dia, bolt_head_depth);
        available_corners = get_available_port_corners();
        if (len(available_corners) >= 2) {
            echo_hole(part_name, "Water Port", available_corners[0], port_tap_dia, "G1/4");
            echo_hole(part_name, "Water Port", available_corners[1], port_tap_dia, "G1/4");
        }
    } else {
        difference() {
            color("darkcyan", preview ? 0.8 : 1)
            translate([0,0,water_block_bottom_height + water_block_top_height/2])
            cube([block_width, block_depth, water_block_top_height], center=true);
            translate([0,0,water_block_bottom_height]) water_channels();
            union(){
                grid_map("heatbreak_clearance");
                main_assembly_bolt_counterbored_clearance();
                translate([0,0, water_block_bottom_height + water_block_top_height/2]) {
                    grid_map("coupler_hole");
                    water_ports();
                }
            }
        }
    }
}

module water_block_bottom(preview=false) {
    if(generate_data) {
        part_name = "Water Block Bottom";
        nozzle_pos = get_nozzle_positions();
        for(pos = nozzle_pos) echo_hole(part_name, "Heatbreak Clearance Thru-Hole", pos, heatbreak_clearance_dia);
        bolt_positions = [ for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) for (y_sign = [-1, 1]) [x_pos, y_sign * (block_depth/2 - bracket_flange_width/2), 0] ];
        for(pos = bolt_positions) echo_hole(part_name, "Main Assembly Bolt Clearance", pos, bolt_dia_clearance);
    } else {
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
}
