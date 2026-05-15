extends Node3D

signal chapter_completed(chapter_id: String)
signal request_return_to_campaign()

const CampaignData := preload("res://scripts/campaign_data.gd")

const WORLD_VERIS := "veris"
const WORLD_FRACTURE := "fracture"

const PHASE_EXPLORE := "explore"
const PHASE_CLUE_FOUND := "clue_found"
const PHASE_SYSTEM_ACTIVE := "system_active"
const PHASE_FRACTURE := "fracture"
const PHASE_ANCHOR_RECOVERED := "anchor_recovered"
const PHASE_RETURNED_TO_VERIS := "returned_to_veris"
const PHASE_ROUTE_UNLOCKED := "route_unlocked"
const PHASE_COMPLETE := "complete"

const FRACTURE_GRAFFITI := [
	"Decal",
	"Decal2",
	"Decal3",
	"Decal4",
	"Decal5",
	"Decal6",
	"Decal7",
	"Decal8"
]

const FRACTURE_SUBWAY_PREFIXES := [
	"wood_frame",
	"metal_wall",
	"bedding_base",
	"sleeping_bag",
	"tarp",
	"rope_post",
	"rope",
	"bench_rail_base",
	"bench",
	"chair",
	"chair_collider",
	"table",
	"garden_box",
	"potato_planter",
	"Plane_008"
]

@onready var metro: Node3D = $Metro
@onready var player: Node3D = $Metro/fps_controller
@onready var world_env: WorldEnvironment = $Metro/WorldEnvironment
@onready var directional_light: DirectionalLight3D = $Metro/DirectionalLight3D
@onready var particles: GPUParticles3D = $Metro/GPUParticles3D
@onready var subway_root: Node3D = $Metro/subway
@onready var dirt_piles: Node3D = $Metro/dirt_piles
@onready var random_floor_junk: Node3D = $Metro/random_floor_junk
@onready var trash_cans: Node3D = $Metro/trash_cans
@onready var cork_boards: Node3D = $Metro/cork_boards
@onready var soft_bodies: Node3D = $Metro/soft_bodies
@onready var decals: Node3D = $Metro/decals
@onready var music: AudioStreamPlayer = $Metro/sounds/music

@onready var header_sign: Node3D = $WorldAnchors/PlatformBranding/HeaderSign
@onready var game_poster: Node3D = $WorldAnchors/PlatformBranding/GamePoster
@onready var book_poster: Node3D = $WorldAnchors/PlatformBranding/BookPoster
@onready var arrival_matrix: Node3D = $WorldAnchors/PlatformBranding/ArrivalMatrix
@onready var matrix_core: MeshInstance3D = $WorldAnchors/PlatformBranding/ArrivalMatrix/Core
@onready var matrix_light: OmniLight3D = $WorldAnchors/PlatformBranding/ArrivalMatrix/Light

@onready var portal_rig: Node3D = $WorldAnchors/PortalRig
@onready var portal_ring: MeshInstance3D = $WorldAnchors/PortalRig/Ring
@onready var portal_core: MeshInstance3D = $WorldAnchors/PortalRig/Core
@onready var portal_back_core: MeshInstance3D = $WorldAnchors/PortalRig/BackCore
@onready var portal_light: OmniLight3D = $WorldAnchors/PortalRig/PortalLight

@onready var poster_a_area: Area3D = $WorldAnchors/QuestAreas/PosterA
@onready var poster_b_area: Area3D = $WorldAnchors/QuestAreas/PosterB
@onready var portal_area: Area3D = $WorldAnchors/QuestAreas/PortalArea
@onready var anchor_area: Area3D = $WorldAnchors/QuestAreas/AnchorArea
@onready var exit_gate_area: Area3D = $WorldAnchors/QuestAreas/ExitGateArea
@onready var matrix_area: Area3D = $WorldAnchors/QuestAreas/MatrixArea
@onready var metro_scare_a_area: Area3D = $WorldAnchors/QuestAreas/MetroScareAreaA
@onready var metro_scare_b_area: Area3D = $WorldAnchors/QuestAreas/MetroScareAreaB

