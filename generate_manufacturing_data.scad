// generate_manufacturing_data.scad
//
// This is the master file for generating manufacturing data.
// Open this file in OpenSCAD and ensure the Console is open (View > Hide Console).
// The script will not render a 3D model. Instead, it will print a formatted
// table of all the holes that need to be drilled, tapped, or counterbored
// for each part.

// --- Main Setup ---
include <assembly.scad>;

// --- OVERRIDE: Enable Data Generation Mode ---
generate_data = true;

// --- Header for the Data Table ---
echo("MANUFACTURING DATA TABLE");
echo("=========================================");
echo("| Part Name | Purpose | Position (mm) | Diameter | Drill Bit | Tap Info | Counterbore |");
echo("|---|---|---|---|---|---|---|");

// --- Call Each Part Module to Generate its Data ---
echo(" ");
echo("--- HEATER BLOCK ---");
heater_block();

echo(" ");
echo("--- WATER BLOCK TOP ---");
water_block_top();

echo(" ");
echo("--- WATER BLOCK BOTTOM ---");
water_block_bottom();

echo(" ");
echo("--- C-BRACKET (x2) ---");
c_bracket();

echo(" ");
echo("=========================================");
echo("Data generation complete.");

// Empty module call to ensure the script executes.
module dummy() {}
dummy();
