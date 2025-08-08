// positions.scad - Functions for calculating hole positions.

// Function to get a list of all nozzle center coordinates.
function get_nozzle_positions() = [
    for (y = [0 : grid_y - 1])
        for (x = [0 : grid_x - 1])
            let (
                offset_x = -(grid_x - 1) * nozzle_spacing / 2,
                offset_y = -((grid_y - 1) * stagger_y_spacing) / 2,
                center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0,
                stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0
            )
            [offset_x + x * nozzle_spacing + stagger + center_adj, offset_y + y * stagger_y_spacing, 0]
];

// Function to get a list of all heater cartridge center coordinates.
function get_heater_positions() = [
     for (y = [0 : grid_y - 1])
        for (x = [0 : grid_x - 1])
            let (
                offset_x = -(grid_x - 1) * nozzle_spacing / 2,
                offset_y = -((grid_y - 1) * stagger_y_spacing) / 2,
                center_adj = (grid_x % 2 == 0) ? -nozzle_spacing/4 : 0,
                stagger = (y % 2 == 1) ? nozzle_spacing / 2 : 0
            )
            [nozzle_spacing/2 + offset_x + x * nozzle_spacing - stagger + center_adj, offset_y + y * stagger_y_spacing, 0]
];