@onready var resonance_trail: Node3D = $WorldAnchors/WorldBuild/ResonanceTrail
@onready var marker_a: Node3D = $WorldAnchors/WorldBuild/ResonanceTrail/MarkerA
@onready var marker_b: Node3D = $WorldAnchors/WorldBuild/ResonanceTrail/MarkerB
@onready var marker_c: Node3D = $WorldAnchors/WorldBuild/ResonanceTrail/MarkerC
@onready var metro_echo_figure: MeshInstance3D = $WorldAnchors/WorldBuild/MetroEchoFigure
@onready var metro_echo_light: OmniLight3D = $WorldAnchors/WorldBuild/MetroEchoFigure/Light

@onready var anchor_shard: Node3D = $WorldAnchors/WorldBuild/AnchorShard
@onready var anchor_core: MeshInstance3D = $WorldAnchors/WorldBuild/AnchorShard/Core
@onready var anchor_light: OmniLight3D = $WorldAnchors/WorldBuild/AnchorShard/Light

@onready var metro_exit: Node3D = $WorldAnchors/WorldBuild/MetroExit
@onready var gate_left: MeshInstance3D = $WorldAnchors/WorldBuild/MetroExit/GateLeft
@onready var gate_right: MeshInstance3D = $WorldAnchors/WorldBuild/MetroExit/GateRight
@onready var gate_blocker: StaticBody3D = $WorldAnchors/WorldBuild/MetroExit/GateBlocker
@onready var gate_blocker_shape: CollisionShape3D = $WorldAnchors/WorldBuild/MetroExit/GateBlocker/CollisionShape3D
@onready var exit_sign: Label3D = $WorldAnchors/WorldBuild/MetroExit/ExitSign

@onready var title_card: Control = $HUD/TitleCard
@onready var title_label: Label = $HUD/TitleCard/MarginContainer/VBoxContainer/Title
@onready var meta_label: Label = $HUD/TitleCard/MarginContainer/VBoxContainer/Meta
@onready var world_label: Label = $HUD/TitleCard/MarginContainer/VBoxContainer/WorldLabel
@onready var objective_label: Label = $HUD/ObjectivePanel/MarginContainer/ObjectiveLabel
@onready var prompt_label: Label = $HUD/PromptPanel/MarginContainer/PromptLabel
@onready var journal_panel: Control = $HUD/JournalPanel
@onready var journal_label: RichTextLabel = $HUD/JournalPanel/MarginContainer/JournalLabel
@onready var status_label: Label = $HUD/StatusLabel
@onready var transition_rect: ColorRect = $HUD/TransitionRect
@onready var scare_overlay: ColorRect = $HUD/ScareOverlay

var chapter_data: Dictionary = {}
var world_state := WORLD_VERIS
var phase := PHASE_EXPLORE
var focus_mode := false

var clue_found := false
var system_activated := false
var anchor_recovered := false
var returned_to_veris := false
var route_unlocked := false

var nearby_interactions: Array[String] = []
var active_interaction_id := ""
var resonance_markers: Array[Node3D] = []
var metro_fracture_roots: Array[Node] = []
var collision_layer_defaults: Dictionary = {}
var collision_mask_defaults: Dictionary = {}
var shape_disabled_defaults: Dictionary = {}
var gate_left_closed := Vector3.ZERO
var gate_right_closed := Vector3.ZERO
var scare_timer := 0.0
var metro_echo_timer := 0.0
var base_forward := Vector3.FORWARD
var base_right := Vector3.RIGHT
var metro_echo_spot_a := Vector3.ZERO
var metro_echo_spot_b := Vector3.ZERO
var portal_ring_material: StandardMaterial3D
var portal_core_material: StandardMaterial3D
var anchor_material: StandardMaterial3D
var matrix_core_material: StandardMaterial3D

func _ready() -> void:
	resonance_markers = [marker_a, marker_b, marker_c]
	gate_left_closed = gate_left.position
	gate_right_closed = gate_right.position
	portal_ring_material = _ensure_unique_material(portal_ring)
	portal_core_material = _ensure_unique_material(portal_core)
	anchor_material = _ensure_unique_material(anchor_core)
	matrix_core_material = _ensure_unique_material(matrix_core)

	_prepare_demo_scene()
	_register_quest_areas()
	_layout_world()
	_cache_fracture_roots()
	_apply_world_state(WORLD_VERIS)

	metro_exit.visible = true # Ensure the exit area and gates are visible

	_set_phase(PHASE_EXPLORE)
	_refresh_journal()
	_fade_in()

