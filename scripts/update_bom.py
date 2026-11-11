#!/usr/bin/env python3
"""scripts/update_bom.py

Parametric Bill of Materials (BOM) Calculation and Verification Engine.
Parses parametric variables from OpenSCAD config files, dynamically calculates
quantities using formulas in bom.csv, synchronizes quantities and outputs
formatted Markdown tables, and verifies consistency with CLI exit codes.
"""

import argparse
import csv
import math
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


def parse_scad_config(config_filepath: str) -> Dict[str, Any]:
    """Parse key-value definitions and mathematical expressions from an OpenSCAD config file."""
    config: Dict[str, Any] = {}
    path = Path(config_filepath)
    if not path.is_file():
        raise FileNotFoundError(f"SCAD config file not found: {config_filepath}")

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Strip block comments
    content = re.sub(r"/\*.*?\*/", "", content, flags=re.DOTALL)

    eval_globals = {
        "__builtins__": {},
        "sqrt": math.sqrt,
        "ceil": math.ceil,
        "floor": math.floor,
        "round": round,
        "abs": abs,
        "min": min,
        "max": max,
        "PI": math.pi,
    }

    for line in content.splitlines():
        line = line.strip()
        if not line or line.startswith("//"):
            continue

        # Strip line comments
        if "//" in line:
            line = line.split("//")[0].strip()

        if "=" in line:
            parts = line.split("=", 1)
            var_name = parts[0].strip().lstrip("$")
            raw_val = parts[1].split(";")[0].strip()

            # Handle string literals
            if (raw_val.startswith('"') and raw_val.endswith('"')) or (
                raw_val.startswith("'") and raw_val.endswith("'")
            ):
                config[var_name] = raw_val[1:-1]
                continue

            # Handle boolean literals
            if raw_val.lower() == "true":
                config[var_name] = True
                continue
            if raw_val.lower() == "false":
                config[var_name] = False
                continue

            # Attempt mathematical evaluation with existing variables
            eval_scope = {**eval_globals, **config}
            try:
                val = eval(raw_val, eval_scope)
                config[var_name] = val
            except Exception:
                # If cannot evaluate directly, keep raw string
                config[var_name] = raw_val

    return config


def evaluate_formula(formula: str, config: Dict[str, Any]) -> Any:
    """Evaluate a BOM formula string against config variables."""
    cleaned = formula.strip().strip('"').strip("'")
    if not cleaned:
        return ""

    # If it's a plain integer or float
    if re.fullmatch(r"^-?\d+$", cleaned):
        return int(cleaned)
    if re.fullmatch(r"^-?\d+\.\d+$", cleaned):
        return float(cleaned)

    eval_globals = {
        "__builtins__": {},
        "sqrt": math.sqrt,
        "ceil": math.ceil,
        "floor": math.floor,
        "round": round,
        "abs": abs,
        "min": min,
        "max": max,
    }
    eval_scope = {**eval_globals, **config}

    try:
        val = eval(cleaned, eval_scope)
        if isinstance(val, float) and val.is_integer():
            return int(val)
        return val
    except Exception as e:
        raise ValueError(f"Failed to evaluate formula '{formula}': {e}") from e


