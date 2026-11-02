## Archived: 2026-11-02

* The user requires a deep planning phase with iterative questioning to clarify requirements and verify assumptions before any plan is created or work begins.
* The current development environment does not have the `openscad` CLI installed, necessitating static analysis for code validation.
* Project handoff briefings are stored in `continuity document.txt`, while active tasks are tracked in `TODO.md`.
* The user is Lawrence R Kincheloe III, an entrepreneur (Splotch Creative, Idea Forge, WeFlourish) with interests in hardware engineering and decentralized systems.
* The project is a parametric multi-nozzle 3D printer head developed in OpenSCAD, structured with `assembly.scad` as the master configuration and assembly file, and `helpers.scad` for shared hardware models.
* The repository is used to store professional blog updates (e.g., `2025_year_end_update.md`) in Markdown format alongside the technical project files.
* The Bill of Materials is maintained in `bom.csv` (using formulas dependent on `assembly.scad` configuration) and is synchronized to `bom.md` via the `scripts/update_bom.py` Python script.
* The design targets CNC manufacturing (e.g., SendCutSend) using Aluminum 6061-T6 and 5052.