func start_chapter(data: Dictionary) -> void:
	if not data.is_empty():
		chapter_data = data.duplicate(true)
		title_label.text = str(chapter_data.get("title", "The Subway's Hum"))
		meta_label.text = "%s / %s" % [str(chapter_data.get("book", "ECHO")), str(chapter_data.get("chapter_label", "Book I / Chapter 1"))]
	_refresh_journal()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("journal"):
		journal_panel.visible = not journal_panel.visible

	if world_state == WORLD_VERIS and Input.is_action_just_pressed("focus"):
		_toggle_focus()

	if Input.is_action_just_pressed("interact"):
		_handle_interaction()

	if phase == PHASE_COMPLETE and Input.is_action_just_pressed("ui_accept"):
		request_return_to_campaign.emit()

	if metro_echo_timer > 0.0:
		metro_echo_timer = max(metro_echo_timer - delta, 0.0)
		if metro_echo_timer == 0.0:
			metro_echo_figure.visible = false
			metro_echo_light.light_energy = 0.0

	_update_active_interaction()
	_update_prompt()
	_refresh_world_label()
	_pulse_world_objects()

func _prepare_demo_scene() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if is_instance_valid(player):
		player.set("is_player_in_control", true)

func _register_quest_areas() -> void:
	_connect_area(poster_a_area, "poster_a")
	_connect_area(poster_b_area, "poster_b")
	_connect_area(portal_area, "portal")
	_connect_area(anchor_area, "anchor")
	_connect_area(exit_gate_area, "gate")
	_connect_area(matrix_area, "matrix")
	_connect_area(metro_scare_a_area, "metro_scare_a")
	_connect_area(metro_scare_b_area, "metro_scare_b")

func _connect_area(area: Area3D, area_id: String) -> void:
	area.body_entered.connect(_on_area_body_entered.bind(area_id))
	area.body_exited.connect(_on_area_body_exited.bind(area_id))

