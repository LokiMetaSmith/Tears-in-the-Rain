// heater.scad - Defines the heater block component

// Main module to generate the heater block part.
module heater_block(preview=false) {
    difference() {
        // Main Body
        color("lightgray", preview ? 0.7 : 1)
        cube([block_width, block_depth, heater_block_height], center=true);
        
        // Subtract all the necessary holes by calling the grid mapper
        grid_map("nozzle_hole");
        grid_map("heater_hole");
        grid_map("mounting_hole");
        thermistor_hole_assembly();
    }
}

// Defines a single hole for a nozzle (bottom) and heat break (top)
module nozzle_and_heatbreak_hole() {
    // Nozzle hole from bottom (for M6 tap)
    translate([0, 0, -heater_block_height/2])
    cylinder(h = nozzle_thread_depth + 1, d = nozzle_tap_dia);

    // Heat break hole from top (for M6 tap)
    translate([0, 0, heater_block_height/2])
    rotate([180, 0, 0])
    cylinder(h = heatbreak_thread_depth + 1, d = heatbreak_tap_dia);

    // Filament path connecting them
    cylinder(h = heater_block_height + 2, d = filament_path_dia, center = true);
}

// Defines a single hole for a heater cartridge
module heater_hole() {
    cylinder(h = heater_block_height + 2, d = heater_cartridge_dia, center = true);
}

// Defines the hole for the thermistor and its grub screw
module thermistor_hole_assembly() {
    // Hole for the thermistor cartridge
    rotate([0,90,0])
    cylinder(h=block_width+2, d=thermistor_cartridge_dia, center=true);
    
    // Hole for the M3 grub screw from the front
    translate([0, -block_depth/2, 0])
    rotate([90,0,0])
    cylinder(h=wall_margin+1, d=thermistor_grub_screw_tap_dia);
}
