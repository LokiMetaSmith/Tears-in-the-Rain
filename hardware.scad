// hardware.scad - Defines atomic geometry modules (holes, hardware).
// Intended to be included by helpers.scad and component files.

include <config.scad>;

// Defines a single hole for a nozzle (bottom) and heat break (top)
module nozzle_and_heatbreak_hole() {
    translate([0, 0, -heater_block_height/2]) cylinder(h = nozzle_thread_depth + 0.1, d = nozzle_tap_dia);
    translate([0, 0, heater_block_height/2]) rotate([180, 0, 0]) cylinder(h = heatbreak_thread_depth + 0.1, d = heatbreak_tap_dia);
    cylinder(h = heater_block_height + 0.2, d = filament_path_dia, center = true);
}

// Defines a single hole for a heater cartridge
module heater_hole() {
    cylinder(h = heater_block_height + 0.2, d = heater_cartridge_dia, center = true);
}

// Defines the hole for the thermistor and its grub screw
module thermistor_hole_assembly() {
    rotate([0,90,0]) cylinder(h=block_width+0.2, d=thermistor_cartridge_dia, center=true);
    translate([0, -block_depth/2, 0]) rotate([90,0,0]) cylinder(h=wall_margin+0.1, d=thermistor_grub_screw_tap_dia);
}

// Moved from mounting_plate.scad to avoid circular dependency
module top_mounting_holes_clearance_shared() {
     // Note: The logic in mounting_plate.scad used a for loop with step.
     // x_pos = [-block_width/2 + bolt_margin : block_width/2 - bolt_margin*2 : block_width/2 - bolt_margin]
     // This generates two points: -W/2+M and W/2-M if step is W/2-M*2?
     // Actually the step is (block_width/2 - bolt_margin*2) which is huge.
     // It seems to intend to place 4 corner bolts.
     // Let's replicate the logic exactly or fix it.
     // The loop: for (x = start : step : end)
     // start = -BW/2 + BM
     // end = BW/2 - BM
     // step = BW/2 - BM*2 ??? This looks like it tries to step by the full width?
     // It probably means "start at left, step by (width-2*margin), end at right".
     // Which results in exactly 2 points.

    for (x_pos = [-block_width/2 + bolt_margin, block_width/2 - bolt_margin]) {
        for (y_pos = [-block_depth/2 + bolt_margin, block_depth/2 - bolt_margin]) {
            translate([x_pos, y_pos, 0])
            cylinder(d=m3_clearance_dia, h=mounting_plate_thickness+0.2, center=true);
        }
    }
}

// Visual hardware models
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
        translate([0,0,total_water_block_height + heater_block_height/2]) {
             cylinder(d=bolt_head_dia, h=3); // Nut
             translate([0,0,-3]) cylinder(d=m3_clearance_dia, h=-(total_water_block_height+heater_block_height+bracket_thickness)); // Bolt shaft
        }
    }
}
