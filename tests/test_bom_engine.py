import math
import tempfile
from pathlib import Path
import pytest
from scripts.update_bom import (
    parse_scad_config,
    evaluate_formula,
    process_bom,
    generate_markdown_table,
    main,
)


def test_parse_scad_config_basic(tmp_path):
    scad_content = """
    // Master Config
    grid_x = 4;
    grid_y = 3;
    nozzle_spacing = 15;
    wall_margin = 10;
    stagger_y_spacing = nozzle_spacing * sqrt(3) / 2;
    block_width = (grid_x - 1) * nozzle_spacing + wall_margin * 2;
    mount_style = "side_brackets";
    is_active = true;
    $fn = 32;
    """
    config_file = tmp_path / "test_config.scad"
    config_file.write_text(scad_content, encoding="utf-8")

    cfg = parse_scad_config(str(config_file))
    assert cfg["grid_x"] == 4
    assert cfg["grid_y"] == 3
    assert cfg["nozzle_spacing"] == 15
    assert cfg["mount_style"] == "side_brackets"
    assert cfg["is_active"] is True
    assert cfg["fn"] == 32
    assert cfg["block_width"] == 65


def test_evaluate_formula():
    cfg = {"grid_x": 8, "grid_y": 6, "block_width": 125, "bolt_margin": 8}
    assert evaluate_formula("grid_x * grid_y", cfg) == 48
    assert evaluate_formula('"1"', cfg) == 1
    assert evaluate_formula("4 * 4", cfg) == 16
    assert evaluate_formula("ceil((block_width - 2 * bolt_margin) / 16)", cfg) == 7


def test_evaluate_formula_invalid():
    with pytest.raises(ValueError):
        evaluate_formula("invalid_var * 2", {})


def test_process_bom_verify_discrepancy(tmp_path):
    csv_content = (
        "Category,Part Ref,Description,Specification,Quantity Formula,Quantity (8x6),Distributor,Notes\n"
        'Standard Hardware,PH-101,Nozzle,Brass,"grid_x * grid_y",40,E3D,\n'
    )
    csv_file = tmp_path / "test_bom.csv"
    csv_file.write_text(csv_content, encoding="utf-8")

    cfg = {"grid_x": 8, "grid_y": 6}
    header, rows, discrepancies = process_bom(str(csv_file), cfg, update_quantities=False)

    assert len(discrepancies) == 1
    assert "PH-101" in discrepancies[0]
    assert "current quantity '40' != calculated '48'" in discrepancies[0]


def test_process_bom_update_quantities(tmp_path):
    csv_content = (
        "Category,Part Ref,Description,Specification,Quantity Formula,Quantity (8x6),Distributor,Notes\n"
        'Standard Hardware,PH-101,Nozzle,Brass,"grid_x * grid_y",40,E3D,\n'
    )
    csv_file = tmp_path / "test_bom.csv"
    csv_file.write_text(csv_content, encoding="utf-8")

    cfg = {"grid_x": 8, "grid_y": 6}
    header, rows, discrepancies = process_bom(str(csv_file), cfg, update_quantities=True)

    assert len(discrepancies) == 1
    assert rows[0][5] == "48"


def test_generate_markdown_table():
    header = ["Part", "Qty"]
    rows = [["PH-001", "1"], ["PH-101", "48"]]
    md = generate_markdown_table(header, rows)
    assert "| Part | Qty |" in md
    assert "| --- | --- |" in md
    assert "| PH-001 | 1 |" in md
    assert "| PH-101 | 48 |" in md


def test_cli_verify_success():
    exit_code = main(["--verify", "--config", "config.scad", "--csv", "bom.csv"])
    assert exit_code == 0


def test_cli_sync_roundtrip(tmp_path):
    # Copy bom.csv and config.scad to tmp_path
    bom_file = tmp_path / "bom.csv"
    out_md = tmp_path / "bom.md"
    bom_file.write_text(Path("bom.csv").read_text(encoding="utf-8"), encoding="utf-8")

    exit_code = main([
        "--sync",
        "--config", "config.scad",
        "--csv", str(bom_file),
        "--output", str(out_md)
    ])
    assert exit_code == 0
    assert out_md.exists()
    assert "| PH-101 |" in out_md.read_text(encoding="utf-8")
