// heater.scad - Defines the heater block component

module heater_block(preview=false) {
    difference() {
        color("lightgray", preview ? 0.7 : 1)
        cube([block_width, block_depth, heater_block_height], center=true);
        
        grid_map("nozzle_hole");
        grid_map("heater_hole");
        grid_map("mounting_hole");
        thermistor_hole_assembly();
    }
}

module nozzle_and_heatbreak_hole() {
    translate([0, 0, -heater_block_height/2]) cylinder(h = nozzle_thread_depth + 1, d = nozzle_tap_dia);
    translate([0, 0, heater_block_height/2]) rotate([180, 0, 0]) cylinder(h = heatbreak_thread_depth + 1, d = heatbreak_tap_dia);
    cylinder(h = heater_block_height + 2, d = filament_path_dia, center = true);
}

module heater_hole() {
    cylinder(h = heater_block_height + 2, d = heater_cartridge_dia, center = true);
}

module thermistor_hole_assembly() {
    rotate([0,90,0]) cylinder(h=block_width+2, d=thermistor_cartridge_dia, center=true);
    translate([0, -block_depth/2, 0]) rotate([90,0,0]) cylinder(h=wall_margin+1, d=thermistor_grub_screw_tap_dia);
}
