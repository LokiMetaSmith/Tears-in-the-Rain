import glob
import math
import re
from pathlib import Path
import pytest
from scripts.update_bom import parse_scad_config


def get_all_scad_files():
    return sorted(glob.glob("*.scad"))


def test_scad_files_bracket_matching():
    """Verify that all OpenSCAD files have properly matched braces, brackets, and parentheses."""
    files = get_all_scad_files()
    assert len(files) > 0, "No .scad files found"

    opens = {"{": "}", "(": ")", "[": "]"}
    closes = {"}": "{", ")": "(", "]": "["}

    for fpath in files:
        content = Path(fpath).read_text(encoding="utf-8")
        # Strip comments
        no_comments = re.sub(r"/\*.*?\*/", "", content, flags=re.DOTALL)
        no_comments = re.sub(r"//.*", "", no_comments)

        stack = []
        for char_idx, char in enumerate(no_comments):
            if char in opens:
                stack.append(char)
            elif char in closes:
                assert stack, f"Unmatched closing '{char}' at index {char_idx} in {fpath}"
                expected = closes[char]
                actual = stack.pop()
                assert actual == expected, (
                    f"Mismatched bracket in {fpath}: expected '{opens[actual]}', got '{char}'"
                )

        assert not stack, f"Unclosed brackets {stack} in {fpath}"


def test_scad_no_malformed_assignments():
    """Ensure no bare assignments like '=64;' or malformed parameter lists remain in SCAD files."""
    files = get_all_scad_files()
    for fpath in files:
        lines = Path(fpath).read_text(encoding="utf-8").splitlines()
        for idx, line in enumerate(lines, start=1):
            stripped = line.strip()
            # check for bare assignment
            assert not re.match(r"^=\s*\d+;", stripped), f"Bare assignment error at {fpath}:{idx}"
            # check for malformed param assignment like ', =6'
            assert not re.search(r",\s*=\s*\d+", stripped), f"Bare parameter assignment error at {fpath}:{idx}"


def test_scad_geometric_clearances():
    """Verify parametric geometric constraints: clearance, wall margins, and nozzle spacing."""
    cfg = parse_scad_config("config.scad")

    # Clearance constraint: spacing between nozzles must be greater than nozzle tap diameter
    assert cfg["nozzle_spacing"] > cfg["nozzle_tap_dia"], "Nozzle spacing must exceed tap diameter"

    # Block width and depth must be positive and larger than active grid area
    grid_area_w = (cfg["grid_x"] - 1) * cfg["nozzle_spacing"]
    grid_area_d = (cfg["grid_y"] - 1) * cfg["stagger_y_spacing"]
    assert cfg["block_width"] > grid_area_w
    assert cfg["block_depth"] > grid_area_d
    assert cfg["block_width"] == grid_area_w + cfg["wall_margin"] * 2
    assert cfg["block_depth"] == grid_area_d + cfg["wall_margin"] * 2

    # Port clearance vs nozzle spacing
    assert cfg["port_clearance"] > 0
    assert cfg["wall_margin"] >= 8, "Wall margin should be at least 8mm for structural stability"


def test_nozzle_and_heater_grid_counts():
    """Verify that the calculated nozzle and heater cartridge positions match grid_x * grid_y."""
    cfg = parse_scad_config("config.scad")
    expected_count = cfg["grid_x"] * cfg["grid_y"]
    assert expected_count == 48

    # Calculate nozzle positions per positions.scad logic
    offset_x = -(cfg["grid_x"] - 1) * cfg["nozzle_spacing"] / 2
    offset_y = -((cfg["grid_y"] - 1) * cfg["stagger_y_spacing"]) / 2
    center_adj = -cfg["nozzle_spacing"] / 4 if (cfg["grid_x"] % 2 == 0) else 0

    nozzle_positions = []
    for y in range(cfg["grid_y"]):
        for x in range(cfg["grid_x"]):
            stagger = (cfg["nozzle_spacing"] / 2) if (y % 2 == 1) else 0
            pos = (
                offset_x + x * cfg["nozzle_spacing"] + stagger + center_adj,
                offset_y + y * cfg["stagger_y_spacing"],
                0,
            )
            nozzle_positions.append(pos)

    assert len(nozzle_positions) == expected_count

    # Verify all nozzles lie strictly within block bounds with wall margin
    for pos_x, pos_y, _ in nozzle_positions:
        assert abs(pos_x) <= (cfg["block_width"] / 2)
        assert abs(pos_y) <= (cfg["block_depth"] / 2)
