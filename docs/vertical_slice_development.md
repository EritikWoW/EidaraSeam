# EIDARA Vertical Slice

The project has been transformed from a single-scene demo into a playable vertical slice with a campaign structure and a complete quest loop.

## New Gameplay Structure

### 1. Campaign Menu (`scenes/main.tscn`)
- The game now starts with a campaign selection menu.
- Players can select chapters, view their status (playable vs planned), and see details.
- Progress is tracked via `GameContext` and saved to `user://eidara_progress.cfg`.
- Completing a chapter returns the player to this menu.

### 2. Playable Chapter: Platform Seven (`scenes/chapters/platform_seven.tscn`)
Platform Seven serves as the first playable sector. It demonstrates the core EIDARA mechanic: two states of the same physical location.

**The Quest Loop:**
1. **Explore (Veris):** Examine the station. Find three clues: the EIDARA poster, the ECHO/FRACTURE book board, and the arrival matrix.
2. **Activate System:** Once clues are found, the `seam` (portal) stabilizes.
3. **Cross Seam:** Use `Focus` (Q) to reveal the portal and `Interact` (E) to enter the `Fracture`.
4. **Recover Anchor:** Follow the resonance markers in the warped station to find and secure the `anchor shard`.
5. **Return:** Bring the anchor back to the `Veris` state via the portal.
6. **Unlock Route:** Use the recovered anchor frequency to unlock the Service Exit gate.
7. **City Perimeter:** Enter the city perimeter, restore the street signal cabinet, and investigate the street rift.
8. **Safehouse Node:** Synchronize resonance relays in the courtyard to open `Shelter Node 7`.
9. **Chapter Goal:** Secure the field log, restore power, and read the district map to reveal the path to the next sector.

## System Improvements

- **Diegetic HUD:** Objectives and status messages are displayed in-game to guide the player without breaking immersion.
- **Dynamic Journal:** Press `Tab` to view a detailed log of your progress, chapter design notes, and the campaign map.
- **World States:** `Veris` and `Fracture` now have distinct lighting, environment adjustments, prop visibility, and collision states.
- **Seamless Transition:** Transitions between states and areas (Station -> City) happen within the same scene for a continuous experience.

## Development Guide

### Adding New Chapters
1. Create a new `.tscn` in `scenes/chapters/`.
2. Attach a script that inherits from `Node3D` and implements:
   - `signal chapter_completed(chapter_id: String)`
   - `signal request_return_to_campaign()`
   - `func start_chapter(data: Dictionary)`
3. Register the chapter in `scripts/campaign_data.gd`.

### World State Logic
Use the pattern established in `platform_seven.gd`:
- Maintain a `world_state` variable (`veris` or `fracture`).
- Use `_apply_world_state()` to toggle visibility and collision of node groups.
- Fracture-specific objects should be grouped under descriptive parent nodes for easy management.

### Interaction System
Quest areas are handled via `Area3D` nodes. Use the `nearby_interactions` array logic to prioritize which object the player interacts with when pressing `E`.
