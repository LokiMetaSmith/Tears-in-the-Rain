// helpers.scad - Contains all hardware models and placement logic.
// HELPER MODULES (Defined before includes)
// =============================================================================

module hardware(type,preview=false) {

    if (type=="nozzle"){ 
    color("Orange", preview ? 0.7 : 1) rotate([180,0,0])union(){translate([0,0,-nozzle_thread_depth])cylinder(d=nozzle_tap_dia, h=nozzle_thread_depth + 0.1); 
     cylinder(d1=7, d2=2, h=5); 
    }}
    if (type=="heater") color("red", preview ? 0.7 : 1) cylinder(d=heater_cartridge_dia, h=heater_block_height, center=false);
    if (type=="thermistor") color("green", preview ? 0.7 : 1) rotate([0,90,0]) cylinder(d=thermistor_cartridge_dia, h=block_width, center=true);
    if (type=="heatbreak") color("Cyan", preview ? 0.7 : 1) { cylinder(d=7, h=total_water_block_height); translate([0,0,-heatbreak_thread_depth]) cylinder(d=6, h=heatbreak_thread_depth); }
    if (type=="coupler") color("gold", preview ? 0.7 : 1) { cylinder(d=m3_clearance_dia, h=4); translate([0,0,4]) cylinder(d=8, h=5, $fn=6); translate([0,0,9]) color("white", preview ? 0.7 : 1) cylinder(d=10, h=4); }
    if (type=="assembly_bolt") color("gray",  preview ? 0.7 : 1) {
        translate([0,0,total_water_block_height]) cylinder(d=bolt_head_dia, h=bolt_head_depth);
        translate([0,0,total_water_block_height]) cylinder(d=bolt_dia_clearance, h=-total_water_block_height);
    }
    if (type=="main_assembly_bolt") color("gray",  preview ? 0.7 : 1) {
        // Model a bolt inserted from the top of the water block, threading into the heater block.
        bolt_length = total_water_block_height + heater_block_height/2;
        translate([0,0,total_water_block_height/2]) {
             // Bolt Head
             rotate([180,0,0]) cylinder(d=bolt_head_dia, h=bolt_head_depth);
             // Bolt Shaft
             rotate([180,0,0]) cylinder(d=bolt_dia_clearance, h=bolt_length);
        }
    }
}

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
        translate([0,0,-heater_block_height/2]) grid_map_hardware(type,preview);
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
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            pos = [nozzle_spacing/2 + offset_x + x * nozzle_spacing - stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
           // y_pos = offset_y + y*stagger_y_spacing + stagger_y_spacing/2;
           // x_pos = offset_x + x*nozzle_spacing + nozzle_spacing/2 + center_adj;
            translate(pos) hardware(type,preview);
        }
    }
    else if (type=="main_assembly_bolt") {
        for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
            translate([x_pos, -block_depth/2 + bracket_flange_width/2, 0]) hardware("main_assembly_bolt",preview);
            translate([x_pos, block_depth/2 - bracket_flange_width/2, 0]) hardware("main_assembly_bolt",preview);
        }
    }}
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
    if (type=="heater_hole") { /* ... heater hole logic ... */ }
    if (type=="assembly_bolt_top" || type=="assembly_bolt_bottom") { /* ... bolt logic ... */ }
    if (type=="mounting_hole") { top_mounting_holes(); }
}