func _layout_world() -> void:
	base_forward = -player.global_transform.basis.z.normalized()
	base_right = player.global_transform.basis.x.normalized()
	var track_level := _get_track_level()
	var eye_level := track_level + 1.55
	var player_head := Vector3(player.global_position.x, eye_level, player.global_position.z)
	var tunnel_forward := player.global_transform.basis.z.normalized()
	var service_side := -base_right

	var sign_target := subway_root.get_node_or_null("sign_1") as Node3D
	var poster_target_a := cork_boards.get_node_or_null("corkboard7") as Node3D
	var poster_target_b := cork_boards.get_node_or_null("corkboard3") as Node3D

	if sign_target != null:
		_attach_surface_node(header_sign, sign_target, 0.32, 1.2)
	else:
		header_sign.global_position = Vector3(player.global_position.x, track_level + 3.6, player.global_position.z) + base_forward * 10.0
		header_sign.look_at(player_head, Vector3.UP, true)

	if poster_target_a != null:
		_attach_surface_node(game_poster, poster_target_a, 0.18, 0.0)
		poster_a_area.global_position = game_poster.global_position + Vector3.UP * 0.8
	else:
		game_poster.global_position = Vector3(player.global_position.x, track_level + 1.8, player.global_position.z) + base_forward * 9.0 + base_right * 8.0
		game_poster.look_at(player_head, Vector3.UP, true)
		poster_a_area.global_position = game_poster.global_position

	if poster_target_b != null:
		_attach_surface_node(book_poster, poster_target_b, 0.18, 0.0)
		poster_b_area.global_position = book_poster.global_position + Vector3.UP * 0.8
	else:
		book_poster.global_position = Vector3(player.global_position.x, track_level + 1.8, player.global_position.z) + base_forward * 26.0 - base_right * 9.0
		book_poster.look_at(player_head, Vector3.UP, true)
		poster_b_area.global_position = book_poster.global_position

	arrival_matrix.global_position = Vector3(player.global_position.x, track_level + 2.35, player.global_position.z) + base_forward * 12.8 - base_right * 5.9
	arrival_matrix.look_at(player_head, Vector3.UP, true)
	matrix_area.global_position = arrival_matrix.global_position + Vector3.UP * 0.25

	portal_rig.global_position = Vector3(player.global_position.x, track_level + 1.55, player.global_position.z) + base_forward * 18.0 + base_right * 1.2
	portal_rig.look_at(player_head, Vector3.UP, true)
	portal_area.global_position = portal_rig.global_position
	metro_scare_a_area.global_position = Vector3(player.global_position.x, track_level + 1.2, player.global_position.z) + base_forward * 10.5 - base_right * 1.6
	metro_scare_b_area.global_position = Vector3(player.global_position.x, track_level + 1.2, player.global_position.z) + base_forward * 27.0 + base_right * 5.2
	metro_echo_spot_a = Vector3(player.global_position.x, track_level + 1.72, player.global_position.z) + base_forward * 12.4 - base_right * 6.1
	metro_echo_spot_b = Vector3(player.global_position.x, track_level + 1.72, player.global_position.z) + base_forward * 29.2 + base_right * 6.0
	metro_echo_figure.global_position = metro_echo_spot_a
	metro_echo_figure.look_at(player_head, Vector3.UP, true)

	marker_a.global_position = Vector3(player.global_position.x, track_level + 1.0, player.global_position.z) + base_forward * 28.0 + base_right * 1.5
	marker_b.global_position = Vector3(player.global_position.x, track_level + 1.0, player.global_position.z) + base_forward * 39.0 + base_right * -1.2
	marker_c.global_position = Vector3(player.global_position.x, track_level + 1.0, player.global_position.z) + base_forward * 50.0 + base_right * 1.1
	anchor_shard.global_position = Vector3(player.global_position.x, track_level + 1.45, player.global_position.z) + base_forward * 56.0 + base_right * -1.1
	anchor_area.global_position = anchor_shard.global_position

	metro_exit.global_position = Vector3(player.global_position.x, track_level, player.global_position.z) + tunnel_forward * 42.0 + service_side * 11.8
	metro_exit.look_at(metro_exit.global_position + service_side, Vector3.UP, true)
	exit_gate_area.global_position = metro_exit.to_global(Vector3(0, 1.2, -0.8))

func _get_track_level() -> float:
	var rail := subway_root.get_node_or_null("rail_collider") as Node3D
	if rail != null:
		return rail.global_position.y + 0.06
	return player.global_position.y - 1.2

func _attach_surface_node(node: Node3D, target: Node3D, forward_offset: float, up_offset: float) -> void:
	node.global_position = target.global_position + Vector3.UP * up_offset
	var to_player := (player.global_position + Vector3.UP * 1.4 - target.global_position).normalized()
	node.look_at(node.global_position + to_player, Vector3.UP, true)
	node.global_position += -node.global_transform.basis.z.normalized() * forward_offset

func _cache_fracture_roots() -> void:
	metro_fracture_roots = [dirt_piles, random_floor_junk, soft_bodies]
	for decal_name in FRACTURE_GRAFFITI:
		var decal := decals.get_node_or_null(decal_name)
		if decal != null:
			metro_fracture_roots.append(decal)

	for child in subway_root.get_children():
		if child is Node:
			for prefix in FRACTURE_SUBWAY_PREFIXES:
				if String(child.name).begins_with(prefix):
					metro_fracture_roots.append(child)
					break

	for root in metro_fracture_roots:
		_cache_collision_state(root)
	_cache_collision_state(gate_blocker)

func _cache_collision_state(root: Node) -> void:
	if root is CollisionObject3D:
		var collision_object := root as CollisionObject3D
		collision_layer_defaults[collision_object.get_instance_id()] = collision_object.collision_layer
		collision_mask_defaults[collision_object.get_instance_id()] = collision_object.collision_mask
	if root is CollisionShape3D:
		var shape := root as CollisionShape3D
		shape_disabled_defaults[shape.get_instance_id()] = shape.disabled
	if root is CollisionPolygon3D:
		var polygon := root as CollisionPolygon3D
		shape_disabled_defaults[polygon.get_instance_id()] = polygon.disabled

	for child in root.get_children():
		_cache_collision_state(child)

