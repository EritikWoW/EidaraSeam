# Jules Working Notes

This repository is a Godot 4.6 project for EIDARA. Work from the repository
root, where `project.godot` lives.

## Project Shape

- Main project file: `project.godot`
- Default scene: `res://scenes/main.tscn`
- Campaign shell script: `res://scripts/main.gd`
- Campaign data: `res://scripts/campaign_data.gd`
- Global state autoload: `res://scripts/game_context.gd`
- Current world/prototype script: `res://scripts/eidara_world.gd`
- First playable chapter scene: `res://scenes/chapters/platform_seven.tscn`
- First playable chapter script: `res://scripts/chapters/platform_seven.gd`
- Design notes live under `docs/`, especially:
  - `docs/eidara_game_foundation.md`
  - `docs/eidara_seamless_world.md`
  - `docs/eidara_campaign_map.md`

## Design Rules

- Treat EIDARA as a multi-chapter game, not a one-room demo.
- Keep the contrast between `Veris` and `Fracture` strong:
  - `Veris` is intact, lived-in, and uneasy.
  - `Fracture` is visibly broken, memory-warped, and meaningful.
- Prefer the existing pattern: one chapter or sector equals one location with
  two readable states.
- Existing quest rhythm to reuse: open the route, read a clue, restore or power
  a system, then decode the next route.
- Extend the current campaign shell and scene/script routing instead of
  replacing the project architecture.

## Code Rules

- Use Godot 4.x GDScript style already present in the repo.
- Preserve tabs for GDScript indentation.
- Keep user-facing in-game text intentional and diegetic where practical.
- Do not edit `.godot/`; it is generated import/editor cache.
- Do not commit generated exports or local editor state.
- Be careful with large art/audio assets. Prefer script, scene, and data edits
  unless the task explicitly requires asset changes.

## Jules Setup

Use this setup command in Jules repository configuration:

```bash
bash tools/jules_setup.sh
```

The setup installs Godot 4.6.2 stable into the Jules VM if `godot` is not
already present, then prints the version. For heavier asset-import validation,
run:

```bash
RUN_GODOT_IMPORT=1 bash tools/jules_setup.sh
```

If a task requires importing `.blend` sources in the Jules VM, Blender may also
be needed:

```bash
INSTALL_BLENDER=1 RUN_GODOT_IMPORT=1 bash tools/jules_setup.sh
```

## Validation

- For script and scene changes, at least run `godot --version` after setup.
- When Godot import is available, run `godot --headless --path . --editor --quit`
  and report any parse/import errors.
- If Godot or Blender cannot run in the VM, say that validation was static only.
