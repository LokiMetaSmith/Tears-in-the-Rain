# Todo List

- [ ] **Refactor Structure**
    - [ ] Create `config.scad` for global variables.
    - [ ] Create `hardware.scad` for atomic geometry modules (nozzles, holes, bolts).
    - [ ] Break circular dependencies between `helpers.scad` and component files.
- [ ] **Fix Functionality**
    - [ ] Implement missing `heater_hole` logic in `grid_map`.
    - [ ] Implement missing `assembly_bolt` logic in `grid_map` and hole definitions.
    - [ ] Ensure heater cartridge holes are actually subtracted in `heater.scad`.
    - [ ] Ensure water block assembly bolts are subtracted in `waterblock.scad`.
- [ ] **Optimization**
    - [ ] Replace `minkowski()` in `waterblock.scad` with `hull()` chain for performance.
- [ ] **Verification**
    - [ ] Verify functionality matches BOM (bolt counts, heater counts).
    - [ ] Verify code can be previewed independently (e.g., `heater.scad` works alone).