func _apply_world_state(next_state: String) -> void:
	world_state = next_state
	var in_fracture := world_state == WORLD_FRACTURE

	for root in metro_fracture_roots:
		_apply_node_state(root, in_fracture, in_fracture)

	_set_trash_state(in_fracture)
	resonance_trail.visible = in_fracture
	anchor_shard.visible = in_fracture and not anchor_recovered
	anchor_area.monitoring = in_fracture and not anchor_recovered

	if in_fracture:
		portal_rig.visible = true
		directional_light.light_color = Color(0.670588, 0.619608, 0.960784, 1)
		directional_light.light_energy = 0.66
		directional_light.light_indirect_energy = 8.0
		particles.visible = true
		particles.emitting = true
		music.volume_db = -14.0
		var env := world_env.environment
		if env != null:
			env.adjustment_enabled = true
			env.adjustment_brightness = 0.64
			env.adjustment_contrast = 1.28
			env.adjustment_saturation = 0.42
			env.volumetric_fog_density = 0.04
	else:
		directional_light.light_color = Color(1, 0.964706, 0.909804, 1)
		directional_light.light_energy = 1.04
		directional_light.light_indirect_energy = 13.0
		particles.visible = false
		particles.emitting = false
		music.volume_db = -22.0
		var env_normal := world_env.environment
		if env_normal != null:
			env_normal.adjustment_enabled = true
			if focus_mode:
				env_normal.adjustment_brightness = 0.84
				env_normal.adjustment_contrast = 1.16
				env_normal.adjustment_saturation = 0.58
			else:
				env_normal.adjustment_brightness = 1.03
				env_normal.adjustment_contrast = 1.02
				env_normal.adjustment_saturation = 0.92
			env_normal.volumetric_fog_density = 0.02

func _apply_node_state(root: Node, visible_state: bool, collision_state: bool) -> void:
	if root is Node3D:
		(root as Node3D).visible = visible_state
	if root is GPUParticles3D:
		(root as GPUParticles3D).emitting = visible_state
	if root is CollisionObject3D:
		var collision_object := root as CollisionObject3D
		var collision_id := collision_object.get_instance_id()
		if collision_state:
			collision_object.collision_layer = int(collision_layer_defaults.get(collision_id, 1))
			collision_object.collision_mask = int(collision_mask_defaults.get(collision_id, 1))
		else:
			collision_object.collision_layer = 0
			collision_object.collision_mask = 0
	if root is CollisionShape3D:
		var shape := root as CollisionShape3D
		shape.disabled = not collision_state
	if root is CollisionPolygon3D:
		var polygon := root as CollisionPolygon3D
		polygon.disabled = not collision_state

	for child in root.get_children():
		_apply_node_state(child, visible_state, collision_state)

func _set_trash_state(in_fracture: bool) -> void:
	if trash_cans.has_node("trashcan2"):
		trash_cans.get_node("trashcan2").visible = in_fracture
	if trash_cans.has_node("trashcan7"):
		trash_cans.get_node("trashcan7").visible = not in_fracture
	trash_cans.visible = true
	cork_boards.visible = true

func _set_phase(next_phase: String) -> void:
	phase = next_phase
	match phase:
		PHASE_EXPLORE:
			objective_label.text = "Survey Platform Seven in Veris. Check the EIDARA panel, the book board, and the arrival matrix."
			_set_status("The platform should feel normal, yet unsettling.")
		PHASE_CLUE_FOUND:
			objective_label.text = "Clues gathered. Activate the arrival matrix to stabilize the local frequency."
			_set_status("The station is responding to your investigation.")
		PHASE_SYSTEM_ACTIVE:
			objective_label.text = "System active. Hold Focus near the seam and cross the portal."
			_set_status("The portal has stabilized: it is now a readable anomaly.")
		PHASE_FRACTURE:
			objective_label.text = "You are in the Fracture. Follow resonance markers and secure the anchor shard."
			_set_status("The Fracture didn't replace the station; it turned it inside out.")
		PHASE_ANCHOR_RECOVERED:
			objective_label.text = "Anchor secured. Return to the seam to carry the frequency back to Veris."
			_set_status("You have the anchor. Return to the normal world.")
		PHASE_RETURNED_TO_VERIS:
			objective_label.text = "Frequency returned. Use the anchor to unlock the service gate."
			_set_status("The exit now has a reason to open in the normal world.")
		PHASE_ROUTE_UNLOCKED:
			objective_label.text = "Route unlocked. Proceed through the service exit."
			_set_status("The station route is clear.")
		PHASE_COMPLETE:
			objective_label.text = "Chapter Complete. Press Enter to return to the campaign menu."
			_set_status("Platform Seven route documented.")
	_refresh_journal()