def process_bom(
    csv_filepath: str,
    config: Dict[str, Any],
    update_quantities: bool = True,
) -> Tuple[List[str], List[List[str]], List[str]]:
    """Reads bom.csv, evaluates formulas, checks consistency, and returns (header, rows, discrepancies)."""
    path = Path(csv_filepath)
    if not path.is_file():
        raise FileNotFoundError(f"CSV file not found: {csv_filepath}")

    with open(path, "r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        all_rows = list(reader)

    if not all_rows:
        return [], [], ["CSV file is empty."]

    header = all_rows[0]
    data_rows = all_rows[1:]

    # Locate formula and quantity columns
    formula_idx = -1
    qty_idx = -1
    for idx, col in enumerate(header):
        normalized = col.strip().lower()
        if "formula" in normalized:
            formula_idx = idx
        elif "quantity" in normalized or "qty" in normalized:
            qty_idx = idx

    discrepancies: List[str] = []
    processed_rows: List[List[str]] = []

    for row_num, row in enumerate(data_rows, start=2):
        new_row = list(row)
        if formula_idx != -1 and qty_idx != -1 and formula_idx < len(row) and qty_idx < len(row):
            formula = row[formula_idx].strip()
            current_qty = row[qty_idx].strip()
            part_ref = row[1] if len(row) > 1 else f"Row {row_num}"

            if formula:
                try:
                    calculated_qty = evaluate_formula(formula, config)
                    calc_str = str(calculated_qty)
                    if current_qty != calc_str:
                        discrepancies.append(
                            f"{part_ref}: current quantity '{current_qty}' != calculated '{calc_str}' (formula: '{formula}')"
                        )
                        if update_quantities:
                            new_row[qty_idx] = calc_str
                except Exception as e:
                    discrepancies.append(f"{part_ref}: error evaluating '{formula}': {e}")

        processed_rows.append(new_row)

    return header, processed_rows, discrepancies


def write_csv(csv_filepath: str, header: List[str], rows: List[List[str]]) -> None:
    """Save processed rows back to CSV."""
    with open(csv_filepath, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)


def generate_markdown_table(header: List[str], rows: List[List[str]]) -> str:
    """Format table data into Markdown table string."""
    if not header:
        return "# Bill of Materials\n\n(No data)\n"

    markdown_lines = ["# Bill of Materials\n"]
    markdown_lines.append("| " + " | ".join(header) + " |")
    markdown_lines.append("| " + " | ".join(["---"] * len(header)) + " |")

    for row in rows:
        safe_row = [str(cell) if cell is not None else "" for cell in row]
        markdown_lines.append("| " + " | ".join(safe_row) + " |")

    return "\n".join(markdown_lines) + "\n"


def write_markdown(md_filepath: str, header: List[str], rows: List[List[str]]) -> None:
    """Write markdown table to destination file."""
    md_content = generate_markdown_table(header, rows)
    with open(md_filepath, "w", encoding="utf-8") as f:
        f.write(md_content)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Parametric BOM Calculation and Verification Tool for Multi-Nozzle 3D Printer Head."
    )
    parser.add_argument(
        "--config",
        "-c",
        default="config.scad",
        help="Path to OpenSCAD config file (default: config.scad)",
    )
    parser.add_argument(
        "--csv",
        default="bom.csv",
        help="Path to BOM CSV file (default: bom.csv)",
    )
    parser.add_argument(
        "--output",
        "-o",
        default="bom.md",
        help="Path to output Markdown file (default: bom.md)",
    )
    parser.add_argument(
        "--sync",
        action="store_true",
        help="Recalculate quantities from config formulas and update both CSV and Markdown files.",
    )
    parser.add_argument(
        "--verify",
        "--check",
        dest="verify",
        action="store_true",
        help="Verify that recorded quantities match computed parametric formulas without altering files. Exits non-zero on mismatch.",
    )

    args = parser.parse_args(argv)

    try:
        config = parse_scad_config(args.config)
    except Exception as e:
        print(f"Error loading SCAD config from '{args.config}': {e}", file=sys.stderr)
        return 1

    update_in_place = args.sync or (not args.verify)
    try:
        header, rows, discrepancies = process_bom(
            args.csv,
            config,
            update_quantities=update_in_place,
        )
    except Exception as e:
        print(f"Error processing BOM: {e}", file=sys.stderr)
        return 1

    if args.verify:
        if discrepancies:
            print("BOM Verification Failed! Found discrepancies:")
            for d in discrepancies:
                print(f"  - {d}")
            return 2
        else:
            print("BOM Verification Successful: all quantities match parametric configuration.")
            return 0

    # If syncing or default update
    if update_in_place and args.sync:
        write_csv(args.csv, header, rows)
        print(f"Updated CSV quantities in {args.csv}")

    write_markdown(args.output, header, rows)
    print(f"Successfully converted {args.csv} to {args.output}")

    if discrepancies:
        print(f"Notice: {len(discrepancies)} discrepancies were synchronized:")
        for d in discrepancies:
            print(f"  * {d}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
