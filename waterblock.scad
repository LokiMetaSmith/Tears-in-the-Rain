// waterblock.scad - Defines the two-piece water block component
// Optimized for manufacturing from standard plate thicknesses.

// Merged Top Plate (Water Block Top + Bowden Plate)
module water_block_top(preview=false) {
    difference() {
        // Main Body from 0.500" plate
        color("darkcyan", preview ? 0.8 : 1)
        translate([0,0,water_block_bottom_height + water_block_top_height/2])
        cube([block_width, block_depth, water_block_top_height], center=true);
        
        // Water channels milled into the bottom face
        translate([0,0,water_block_bottom_height])
        water_channels();
        
        // Clearance holes for heat breaks
        grid_map("heatbreak_clearance");
        
        // Tapped holes for Bowden couplers on the top face
        translate([0,0,water_block_bottom_height])
        grid_map("coupler_hole");
        
        // Clearance holes and counterbores for assembly bolts
        grid_map("assembly_bolt_top");
    }
}

// Bottom Plate
module water_block_bottom(preview=false) {
     difference() {
        // Main Body from 0.250" plate
        color("teal", preview ? 0.8 : 1)
        translate([0,0,water_block_bottom_height/2])
        cube([block_width, block_depth, water_block_bottom_height], center=true);
        
        // Water channels milled into the top face
        translate([0,0,water_block_bottom_height])
        water_channels();
        
        // Clearance holes for heat breaks
        grid_map("heatbreak_clearance");
        
        // Tapped holes for assembly bolts
        grid_map("assembly_bolt_bottom");
        
        // Tapped G1/4" ports for water fittings
        water_ports();
    }
}

// Defines the serpentine water channel path
module water_channels() {
    // ... (water channel logic remains the same)
}

// Defines the G1/4" threaded inlet/outlet ports
module water_ports() {
    // ... (water port logic remains the same)
}