func _toggle_focus() -> void:
	focus_mode = not focus_mode
	if world_state == WORLD_VERIS:
		_apply_world_state(WORLD_VERIS)
	_refresh_journal()

func _handle_interaction() -> void:
	match active_interaction_id:
		"poster_a":
			_on_poster_a_interacted()
		"poster_b":
			_on_poster_b_interacted()
		"matrix":
			_on_matrix_interacted()
		"portal":
			_try_cross_seam()
		"anchor":
			_on_anchor_interacted()
		"gate":
			_on_gate_interacted()
		_:
			pass

func _on_poster_a_interacted() -> void:
	if clue_found: return
	_set_status("The ad panel sells a place, not a product: EIDARA feels already embedded in the station's memory.")
	_check_clue_progress()

func _on_poster_b_interacted() -> void:
	if clue_found: return
	_set_status("The book board links ECHO and FRACTURE to the station route. It's a map, not decor.")
	_check_clue_progress()

func _check_clue_progress() -> void:
	# Simplified for vertical slice: interacting with any poster counts as clue found
	clue_found = true
	_set_phase(PHASE_CLUE_FOUND)

func _on_matrix_interacted() -> void:
	if not clue_found:
		_set_status("The matrix is unresponsive. Investigate the platform first.")
		return
	if system_activated: return

	system_activated = true
	_set_phase(PHASE_SYSTEM_ACTIVE)
	_set_status("The arrival matrix outputs three points: Platform Seven, city fault, and shelter node.")

func _try_cross_seam() -> void:
	if world_state == WORLD_VERIS:
		if not system_activated:
			_set_status("Seam not stabilized. Activate the station systems first.")
			return
		if not focus_mode:
			_set_status("The seam is invisible to the naked eye. Use Focus.")
			return

		_play_transition(Color(0.262745, 0.196078, 0.392157, 0.82))
		_apply_world_state(WORLD_FRACTURE)
		_set_phase(PHASE_FRACTURE)
		focus_mode = false
	else:
		if not anchor_recovered:
			_set_status("The anchor shard must be secured before returning.")
			return

		_play_transition(Color(0.121569, 0.145098, 0.215686, 0.68))
		_apply_world_state(WORLD_VERIS)
		returned_to_veris = true
		_set_phase(PHASE_RETURNED_TO_VERIS)
		focus_mode = false

func _on_anchor_interacted() -> void:
	if world_state != WORLD_FRACTURE or anchor_recovered:
		return

	anchor_recovered = true
	_set_phase(PHASE_ANCHOR_RECOVERED)
	_set_status("Anchor frequency recorded. Return to the seam.")

func _on_gate_interacted() -> void:
	if not returned_to_veris:
		_set_status("The gate is locked by a frequency mismatch. Find the anchor in the Fracture.")
		return
	if route_unlocked: return

	route_unlocked = true
	gate_blocker_shape.disabled = true
	var tween := create_tween()
	tween.tween_property(gate_left, "position:x", gate_left_closed.x - 1.7, 0.65)
	tween.parallel().tween_property(gate_right, "position:x", gate_right_closed.x + 1.7, 0.65)

	_set_phase(PHASE_ROUTE_UNLOCKED)
	_set_status("Service gate unlocked. Route clear.")

	# Complete chapter after a short delay
	await get_tree().create_timer(2.0).timeout
	_set_phase(PHASE_COMPLETE)
	chapter_completed.emit(str(chapter_data.get("id", "echo_platform_seven")))

