// manufacturing_helpers.scad - Helper modules for generating manufacturing data.

// Echos a formatted string with details for a single hole.
// This creates a pipe-delimited line for easy import into spreadsheets.
module echo_hole(part_name, purpose, position, diameter, tap_info="N/A", counterbore_dia=0, counterbore_depth=0) {

    // Determine Drill Bit size (a common approximation)
    drill_bit = (tap_info != "N/A") ? str(tap_info, " Tap Drill") : str(diameter, "mm");

    // Format counterbore info
    counterbore_info = (counterbore_dia > 0)
        ? str("CBore: ", counterbore_dia, "mm dia, ", counterbore_depth, "mm deep")
        : "N/A";

    // Format the final output string
    echo(str(
        "| ", part_name, " | ",
        purpose, " | ",
        "X:", round(position.x*100)/100, " Y:", round(position.y*100)/100, " Z:", round(position.z*100)/100, " | ",
        diameter, "mm | ",
        drill_bit, " | ",
        tap_info, " | ",
        counterbore_info, " |"
    ));
}
