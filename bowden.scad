// bowden.scad - Defines the Bowden coupler plate component

module bowden_coupler_plate(preview=false) {
     difference() {
        color("dimgray", preview ? 0.8 : 1)
        cube([block_width, block_depth, coupler_plate_height], center = true);
        
        grid_map("coupler_hole");
        grid_map("assembly_bolt_top", height_override=coupler_plate_height);
    }
}