func _on_area_body_entered(body: Node, area_id: String) -> void:
	if body != player:
		return

	match area_id:
		"metro_scare_a":
			if world_state == WORLD_VERIS and not metro_scare_a_triggered:
				metro_scare_a_triggered = true
				_trigger_metro_scare("train_echo")
		"metro_scare_b":
			if world_state == WORLD_VERIS and not metro_scare_b_triggered:
				metro_scare_b_triggered = true
				_trigger_metro_scare("tunnel_witness")
		_:
			if not nearby_interactions.has(area_id):
				nearby_interactions.append(area_id)

func _on_area_body_exited(body: Node, area_id: String) -> void:
	if body != player:
		return
	nearby_interactions.erase(area_id)

var metro_scare_a_triggered := false
var metro_scare_b_triggered := false

func _trigger_metro_scare(scare_id: String) -> void:
	match scare_id:
		"train_echo":
			metro_echo_figure.visible = true
			metro_echo_figure.global_position = metro_echo_spot_a
			metro_echo_light.light_energy = 0.85
			metro_echo_timer = 0.75
			_set_status("Someone is in the cars, but the platform fails to secure their silhouette.")
		"tunnel_witness":
			metro_echo_figure.visible = true
			metro_echo_figure.global_position = metro_echo_spot_b
			metro_echo_light.light_energy = 1.1
			metro_echo_timer = 0.95
			_set_status("The tunnel shows a witness before the seam can fully form.")
		_:
			return

	_play_scare_overlay()

func _update_active_interaction() -> void:
	var priorities := {
		"gate": 90,
		"anchor": 80,
		"portal": 70,
		"matrix": 65,
		"poster_b": 60,
		"poster_a": 50
	}

	active_interaction_id = ""
	var best_priority := -1
	for interaction_id in nearby_interactions:
		if not _is_interaction_available(interaction_id):
			continue
		var priority := int(priorities.get(interaction_id, 0))
		if priority > best_priority:
			best_priority = priority
			active_interaction_id = interaction_id

func _is_interaction_available(interaction_id: String) -> bool:
	match interaction_id:
		"poster_a": return not clue_found
		"poster_b": return not clue_found
		"matrix": return clue_found and not system_activated
		"portal":
			if world_state == WORLD_VERIS:
				return system_activated and not returned_to_veris
			else:
				return anchor_recovered
		"anchor": return world_state == WORLD_FRACTURE and not anchor_recovered
		"gate": return returned_to_veris and not route_unlocked
		_: return false

func _update_prompt() -> void:
	if phase == PHASE_COMPLETE:
		prompt_label.text = "Enter — to campaign menu   |   Tab — journal"
		return

	match active_interaction_id:
		"poster_a":
			prompt_label.text = "E — study ad panel   |   Tab — journal"
			return
		"poster_b":
			prompt_label.text = "E — study book board   |   Tab — journal"
			return
		"matrix":
			prompt_label.text = "E — read route matrix   |   Tab — journal"
			return
		"portal":
			if world_state == WORLD_VERIS and not focus_mode:
				prompt_label.text = "Q — Focus, to hold the seam   |   Tab — journal"
			else:
				prompt_label.text = "E — cross the seam   |   Tab — journal"
			return
		"anchor":
			prompt_label.text = "E — secure anchor   |   Tab — journal"
			return
		"gate":
			prompt_label.text = "E — open service gate   |   Tab — journal"
			return
		_:
			pass

	if world_state == WORLD_VERIS:
		prompt_label.text = "Q — Focus   |   Tab — journal"
	else:
		prompt_label.text = "Fracture active: follow resonance   |   Tab — journal"

func _refresh_world_label() -> void:
	var world_text := "Veris" if world_state == WORLD_VERIS else "Fracture"
	world_label.text = "World State: %s" % world_text

