// heater.scad - Defines the heater block.
include <helpers.scad>;
include <manufacturing_helpers.scad>;

// --- Original Hole Modules (for 3D rendering) ---
module nozzle_and_heatbreak_hole() {
    cylinder(h = heater_block_height + 0.2, d = nozzle_tap_dia, center = true);
}
module heater_hole() {
    cylinder(h = heater_block_height + 0.2, d = heater_cartridge_dia, center = true);
}
module thermistor_hole_assembly() {
    rotate([0,90,0]) cylinder(h=block_width+0.2, d=thermistor_cartridge_dia, center=true);
    translate([0, -block_depth/2, 0]) rotate([90,0,0]) cylinder(h=wall_margin+0.1, d=thermistor_grub_screw_tap_dia);
}
module main_assembly_bolt_tapped_holes() {
    bolt_thread_depth = 8;
    for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2]) {
        translate([x_pos, -block_depth/2 + bracket_flange_width/2, heater_block_height/2]) rotate([180,0,0]) cylinder(d=bolt_dia_tap, h=bolt_thread_depth, center=false);
        translate([x_pos, block_depth/2 - bracket_flange_width/2, heater_block_height/2]) rotate([180,0,0]) cylinder(d=bolt_dia_tap, h=bolt_thread_depth, center=false);
    }
}
module bracket_mounting_holes() {
    hole_depth = 8;
    hole_positions_x = [-block_width/4, 0, block_width/4];
    for (x_pos = hole_positions_x) {
        translate([x_pos, -block_depth/2, 0]) rotate([0, 90, 0]) cylinder(d=bolt_dia_tap, h=hole_depth);
    }
    for (x_pos = hole_positions_x) {
        translate([x_pos, block_depth/2, 0]) rotate([0, -90, 0]) cylinder(d=bolt_dia_tap, h=hole_depth);
    }
}

// --- Main Module ---
module heater_block(preview=false) {
    if (generate_data) {
        // --- DATA GENERATION MODE ---
        part_name = "Heater Block";

        // Nozzle/Heatbreak Holes (Tapped M6)
        nozzle_pos = get_nozzle_positions();
        for(pos = nozzle_pos) {
            echo_hole(part_name, "Nozzle/Heatbreak Thru-Hole", pos, nozzle_tap_dia, "M6x1.0");
        }

        // Heater Cartridge Holes
        heater_pos = get_heater_positions();
        for(pos = heater_pos) {
            echo_hole(part_name, "Heater Cartridge Thru-Hole", pos, heater_cartridge_dia);
        }

        // Main Assembly Bolt Holes (Tapped M3)
        bolt_thread_depth = 8;
        bolt_positions = [
            for (x_pos = [-bracket_width/2 + bolt_margin*2, 0, bracket_width/2 - bolt_margin*2])
                for (y_sign = [-1, 1])
                    [x_pos, y_sign * (block_depth/2 - bracket_flange_width/2), heater_block_height/2]
        ];
        for(pos = bolt_positions) {
            echo_hole(part_name, "Main Assembly Bolt", pos, bolt_dia_tap, "M3");
        }

        // Bracket Mounting Holes (Tapped M3)
        bracket_hole_depth = 8;
        bracket_hole_positions = [
            for (x_pos = [-block_width/4, 0, block_width/4])
                for (y_sign = [-1, 1])
                    [x_pos, y_sign * block_depth/2, 0]
        ];
        for(pos = bracket_hole_positions) {
            echo_hole(part_name, "Bracket Mount", pos, bolt_dia_tap, "M3");
        }

        // Thermistor Hole
        echo_hole(part_name, "Thermistor Cartridge Thru-Hole", [0,0,0], thermistor_cartridge_dia);
        echo_hole(part_name, "Thermistor Grub Screw", [0, -block_depth/2, 0], thermistor_grub_screw_tap_dia, "M3");

    } else {
        // --- 3D RENDERING MODE ---
        difference() {
            color("lightgray", preview ? 0.7 : 1)
            cube([block_width, block_depth, heater_block_height], center=true);

            grid_map("nozzle_hole");
            grid_map("heater_hole");
            main_assembly_bolt_tapped_holes();
            thermistor_hole_assembly();
            bracket_mounting_holes();
        }
    }
}
