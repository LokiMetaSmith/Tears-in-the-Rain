// helpers.scad - Contains placement logic.
include <config.scad>;
include <hardware.scad>;
// include <mounting_plate.scad>; // Removed to avoid circular dependency

// Helper to place hardware models
module place_hardware(type,preview=false) {
    offset_x = -(grid_x - 1) * nozzle_spacing / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;
    center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0;
    
    if (type=="thermistor")
    { 
        hardware("thermistor",preview);
    }
    else if (type=="nozzle") {
        translate([0,0,-heater_block_height/2]) grid_map_hardware(type,preview);
    }
    else if (type=="heatbreak") {
        translate([0,0,0]) grid_map_hardware(type,preview);
    }
    else if (type=="coupler") {
        translate([0,0,total_water_block_height]) grid_map_hardware(type,preview);
    }
    else if (type=="heater") {
        translate([0,0,0]) grid_map_hardware(type,preview);
    }
    else if (type=="assembly_bolt") {
        translate([0,0,0]) grid_map_hardware(type,preview);
    }
    else if (type=="main_assembly_bolt") {
        for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
            translate([x_pos, -block_depth/2 + bracket_flange_width/2, 0]) hardware("main_assembly_bolt",preview);
            translate([x_pos, block_depth/2 - bracket_flange_width/2, 0]) hardware("main_assembly_bolt",preview);
        }
    }
}

module grid_map_hardware(type,preview=false) {
    offset_x = -(grid_x - 1) * nozzle_spacing / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;
    center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0;
    
    if (type=="nozzle") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            pos = [offset_x + x * nozzle_spacing + stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
            translate(pos) hardware(type,preview);
        }
    }
    else if (type=="coupler") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            pos = [offset_x + x * nozzle_spacing + stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
            translate(pos) hardware(type,preview);
        }
    }
    else if (type=="heatbreak") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            pos = [offset_x + x * nozzle_spacing + stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
            translate(pos) hardware(type,preview);
        }
    }
    else if (type=="heater") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            if (x < grid_x - 1) {
                 effective_stagger = (y % 2 == 0) ? nozzle_spacing/2 : 0;
                 pos = [offset_x + x * nozzle_spacing + effective_stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
                 translate(pos) hardware(type,preview);
            }
        }
    }
    else if (type=="assembly_bolt") {
       // Logic to place bolts around the perimeter
       // Bolts along X (top and bottom edges)
       x_start = -block_width/2 + bolt_margin;
       x_end = block_width/2 - bolt_margin;
       // Calculate number of steps to space them roughly 2*bolt_margin apart (16mm)
       num_x = ceil((x_end - x_start) / (bolt_margin*3)); // Spread them out a bit
       x_inc = (x_end - x_start) / num_x;

       for (i=[0:num_x]) {
           x = x_start + i*x_inc;
           translate([x, -block_depth/2 + bolt_margin, 0]) hardware("assembly_bolt", preview);
           translate([x, block_depth/2 - bolt_margin, 0]) hardware("assembly_bolt", preview);
       }

       // Bolts along Y (left and right edges)
       y_start = -block_depth/2 + bolt_margin + x_inc; // Start after corner? No, corners covered.
       y_end = block_depth/2 - bolt_margin - x_inc;

       // We can just do a loop for Y
       y_dist = block_depth - 2*bolt_margin;
       num_y = ceil(y_dist / (bolt_margin*3));
       y_inc = y_dist / num_y;

        for (i=[1:num_y-1]) { // Skip first and last as they are corners covered by X loop
           y = -block_depth/2 + bolt_margin + i*y_inc;
           translate([-block_width/2 + bolt_margin, y, 0]) hardware("assembly_bolt", preview);
           translate([block_width/2 - bolt_margin, y, 0]) hardware("assembly_bolt", preview);
       }
    }
}

module grid_map(type,preview=false) {
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
    else if (type=="heater_hole") {
         for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            if (x < grid_x - 1) {
                 effective_stagger = (y % 2 == 0) ? nozzle_spacing/2 : 0;
                 pos = [offset_x + x * nozzle_spacing + effective_stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
                 translate(pos) heater_hole();
            }
        }
    }
    else if (type=="assembly_bolt_top" || type=="assembly_bolt_bottom") {
       // Logic to subtract bolts
       // Bolts along X (top and bottom edges)
       x_start = -block_width/2 + bolt_margin;
       x_end = block_width/2 - bolt_margin;
       num_x = ceil((x_end - x_start) / (bolt_margin*3));
       x_inc = (x_end - x_start) / num_x;

       for (i=[0:num_x]) {
           x = x_start + i*x_inc;
           translate([x, -block_depth/2 + bolt_margin, 0]) bolt_hole_logic(type);
           translate([x, block_depth/2 - bolt_margin, 0]) bolt_hole_logic(type);
       }

       y_dist = block_depth - 2*bolt_margin;
       num_y = ceil(y_dist / (bolt_margin*3));
       y_inc = y_dist / num_y;

        for (i=[1:num_y-1]) {
           y = -block_depth/2 + bolt_margin + i*y_inc;
           translate([-block_width/2 + bolt_margin, y, 0]) bolt_hole_logic(type);
           translate([block_width/2 - bolt_margin, y, 0]) bolt_hole_logic(type);
       }
    }
    if (type=="mounting_hole") { top_mounting_holes_clearance_shared(); }
}

module bolt_hole_logic(type) {
    if (type == "assembly_bolt_top") {
        // Clearance in top plate
        cylinder(d=bolt_dia_clearance, h=water_block_top_height+0.2, center=true);
        // Counterbore
        translate([0,0, water_block_top_height/2 - bolt_head_depth]) cylinder(d=bolt_head_dia, h=bolt_head_depth+0.1);
    } else {
        // Thread in bottom plate
        cylinder(d=bolt_dia_tap, h=water_block_bottom_height+0.2, center=true);
    }
}