func _refresh_journal() -> void:
	var lines: Array[String] = []
	lines.append("EIDARA / Campaign")
	lines.append("")
	lines.append("Current Chapter")
	lines.append("%s / %s" % [str(chapter_data.get("book", "ECHO")), str(chapter_data.get("title", "The Subway's Hum"))])
	lines.append("")
	lines.append("Current Objective")
	lines.append(objective_label.text)
	lines.append("")
	lines.append("Investigation Status")
	lines.append("Clue found: %s" % ("yes" if clue_found else "no"))
	lines.append("System active: %s" % ("yes" if system_activated else "no"))
	lines.append("Anchor recovered: %s" % ("yes" if anchor_recovered else "no"))
	lines.append("Returned to Veris: %s" % ("yes" if returned_to_veris else "no"))
	lines.append("Route unlocked: %s" % ("yes" if route_unlocked else "no"))
	lines.append("")
	lines.append("Level Design")
	lines.append("Veris: almost normal world, where anxiety hides under routine.")
	lines.append("Fracture: the same geometry after memory-slip, when the city shows its wound.")
	journal_label.text = "\n".join(lines)

func _pulse_world_objects() -> void:
	var time_value := Time.get_ticks_msec() / 1000.0
	var portal_pulse := 0.55 + 0.45 * sin(time_value * 2.1)
	var portal_visible := world_state == WORLD_FRACTURE or focus_mode or system_activated
	portal_rig.visible = portal_visible
	portal_light.light_energy = (1.4 + portal_pulse * 3.0) if portal_visible else 0.0

	if portal_ring_material != null:
		portal_ring_material.emission_energy_multiplier = 1.8 + portal_pulse * (2.8 if system_activated else 1.2)
	if portal_core_material != null:
		portal_core_material.emission_energy_multiplier = 1.4 + portal_pulse * 2.6

	portal_core.rotate_y(0.01)
	portal_back_core.rotate_y(-0.008)

	for index in resonance_markers.size():
		var marker := resonance_markers[index]
		var pulse := 0.5 + 0.5 * sin(time_value * 1.8 + float(index) * 0.85)
		marker.visible = world_state == WORLD_FRACTURE
		if marker.has_node("Mesh"):
			var mesh := marker.get_node("Mesh") as MeshInstance3D
			mesh.scale = Vector3.ONE * (0.75 + pulse * 0.25)
		if marker.has_node("Light"):
			var light := marker.get_node("Light") as OmniLight3D
			light.light_energy = (0.8 + pulse * 1.2) if world_state == WORLD_FRACTURE else 0.0

	var anchor_pulse := 0.55 + 0.45 * sin(time_value * 2.7)
	if anchor_material != null:
		anchor_material.emission_energy_multiplier = 1.8 + anchor_pulse * 2.4
	anchor_light.light_energy = (1.1 + anchor_pulse * 2.0) if world_state == WORLD_FRACTURE else 0.0

	if matrix_core_material != null:
		if system_activated:
			matrix_core_material.emission_energy_multiplier = 1.2 + portal_pulse * 0.85
			matrix_light.light_energy = 0.8 + portal_pulse * 0.45
		else:
			matrix_core_material.emission_energy_multiplier = 0.25 + max(sin(time_value * 2.7), 0.0) * 0.18
			matrix_light.light_energy = 0.18 + max(sin(time_value * 2.2), 0.0) * 0.12

func _play_transition(color: Color) -> void:
	transition_rect.color = color
	var tween := create_tween()
	tween.tween_property(transition_rect, "modulate:a", 0.72, 0.25)
	tween.tween_property(transition_rect, "modulate:a", 0.0, 0.55)

func _play_scare_overlay() -> void:
	var tween := create_tween()
	tween.tween_property(scare_overlay, "modulate:a", 0.56, 0.08)
	tween.tween_property(scare_overlay, "modulate:a", 0.18, 0.12)
	tween.tween_property(scare_overlay, "modulate:a", 0.0, 0.4)

func _fade_in() -> void:
	transition_rect.modulate.a = 1.0
	scare_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(transition_rect, "modulate:a", 0.0, 1.0)
	var title_tween := create_tween()
	title_tween.tween_interval(4.0)
	title_tween.tween_property(title_card, "modulate:a", 0.0, 2.0)
	title_tween.tween_callback(Callable(self, "_hide_title_card"))

func _set_status(message: String) -> void:
	status_label.text = message

func _hide_title_card() -> void:
	title_card.visible = false

func _ensure_unique_material(mesh: MeshInstance3D) -> StandardMaterial3D:
	var material := mesh.material_override as StandardMaterial3D
	if material != null:
		material = material.duplicate() as StandardMaterial3D
		mesh.material_override = material
	return material
