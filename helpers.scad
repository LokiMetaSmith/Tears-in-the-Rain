// helpers.scad - Contains all hardware models and placement logic.

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
    if (type=="heater_hole") { /* ... heater hole logic ... */ }
    if (type=="assembly_bolt_top" || type=="assembly_bolt_bottom") { /* ... bolt logic ... */ }
    if (type=="mounting_hole") { top_mounting_holes(); }
}

module place_hardware(type) {
    offset_x = -(grid_x - 1) * nozzle_spacing / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;
    center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0;
    
    if (type=="thermistor") hardware("thermistor");
    else if (type=="nozzle") {
        translate([0,0,-heater_block_height/2]) grid_map_hardware(type);
    }
    else if (type=="heatbreak") {
        translate([0,0,0]) grid_map_hardware(type);
    }
    else if (type=="coupler") {
        translate([0,0,total_water_block_height]) grid_map_hardware(type);
    }
    else if (type=="heater") {
        translate([0,0,-heater_block_height/2]) grid_map_hardware(type);
    }
    else if (type=="assembly_bolt") {
        translate([0,0,0]) grid_map_hardware(type);
    }
}

module grid_map_hardware(type) {
    offset_x = -(grid_x - 1) * nozzle_spacing / 2;
    offset_y = -((grid_y - 1) * stagger_y_spacing) / 2;
    center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0;
    
    if (type=="nozzle" || type=="heatbreak" || type=="coupler") {
        for (y = [0 : grid_y - 1]) for (x = [0 : grid_x - 1]) {
            stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0;
            pos = [offset_x + x * nozzle_spacing + stagger + center_adj, offset_y + y * stagger_y_spacing, 0];
            translate(pos) hardware(type);
        }
    }
    if (type=="heater") { /* ... heater hardware placement ... */ }
    if (type=="assembly_bolt") { /* ... bolt hardware placement ... */ }
}
