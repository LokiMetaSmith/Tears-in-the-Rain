// waterblock.scad - Defines the two-piece water block component

module water_block_top(preview=false) {
    difference() {
        color("darkcyan", preview ? 0.8 : 1)
        translate([0,0,water_plate_height/2])
        cube([block_width, block_depth, water_plate_height], center=true);
        
        water_channels();
        grid_map("heatbreak_clearance");
        grid_map("assembly_bolt_top");
    }
}

module water_block_bottom(preview=false) {
     difference() {
        color("teal", preview ? 0.8 : 1)
        translate([0,0,-water_plate_height/2])
        cube([block_width, block_depth, water_plate_height], center=true);
        
        water_channels();
        grid_map("heatbreak_clearance");
        grid_map("assembly_bolt_bottom");
        water_ports();
    }
}

// Defines the serpentine water channel path as a solid for subtraction
module water_channels() {
    channel_y_offset = -(grid_y - 1) * stagger_y_spacing / 2;
    channel_x_start = -block_width / 2 + wall_margin / 2;
    channel_x_end = block_width / 2 - wall_margin / 2;

    for (y = [0 : grid_y - 1]) {
        y_pos = channel_y_offset + y * stagger_y_spacing;
        start_point = (y % 2 == 0) ? [channel_x_start, y_pos, 0] : [channel_x_end, y_pos, 0];
        end_point = (y % 2 == 0) ? [channel_x_end, y_pos, 0] : [channel_x_start, y_pos, 0];
        
        // Horizontal channel for the row
        minkowski() {
            hull() {
                translate(start_point) cylinder(h = 0.01, d = 0.01, center = true);
                translate(end_point) cylinder(h = 0.01, d = 0.01, center = true);
            }
            sphere(d = water_channel_dia);
        }

        // Vertical connector to the next row
        if (y < grid_y - 1) {
            next_y_pos = channel_y_offset + (y + 1) * stagger_y_spacing;
            connector_x = (y % 2 == 0) ? channel_x_end : channel_x_start;
            minkowski() {
                hull() {
                    translate([connector_x, y_pos, 0]) cylinder(h = 0.01, d = 0.01, center = true);
                    translate([connector_x, next_y_pos, 0]) cylinder(h = 0.01, d = 0.01, center = true);
                }
                sphere(d = water_channel_dia);
            }
        }
    }
}

// Defines the G1/4" threaded inlet/outlet ports
module water_ports() {
    // Inlet Port (Left Side, Bottom Row)
    inlet_pos = [-block_width / 2, -block_depth / 2 + wall_margin, -water_plate_height/2];
    translate(inlet_pos) rotate([0, 90, 0]) cylinder(h = port_depth + 2, d = port_tap_dia);

    // Outlet Port (Position depends on whether grid_y is even or odd)
    outlet_y = block_depth / 2 - wall_margin;
    outlet_x_side = (grid_y % 2 == 1) ? 1 : -1; 
    outlet_pos = [outlet_x_side * (block_width / 2), outlet_y, -water_plate_height/2];
    translate(outlet_pos) rotate([0, -90 * outlet_x_side, 0]) cylinder(h = port_depth + 2, d = port_tap_dia);
    
    // Connection from port to the main channel
    channel_y_offset = -(grid_y - 1) * stagger_y_spacing / 2;
    channel_x_start = -block_width / 2 + wall_margin / 2;
    channel_x_end = block_width / 2 - wall_margin / 2;

    // Inlet connection
    minkowski() {
        hull(){
             translate(inlet_pos) cylinder(d=0.01, h=0.01, center=true);
             translate([channel_x_start, channel_y_offset, 0]) cylinder(d=0.01, h=0.01, center=true);
        }
        sphere(d=water_channel_dia);
    }
    // Outlet connection
    minkowski() {
        hull(){
             translate(outlet_pos) cylinder(d=0.01, h=0.01, center=true);
             translate([ outlet_x_side > 0 ? channel_x_end : channel_x_start, -channel_y_offset, 0]) cylinder(d=0.01, h=0.01, center=true);
        }
        sphere(d=water_channel_dia);
    }
}
