# Bill of Materials (BOM)

This BOM lists the components required for the 8x6 configuration of the Parametric Multi-Nozzle Print Head.
Quantities are based on the default grid size (8x6 = 48 nozzles).

## Custom Machined Parts

| Part Ref | Description | Material | Qty | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **PH-001** | Heater Block | 6061-T6 Aluminum | 1 | Export `heater_block_part` from `assembly.scad` |
| **PH-002** | Top Water Block / Coupler Plate | 5052 Aluminum | 1 | Export `water_block_top_part` from `assembly.scad` |
| **PH-003** | Bottom Water Block Plate | 5052 Aluminum | 1 | Export `water_block_bottom_part` from `assembly.scad` |
| **PH-004** | Water Block Gasket | High-Temp Silicone Sheet | 1 | Custom cut to match water block perimeter |
| **PH-005** | Gantry Mounting Plate | 6061-T6 Aluminum | 1 | Export `mounting_plate_part`. Required for `top_plate` mount style. |
| **PH-006** | Mounting Bracket (Optional) | 5052 Aluminum | 2 | Export `mounting_bracket_part`. Required for `side_brackets` mount style. |

## Standard Hardware

| Part Ref | Description | Specification | Qty | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **PH-101** | M6 Nozzle | E3D V6 Nozzle, Brass, 1.75mm | 48 | `grid_x * grid_y` |
| **PH-102** | M6 Heat Break | E3D V6 Style, All-Metal | 48 | `grid_x * grid_y` |
| **PH-103** | Heater Cartridge | 24V, 40W, 6mm Diameter | 48 | `grid_x * grid_y` |
| **PH-104** | Thermistor | Cartridge Style, PT100/PT1000 | 1 | |
| **PH-105** | PC4-M6 Bowden Coupler | PC4-M6 Pneumatic Fitting | 48 | `grid_x * grid_y` |
| **PH-106** | G1/4 Water Fitting | G1/4" Barb Fitting | 2 | |

## Fasteners

| Part Ref | Description | Specification | Qty | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **PH-201** | Water Block Perimeter Bolt | M3x20mm Socket Head Cap Screw | ~20 | Clamps water block halves. Not fully modeled in SCAD. |
| **PH-202** | Gantry Mounting Screw | M3x8mm Low Profile Socket Head | 4 | Attaches Mounting Plate to MGN12 carriages. (Qty 16 if using Side Brackets). |
| **PH-203** | Thermistor Grub Screw | M3x3mm Set Screw | 1 | |
| **PH-204** | Main Assembly Bolt | M3x40mm Socket Head Cap Screw | 6 | Clamps Mounting Plate, Water Block, and Heater Block together. |
| **PH-205** | M3 Nut | M3 Hex Nut | 6 | For Main Assembly Bolts. |
