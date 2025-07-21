// waterblock.scad - Defines the two-piece water block component
// This file is intended to be included by assembly.scad and will not render correctly on its own.

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

// Defines the G1/4" threaded inlet/outlet ports
module water_ports() {
    inlet_pos = [-block_width / 2, -block_depth / 2 + wall_margin, 0];
    translate(inlet_pos) rotate([0, 90, 0]) cylinder(h = port_depth + 0.2, d = port_tap_dia);

    outlet_y = block_depth / 2 - wall_margin;
    outlet_x_side = (grid_y % 2 == 1) ? 1 : -1; 
    outlet_pos = [outlet_x_side * (block_width / 2), outlet_y, 0];
    translate(outlet_pos) rotate([0, -90 * outlet_x_side, 0]) cylinder(h = port_depth + 0.2, d = port_tap_dia);
}

// Merged Top Plate (Water Block Top + Bowden Plate)
module water_block_top(preview=false) {
    difference() {
        color("darkcyan", preview ? 0.8 : 1)
        translate([0,0,water_block_bottom_height + water_block_top_height/2])
        cube([block_width, block_depth, water_block_top_height], center=true);
        
        translate([0,0,water_block_bottom_height]) water_channels();
        grid_map("heatbreak_clearance");
        translate([0,0,water_block_bottom_height]) grid_map("coupler_hole");
        grid_map("assembly_bolt_top");
    }
}

// Bottom Plate
module water_block_bottom(preview=false) {
     difference() {
        color("teal", preview ? 0.8 : 1)
        translate([0,0,water_block_bottom_height/2])
        cube([block_width, block_depth, water_block_bottom_height], center=true);
        
        translate([0,0,water_block_bottom_height]) water_channels();
        grid_map("heatbreak_clearance");
        grid_map("assembly_bolt_bottom");
        translate([0,0,water_block_bottom_height/2]) water_ports();
    }
}
