extends Node3D

const WORLD_VERIS := "veris"
const WORLD_FRACTURE := "fracture"

const STAGE_SURVEY := "survey"
const STAGE_PORTAL := "portal"
const STAGE_FRACTURE := "fracture"
const STAGE_RETURN := "return"
const STAGE_EXIT := "exit"
const STAGE_CITY := "city"
const STAGE_CITY_RIFT := "city_rift"
const STAGE_COURTYARD := "courtyard"
const STAGE_SAFEHOUSE := "safehouse"
const STAGE_SAFEHOUSE_LOG := "safehouse_log"
const STAGE_SAFEHOUSE_POWER := "safehouse_power"
const STAGE_SAFEHOUSE_MAP := "safehouse_map"
const STAGE_COMPLETE := "complete"

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
@onready var city_entry_area: Area3D = $WorldAnchors/QuestAreas/CityEntryArea
@onready var signal_box_area: Area3D = $WorldAnchors/QuestAreas/SignalBoxArea
@onready var scare_a_area: Area3D = $WorldAnchors/QuestAreas/ScareAreaA
@onready var scare_b_area: Area3D = $WorldAnchors/QuestAreas/ScareAreaB
@onready var city_goal_area: Area3D = $WorldAnchors/QuestAreas/CityGoalArea
@onready var matrix_area: Area3D = $WorldAnchors/QuestAreas/MatrixArea
@onready var metro_scare_a_area: Area3D = $WorldAnchors/QuestAreas/MetroScareAreaA
@onready var metro_scare_b_area: Area3D = $WorldAnchors/QuestAreas/MetroScareAreaB
@onready var relay_a_area: Area3D = $WorldAnchors/QuestAreas/RelayAArea
@onready var relay_b_area: Area3D = $WorldAnchors/QuestAreas/RelayBArea
@onready var safehouse_area: Area3D = $WorldAnchors/QuestAreas/SafehouseArea
@onready var safehouse_log_area: Area3D = $WorldAnchors/QuestAreas/SafehouseLogArea
@onready var safehouse_terminal_area: Area3D = $WorldAnchors/QuestAreas/SafehouseTerminalArea
@onready var safehouse_map_area: Area3D = $WorldAnchors/QuestAreas/SafehouseMapArea

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

@onready var city_zone: Node3D = $WorldAnchors/WorldBuild/CityZone
@onready var city_billboard: Node3D = $WorldAnchors/WorldBuild/CityZone/Billboard
@onready var billboard_light: OmniLight3D = $WorldAnchors/WorldBuild/CityZone/Billboard/BillboardLight
@onready var signal_box: Node3D = $WorldAnchors/WorldBuild/CityZone/SignalCabinet
@onready var signal_box_core: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/SignalCabinet/Core
@onready var city_figure: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/ScareFigure
@onready var street_light_a: OmniLight3D = $WorldAnchors/WorldBuild/CityZone/StreetLights/PostA/Light
@onready var street_light_b: OmniLight3D = $WorldAnchors/WorldBuild/CityZone/StreetLights/PostB/Light
@onready var street_light_c: OmniLight3D = $WorldAnchors/WorldBuild/CityZone/StreetLights/PostC/Light
@onready var city_fracture_layer: Node3D = $WorldAnchors/WorldBuild/CityZone/FractureLayer
@onready var city_rift_sphere: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/FractureLayer/RiftSphere
@onready var city_rift_light: OmniLight3D = $WorldAnchors/WorldBuild/CityZone/FractureLayer/RiftLight
@onready var courtyard_route: Node3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute
@onready var relay_a_core: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/RelayA/Core
@onready var relay_b_core: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/RelayB/Core
@onready var safehouse_door_left: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/SafehouseDoor/DoorLeft
@onready var safehouse_door_right: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/SafehouseDoor/DoorRight
@onready var safehouse_blocker_shape: CollisionShape3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/SafehouseDoor/DoorBlocker/CollisionShape3D
@onready var safehouse_light: OmniLight3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/SafehouseDoor/Light
@onready var safehouse_terminal_core: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/SafehouseDoor/Terminal/Core
@onready var safehouse_terminal_light: OmniLight3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/SafehouseDoor/Terminal/Light
@onready var safehouse_map_core: MeshInstance3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/SafehouseDoor/WallMap/Core
@onready var safehouse_map_light: OmniLight3D = $WorldAnchors/WorldBuild/CityZone/CourtyardRoute/SafehouseDoor/WallMap/Light

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

var world_state := WORLD_VERIS
var stage := STAGE_SURVEY
var focus_mode := false
var poster_seen := false
var book_board_seen := false
var route_matrix_seen := false
var portal_stable := false
var fracture_anchor_secured := false
var exit_gate_open := false
var city_entered := false
var city_signal_restored := false
var city_goal_documented := false
var courtyard_route_open := false
var relay_a_aligned := false
var relay_b_aligned := false
var safehouse_open := false
var safehouse_log_found := false
var safehouse_terminal_online := false
var district_map_read := false
var metro_scare_a_triggered := false
var metro_scare_b_triggered := false
var scare_a_triggered := false
var scare_b_triggered := false
var nearby_interactions: Array[String] = []
var active_interaction_id := ""
var resonance_markers: Array[Node3D] = []
var metro_fracture_roots: Array[Node] = []
var city_fracture_roots: Array[Node] = []
var route_roots: Array[Node] = []
var city_progress_roots: Array[Node] = []
var collision_layer_defaults: Dictionary = {}
var collision_mask_defaults: Dictionary = {}
var shape_disabled_defaults: Dictionary = {}
var gate_left_closed := Vector3.ZERO
var gate_right_closed := Vector3.ZERO
var safehouse_left_closed := Vector3.ZERO
var safehouse_right_closed := Vector3.ZERO
var city_bleed_visible := false
var city_bleed_timer := 0.0
var scare_timer := 0.0
var metro_echo_timer := 0.0
var base_forward := Vector3.FORWARD
var base_right := Vector3.RIGHT
var metro_echo_spot_a := Vector3.ZERO
var metro_echo_spot_b := Vector3.ZERO
var portal_ring_material: StandardMaterial3D
var portal_core_material: StandardMaterial3D
var anchor_material: StandardMaterial3D
var city_rift_material: StandardMaterial3D
var signal_core_material: StandardMaterial3D
var matrix_core_material: StandardMaterial3D
var safehouse_terminal_material: StandardMaterial3D
var safehouse_map_material: StandardMaterial3D
var relay_a_material: StandardMaterial3D
var relay_b_material: StandardMaterial3D
var city_lights: Array[OmniLight3D] = []

func _ready() -> void:
	resonance_markers = [marker_a, marker_b, marker_c]
	gate_left_closed = gate_left.position
	gate_right_closed = gate_right.position
	safehouse_left_closed = safehouse_door_left.position
	safehouse_right_closed = safehouse_door_right.position
	portal_ring_material = _ensure_unique_material(portal_ring)
	portal_core_material = _ensure_unique_material(portal_core)
	anchor_material = _ensure_unique_material(anchor_core)
	city_rift_material = _ensure_unique_material(city_rift_sphere)
	signal_core_material = _ensure_unique_material(signal_box_core)
	matrix_core_material = _ensure_unique_material(matrix_core)
	safehouse_terminal_material = _ensure_unique_material(safehouse_terminal_core)
	safehouse_map_material = _ensure_unique_material(safehouse_map_core)
	relay_a_material = _ensure_unique_material(relay_a_core)
	relay_b_material = _ensure_unique_material(relay_b_core)
	city_lights = [street_light_a, street_light_b, street_light_c, billboard_light]

	_prepare_demo_scene()
	_register_quest_areas()
	_layout_world()
	_cache_fracture_roots()
	_apply_world_state(WORLD_VERIS)
	_set_stage(STAGE_SURVEY)
	_refresh_journal()
	_fade_in()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("journal"):
		journal_panel.visible = not journal_panel.visible

	if world_state == WORLD_VERIS and Input.is_action_just_pressed("focus"):
		_toggle_focus()

	if Input.is_action_just_pressed("interact"):
		_handle_interaction()

	if scare_timer > 0.0:
		scare_timer = max(scare_timer - delta, 0.0)
		if scare_timer == 0.0:
			city_figure.visible = false

	if metro_echo_timer > 0.0:
		metro_echo_timer = max(metro_echo_timer - delta, 0.0)
		if metro_echo_timer == 0.0:
			metro_echo_figure.visible = false
			metro_echo_light.light_energy = 0.0

	if city_bleed_timer > 0.0:
		city_bleed_timer = max(city_bleed_timer - delta, 0.0)
		if city_bleed_timer == 0.0:
			_set_city_bleed(false)

	_update_active_interaction()
	_update_prompt()
	_refresh_world_label()
	_pulse_world_objects()

func _prepare_demo_scene() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if is_instance_valid(player):
		player.set("is_player_in_control", true)
	if metro.has_node("AnimationPlayer"):
		metro.get_node("AnimationPlayer").queue_free()
	if metro.has_node("Control"):
		metro.get_node("Control").queue_free()
	if metro.has_node("fps_readout"):
		metro.get_node("fps_readout").queue_free()

func _register_quest_areas() -> void:
	_connect_area(poster_a_area, "poster_a")
	_connect_area(poster_b_area, "poster_b")
	_connect_area(portal_area, "portal")
	_connect_area(anchor_area, "anchor")
	_connect_area(exit_gate_area, "gate")
	_connect_area(city_entry_area, "city_entry")
	_connect_area(signal_box_area, "signal_box")
	_connect_area(scare_a_area, "scare_a")
	_connect_area(scare_b_area, "scare_b")
	_connect_area(city_goal_area, "city_goal")
	_connect_area(matrix_area, "matrix")
	_connect_area(metro_scare_a_area, "metro_scare_a")
	_connect_area(metro_scare_b_area, "metro_scare_b")
	_connect_area(relay_a_area, "relay_a")
	_connect_area(relay_b_area, "relay_b")
	_connect_area(safehouse_area, "safehouse")
	_connect_area(safehouse_log_area, "safehouse_log")
	_connect_area(safehouse_terminal_area, "safehouse_terminal")
	_connect_area(safehouse_map_area, "safehouse_map")

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

	var exit_forward := -metro_exit.global_transform.basis.z.normalized()
	city_zone.global_transform = Transform3D(metro_exit.global_transform.basis, metro_exit.global_position + exit_forward * 32.0)
	city_entry_area.global_position = city_zone.to_global(Vector3(0, 1.2, 3.0))
	signal_box_area.global_position = city_zone.to_global(Vector3(-4.9, 1.2, -10.5))
	scare_a_area.global_position = city_zone.to_global(Vector3(0, 1.2, -10.0))
	scare_b_area.global_position = city_zone.to_global(Vector3(0, 1.2, -22.0))
	city_goal_area.global_position = city_zone.to_global(Vector3(0, 1.2, -35.0))
	relay_a_area.global_position = city_zone.to_global(Vector3(-5.6, 1.2, -47.0))
	relay_b_area.global_position = city_zone.to_global(Vector3(4.8, 1.2, -58.0))
	safehouse_area.global_position = city_zone.to_global(Vector3(0, 1.2, -66.2))
	safehouse_log_area.global_position = city_zone.to_global(Vector3(-1.45, 1.12, -76.2))
	safehouse_terminal_area.global_position = city_zone.to_global(Vector3(1.1, 1.18, -76.0))
	safehouse_map_area.global_position = city_zone.to_global(Vector3(0, 2.15, -78.35))
	city_billboard.look_at(player_head, Vector3.UP, true)

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

	city_fracture_roots = [city_fracture_layer]
	route_roots = [metro_exit, city_zone]
	city_progress_roots = [courtyard_route]

	for root in metro_fracture_roots:
		_cache_collision_state(root)
	for root in city_fracture_roots:
		_cache_collision_state(root)
	for root in route_roots:
		_cache_collision_state(root)
	for root in city_progress_roots:
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
	_set_city_bleed(in_fracture)
	resonance_trail.visible = in_fracture
	anchor_shard.visible = in_fracture
	anchor_area.monitoring = in_fracture

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
			env_normal.volumetric_fog_density = 0.028 if city_entered else 0.02

	_sync_route_visibility()

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

func _set_city_bleed(visible_state: bool) -> void:
	city_bleed_visible = visible_state
	for root in city_fracture_roots:
		_apply_node_state(root, visible_state, false)

func _set_stage(next_stage: String) -> void:
	stage = next_stage
	match stage:
		STAGE_SURVEY:
			title_label.text = "EIDARA / Platform Seven"
			meta_label.text = "Бесшовный срез: метро, seam и первый городской выход"
			objective_label.text = "Осмотри Platform Seven в состоянии Veris. Проверь рекламную панель игры, доску с книгами и маршрутную матрицу."
			_set_status("Платформа должна чувствоваться нормальной, но уже тревожной.")
		STAGE_PORTAL:
			objective_label.text = "Три сигнала совпали. Удержи Focus у seam и пересекни портал в глубине платформы."
			_set_status("Portal стабилизировался: теперь это не абстракция, а читаемая аномалия.")
		STAGE_FRACTURE:
			objective_label.text = "Ты в Fracture. Следуй по резонансным маркерам и зафиксируй anchor в служебном проходе."
			_set_status("Разлом не заменил станцию, а вывернул ее наружу.")
		STAGE_RETURN:
			objective_label.text = "Anchor собран. Верни частоту обратно через seam."
			_set_status("Теперь у выхода есть причина открыться в обычном мире.")
		STAGE_EXIT:
			objective_label.text = "Открой сервисный шлюз и выйди из метро в город."
			_set_status("Станция больше не уровень. Она только первый узел большого маршрута.")
		STAGE_CITY:
			objective_label.text = "Во внешнем квартале найди распределительный шкаф и верни свет уличному контуру."
			_set_status("Город в Veris не развален до конца, но уже потерял ритм.")
		STAGE_CITY_RIFT:
			objective_label.text = "Свет вернулся частично. Под Focus дойди до уличного разрыва и считай его."
			_set_status("Теперь город начал отвечать на твое вмешательство.")
		STAGE_COURTYARD:
			objective_label.text = "Разрыв открыл внутренний двор. Синхронизируй два резонансных реле, чтобы добраться до убежища."
			_set_status("Город начал раскрываться не только вперед, но и вглубь своих служебных узлов.")
		STAGE_SAFEHOUSE:
			objective_label.text = "Оба реле собраны. Открой дверь убежища во внутреннем дворе."
			_set_status("Теперь маршрут держится на двух сигналах: физическом и эхо-следе.")
		STAGE_SAFEHOUSE_LOG:
			objective_label.text = "Дверь открыта. Найди полевой журнал дежурного внутри Shelter Node 7."
			_set_status("Убежище не пустое: кто-то оставил здесь маршрут и аварийные инструкции.")
		STAGE_SAFEHOUSE_POWER:
			objective_label.text = "Журнал указывает на резервный терминал. Подними питание внутри убежища."
			_set_status("Комната начинает работать как диспетчерский узел, а не как глухая концовка.")
		STAGE_SAFEHOUSE_MAP:
			objective_label.text = "Терминал поднял настенную карту района. Под Focus считай схему следующего сектора."
			_set_status("Карта держится между Veris и Fracture. Ее нужно читать на настроенной частоте.")
		STAGE_COMPLETE:
			objective_label.text = "Карта района считана. Shelter Node 7 закреплен как опорная точка следующего сектора."
			_set_status("Следующий шаг: вести маршрут в жилой сектор и разорванные сервисные тоннели.")
	_sync_route_visibility()
	_refresh_journal()

func _sync_route_visibility() -> void:
	var exit_visible := stage in [STAGE_EXIT, STAGE_CITY, STAGE_CITY_RIFT, STAGE_COURTYARD, STAGE_SAFEHOUSE, STAGE_SAFEHOUSE_LOG, STAGE_SAFEHOUSE_POWER, STAGE_SAFEHOUSE_MAP, STAGE_COMPLETE] or exit_gate_open or city_entered
	var city_visible := stage in [STAGE_CITY, STAGE_CITY_RIFT, STAGE_COURTYARD, STAGE_SAFEHOUSE, STAGE_SAFEHOUSE_LOG, STAGE_SAFEHOUSE_POWER, STAGE_SAFEHOUSE_MAP, STAGE_COMPLETE] or city_entered or exit_gate_open
	var courtyard_visible := stage in [STAGE_COURTYARD, STAGE_SAFEHOUSE, STAGE_SAFEHOUSE_LOG, STAGE_SAFEHOUSE_POWER, STAGE_SAFEHOUSE_MAP, STAGE_COMPLETE] or courtyard_route_open or safehouse_open

	_apply_node_state(metro_exit, exit_visible, exit_visible)
	_apply_node_state(city_zone, city_visible, city_visible)
	_apply_node_state(courtyard_route, courtyard_visible, courtyard_visible)

	if exit_visible and exit_gate_open:
		gate_blocker_shape.disabled = true
	if courtyard_visible and safehouse_open:
		safehouse_blocker_shape.disabled = true

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
			_on_portal_interacted()
		"anchor":
			_on_anchor_interacted()
		"gate":
			_on_gate_interacted()
		"signal_box":
			_on_signal_box_interacted()
		"city_goal":
			_on_city_goal_interacted()
		"relay_a":
			_on_relay_a_interacted()
		"relay_b":
			_on_relay_b_interacted()
		"safehouse":
			_on_safehouse_interacted()
		"safehouse_log":
			_on_safehouse_log_interacted()
		"safehouse_terminal":
			_on_safehouse_terminal_interacted()
		"safehouse_map":
			_on_safehouse_map_interacted()
		_:
			pass

func _on_poster_a_interacted() -> void:
	if poster_seen:
		_set_status("Панель уже прочитана: Platform Seven работает как витрина EIDARA.")
		return

	poster_seen = true
	_set_status("Рекламная панель продает не товар, а место: EIDARA будто уже встроена в память станции.")
	_check_portal_unlock()

func _on_poster_b_interacted() -> void:
	if book_board_seen:
		_set_status("Доска уже изучена: ECHO и FRACTURE зашиты в мир как следы прошлых циклов.")
		return

	book_board_seen = true
	_set_status("Книжная доска связывает ECHO и FRACTURE с маршрутом станции. Это уже не декор, а карта.")
	_check_portal_unlock()

func _on_matrix_interacted() -> void:
	if route_matrix_seen:
		_set_status("Маршрутная матрица уже считана. Она держит Platform Seven как узел, а не как станцию.")
		return

	route_matrix_seen = true
	_set_status("Маршрутная матрица выдает три точки сразу: Platform Seven, city fault и shelter node. Станция уже знает больше, чем должна.")
	_check_portal_unlock()

func _check_portal_unlock() -> void:
	if poster_seen and book_board_seen and route_matrix_seen and not portal_stable:
		portal_stable = true
		_set_stage(STAGE_PORTAL)
	_refresh_journal()

func _on_portal_interacted() -> void:
	if world_state == WORLD_VERIS:
		if stage != STAGE_PORTAL:
			_set_status("Seam еще не готов. Сначала нужно собрать все сигналы на платформе.")
			return
		if not focus_mode:
			_set_status("Portal держится только под Focus. Сначала зафиксируй трещину.")
			return

		focus_mode = false
		_apply_world_state(WORLD_FRACTURE)
		_set_stage(STAGE_FRACTURE)
		_play_transition(Color(0.262745, 0.196078, 0.392157, 0.82))
		return

	if stage != STAGE_RETURN:
		_set_status("Возвращаться рано. Сначала закрепи anchor в разломе.")
		return

	_apply_world_state(WORLD_VERIS)
	_set_stage(STAGE_EXIT)
	_play_transition(Color(0.121569, 0.145098, 0.215686, 0.68))

func _on_anchor_interacted() -> void:
	if world_state != WORLD_FRACTURE or stage != STAGE_FRACTURE:
		return
	if fracture_anchor_secured:
		_set_status("Anchor уже закреплен. Возвращайся к seam.")
		return

	fracture_anchor_secured = true
	_set_stage(STAGE_RETURN)
	_set_status("Частота anchor считана. Теперь ее можно вынести обратно в Veris.")
	_refresh_journal()

func _on_gate_interacted() -> void:
	if stage != STAGE_EXIT or world_state != WORLD_VERIS:
		return
	if exit_gate_open:
		_set_status("Шлюз уже открыт. Иди дальше в город.")
		return
	if not fracture_anchor_secured:
		_set_status("Шлюзу нечем открыться. Нужен anchor из разлома.")
		return

	exit_gate_open = true
	gate_blocker_shape.disabled = true
	var tween := create_tween()
	tween.tween_property(gate_left, "position:x", gate_left_closed.x - 1.7, 0.65)
	tween.parallel().tween_property(gate_right, "position:x", gate_right_closed.x + 1.7, 0.65)
	_sync_route_visibility()
	_set_status("Сервисный шлюз разблокирован. Выход в город открыт.")
	_refresh_journal()

func _on_city_goal_interacted() -> void:
	if stage != STAGE_CITY_RIFT:
		return
	if city_goal_documented:
		_set_status("Уличный разрыв уже задокументирован.")
		return
	if not focus_mode:
		_set_status("Разрыв читается только под Focus. Зафиксируй аномалию, потом взаимодействуй.")
		return

	city_goal_documented = true
	courtyard_route_open = true
	_set_stage(STAGE_COURTYARD)
	city_bleed_timer = 1.2
	_set_city_bleed(true)
	city_figure.visible = true
	city_figure.position = Vector3(0.0, 2.1, -49.0)
	scare_timer = 1.0
	_sync_route_visibility()
	_set_status("Разрыв вскрыл внутренний двор. Дальше маршрут держат два реле и закрытая дверь убежища.")
	_play_scare_overlay()
	_refresh_journal()
	_play_transition(Color(0.243137, 0.219608, 0.384314, 0.72))

func _on_signal_box_interacted() -> void:
	if stage != STAGE_CITY or world_state != WORLD_VERIS:
		return
	if city_signal_restored:
		_set_status("Контур уже запитан. Ищи разрыв дальше по улице.")
		return

	city_signal_restored = true
	_set_stage(STAGE_CITY_RIFT)
	city_bleed_timer = 0.8
	_set_city_bleed(true)
	city_figure.visible = true
	city_figure.position = Vector3(5.8, 2.0, -18.0)
	scare_timer = 0.8
	_set_status("Сигнал вернулся рывком. Квартал ожил, но вместе со светом открылся и новый сдвиг.")
	_play_scare_overlay()
	_refresh_journal()

func _on_relay_a_interacted() -> void:
	if world_state != WORLD_VERIS or not (stage in [STAGE_COURTYARD, STAGE_SAFEHOUSE]):
		return
	if relay_a_aligned:
		_set_status("Реле A уже синхронизировано. Оно держит физический контур двора.")
		return

	relay_a_aligned = true
	_set_status("Реле A подняло физическую линию двора. Теперь нужен второй, эхо-контур.")
	_check_safehouse_unlock()

func _on_relay_b_interacted() -> void:
	if world_state != WORLD_VERIS or not (stage in [STAGE_COURTYARD, STAGE_SAFEHOUSE]):
		return
	if relay_b_aligned:
		_set_status("Реле B уже синхронизировано. Его след больше не срывается.")
		return
	if not focus_mode:
		_set_status("Реле B пустое в обычном взгляде. Удержи Focus, чтобы увидеть эхо-контур.")
		return

	relay_b_aligned = true
	city_bleed_timer = 0.8
	_set_city_bleed(true)
	_set_status("Реле B удержалось только под Focus. Теперь убежище получает оба сигнала.")
	_check_safehouse_unlock()

func _check_safehouse_unlock() -> void:
	if relay_a_aligned and relay_b_aligned and stage == STAGE_COURTYARD:
		_set_stage(STAGE_SAFEHOUSE)
		_set_status("Оба реле синхронизированы. Дверь убежища должна принять маршрут.")
	_refresh_journal()

func _on_safehouse_interacted() -> void:
	if world_state != WORLD_VERIS or stage != STAGE_SAFEHOUSE:
		return
	if safehouse_open:
		_set_status("Убежище уже открыто. Это новая точка опоры для следующего куска города.")
		return
	if not relay_a_aligned or not relay_b_aligned:
		_set_status("Дверь не примет неполный сигнал. Сначала собери оба реле.")
		return

	safehouse_open = true
	safehouse_blocker_shape.disabled = true
	var tween := create_tween()
	tween.tween_property(safehouse_door_left, "position:x", safehouse_left_closed.x - 1.3, 0.6)
	tween.parallel().tween_property(safehouse_door_right, "position:x", safehouse_right_closed.x + 1.3, 0.6)
	city_bleed_timer = 0.55
	_set_city_bleed(true)
	_set_stage(STAGE_SAFEHOUSE_LOG)
	_set_status("Дверь приняла оба реле. Внутри должен быть не трофей, а рабочий след следующего маршрута.")
	_refresh_journal()

func _on_safehouse_log_interacted() -> void:
	if world_state != WORLD_VERIS or stage != STAGE_SAFEHOUSE_LOG or not safehouse_open:
		return
	if safehouse_log_found:
		_set_status("Полевой журнал уже прочитан. В нем отмечен резервный терминал узла.")
		return

	safehouse_log_found = true
	_set_stage(STAGE_SAFEHOUSE_POWER)
	_set_status("Журнал описывает аварийный запуск узла: подними резервный терминал и считай карту сектора.")
	_refresh_journal()

func _on_safehouse_terminal_interacted() -> void:
	if world_state != WORLD_VERIS or stage != STAGE_SAFEHOUSE_POWER or not safehouse_open:
		return
	if safehouse_terminal_online:
		_set_status("Терминал уже поднят. Теперь карта должна проступить на стене.")
		return

	safehouse_terminal_online = true
	city_bleed_timer = 0.9
	_set_city_bleed(true)
	_play_transition(Color(0.941176, 0.560784, 0.223529, 0.88))
	_set_stage(STAGE_SAFEHOUSE_MAP)
	_set_status("Резервное питание поднято. Настенная схема оживает, но держится только на границе двух состояний.")
	_refresh_journal()

func _on_safehouse_map_interacted() -> void:
	if world_state != WORLD_VERIS or stage != STAGE_SAFEHOUSE_MAP or not safehouse_open:
		return
	if district_map_read:
		_set_status("Карта уже считана. Следующий маршрут уходит в жилой сектор и сервисные шахты.")
		return
	if not safehouse_terminal_online:
		_set_status("Сначала подними терминал. Без питания карта не соберется.")
		return
	if not focus_mode:
		_set_status("Карта мертва в прямом взгляде. Удержи Focus, чтобы проявить маршрут следующего сектора.")
		return

	district_map_read = true
	_play_transition(Color(0.576471, 0.792157, 1.0, 0.92))
	_set_stage(STAGE_COMPLETE)
	_set_status("Карта считана: следующий выход ведет в жилой сектор и разорванные сервисные тоннели.")
	_refresh_journal()

func _on_area_body_entered(body: Node, area_id: String) -> void:
	if body != player:
		return

	match area_id:
		"city_entry":
			if exit_gate_open and not city_entered:
				city_entered = true
				_set_stage(STAGE_CITY)
				_apply_world_state(world_state)
				_refresh_journal()
		"metro_scare_a":
			if world_state == WORLD_VERIS and stage == STAGE_SURVEY and not metro_scare_a_triggered:
				metro_scare_a_triggered = true
				_trigger_metro_scare("train_echo")
		"metro_scare_b":
			if world_state == WORLD_VERIS and stage in [STAGE_SURVEY, STAGE_PORTAL] and not metro_scare_b_triggered:
				metro_scare_b_triggered = true
				_trigger_metro_scare("tunnel_witness")
		"scare_a":
			if city_entered and not scare_a_triggered:
				scare_a_triggered = true
				_trigger_scare("roofline")
		"scare_b":
			if city_entered and not scare_b_triggered:
				scare_b_triggered = true
				_trigger_scare("street_bleed")
		_:
			if not nearby_interactions.has(area_id):
				nearby_interactions.append(area_id)

func _on_area_body_exited(body: Node, area_id: String) -> void:
	if body != player:
		return
	nearby_interactions.erase(area_id)

func _trigger_scare(scare_id: String) -> void:
	match scare_id:
		"roofline":
			if city_figure.visible:
				return
			city_figure.visible = true
			city_figure.position = Vector3(9.0, 2.3, -17.0)
			scare_timer = 0.85
			_set_status("Над улицей что-то есть, но взгляд не успевает его удержать.")
		"street_bleed":
			city_figure.visible = true
			city_figure.position = Vector3(-6.5, 1.8, -27.0)
			scare_timer = 1.05
			city_bleed_timer = 1.2
			_set_city_bleed(true)
			_set_status("Город на секунду показывает Fracture прямо поверх Veris.")
		_:
			return

	_play_scare_overlay()

func _trigger_metro_scare(scare_id: String) -> void:
	match scare_id:
		"train_echo":
			metro_echo_figure.visible = true
			metro_echo_figure.global_position = metro_echo_spot_a
			metro_echo_light.light_energy = 0.85
			metro_echo_timer = 0.75
			_set_status("В вагонах кто-то есть, но платформа не успевает закрепить его силуэт.")
		"tunnel_witness":
			metro_echo_figure.visible = true
			metro_echo_figure.global_position = metro_echo_spot_b
			metro_echo_light.light_energy = 1.1
			metro_echo_timer = 0.95
			_set_status("Тоннель показывает наблюдателя раньше, чем seam успевает оформиться.")
		_:
			return

	_play_scare_overlay()

func _update_active_interaction() -> void:
	var priorities := {
		"safehouse_map": 104,
		"safehouse_terminal": 103,
		"safehouse_log": 102,
		"city_goal": 100,
		"safehouse": 99,
		"relay_b": 98,
		"relay_a": 97,
		"signal_box": 95,
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
		"poster_a":
			return stage == STAGE_SURVEY
		"poster_b":
			return stage == STAGE_SURVEY
		"matrix":
			return stage == STAGE_SURVEY
		"portal":
			return (world_state == WORLD_VERIS and stage == STAGE_PORTAL) or (world_state == WORLD_FRACTURE and stage == STAGE_RETURN)
		"anchor":
			return world_state == WORLD_FRACTURE and stage == STAGE_FRACTURE
		"gate":
			return stage == STAGE_EXIT and world_state == WORLD_VERIS
		"signal_box":
			return stage == STAGE_CITY and world_state == WORLD_VERIS
		"city_goal":
			return stage == STAGE_CITY_RIFT and world_state == WORLD_VERIS
		"relay_a":
			return stage in [STAGE_COURTYARD, STAGE_SAFEHOUSE] and world_state == WORLD_VERIS
		"relay_b":
			return stage in [STAGE_COURTYARD, STAGE_SAFEHOUSE] and world_state == WORLD_VERIS
		"safehouse":
			return stage == STAGE_SAFEHOUSE and world_state == WORLD_VERIS
		"safehouse_log":
			return stage == STAGE_SAFEHOUSE_LOG and world_state == WORLD_VERIS and safehouse_open
		"safehouse_terminal":
			return stage == STAGE_SAFEHOUSE_POWER and world_state == WORLD_VERIS and safehouse_open
		"safehouse_map":
			return stage == STAGE_SAFEHOUSE_MAP and world_state == WORLD_VERIS and safehouse_open
		_:
			return false

func _update_prompt() -> void:
	if stage == STAGE_COMPLETE:
		prompt_label.text = "Tab — журнал   |   Q — Focus"
		return

	match active_interaction_id:
		"poster_a":
			prompt_label.text = "E — изучить рекламную панель   |   Tab — журнал"
			return
		"poster_b":
			prompt_label.text = "E — изучить книжную доску   |   Tab — журнал"
			return
		"matrix":
			prompt_label.text = "E — считать маршрутную матрицу   |   Tab — журнал"
			return
		"portal":
			if world_state == WORLD_VERIS and not focus_mode:
				prompt_label.text = "Q — Focus, чтобы удержать seam   |   Tab — журнал"
			else:
				prompt_label.text = "E — пересечь seam   |   Tab — журнал"
			return
		"anchor":
			prompt_label.text = "E — закрепить anchor   |   Tab — журнал"
			return
		"gate":
			prompt_label.text = "E — открыть сервисный шлюз   |   Tab — журнал"
			return
		"signal_box":
			prompt_label.text = "E — восстановить уличный сигнал   |   Tab — журнал"
			return
		"city_goal":
			if focus_mode:
				prompt_label.text = "E — считать уличный разрыв   |   Tab — журнал"
			else:
				prompt_label.text = "Q — Focus, чтобы прочитать аномалию   |   Tab — журнал"
			return
		"relay_a":
			prompt_label.text = "E — синхронизировать реле A   |   Tab — журнал"
			return
		"relay_b":
			if focus_mode:
				prompt_label.text = "E — синхронизировать реле B   |   Tab — журнал"
			else:
				prompt_label.text = "Q — Focus, чтобы увидеть реле B   |   Tab — журнал"
			return
		"safehouse":
			prompt_label.text = "E — открыть убежище   |   Tab — журнал"
			return
		"safehouse_log":
			prompt_label.text = "E — прочитать полевой журнал   |   Tab — журнал"
			return
		"safehouse_terminal":
			prompt_label.text = "E — поднять резервный терминал   |   Tab — журнал"
			return
		"safehouse_map":
			if focus_mode:
				prompt_label.text = "E — считать настенную карту   |   Tab — журнал"
			else:
				prompt_label.text = "Q — Focus, чтобы проявить карту   |   Tab — журнал"
			return
		_:
			pass

	if world_state == WORLD_VERIS:
		prompt_label.text = "Q — Focus   |   Tab — журнал"
	else:
		prompt_label.text = "Fracture активен: следуй за резонансом   |   Tab — журнал"

func _refresh_world_label() -> void:
	var world_text := "Veris" if world_state == WORLD_VERIS else "Fracture"
	world_label.text = "Состояние мира: %s" % world_text

func _refresh_journal() -> void:
	var lines: Array[String] = []
	lines.append("EIDARA / Seamless World Slice")
	lines.append("")
	lines.append("Концепция")
	lines.append("Игра больше не делится на главы-сцены. Platform Seven, seam и первый городской квартал собраны как один маршрут.")
	lines.append("Veris: мир собран и функционален, но тревожен.")
	lines.append("Fracture: та же геометрия после разрыва памяти, с другими объектами, светом и логикой прохода.")
	lines.append("")
	lines.append("Текущая цель")
	lines.append(objective_label.text)
	lines.append("")
	lines.append("Состояние расследования")
	lines.append("Рекламная панель EIDARA: %s" % ("прочитана" if poster_seen else "не изучена"))
	lines.append("Книжная доска ECHO / FRACTURE: %s" % ("прочитана" if book_board_seen else "не изучена"))
	lines.append("Маршрутная матрица Platform Seven: %s" % ("прочитана" if route_matrix_seen else "не изучена"))
	lines.append("Portal стабилен: %s" % ("да" if portal_stable else "нет"))
	lines.append("Anchor вынесен из Fracture: %s" % ("да" if fracture_anchor_secured else "нет"))
	lines.append("Выход в город открыт: %s" % ("да" if exit_gate_open else "нет"))
	lines.append("Город достигнут: %s" % ("да" if city_entered else "нет"))
	lines.append("Уличный сигнал восстановлен: %s" % ("да" if city_signal_restored else "нет"))
	lines.append("Уличный разрыв считан: %s" % ("да" if city_goal_documented else "нет"))
	lines.append("Внутренний двор вскрыт: %s" % ("да" if courtyard_route_open else "нет"))
	lines.append("Реле A синхронизировано: %s" % ("да" if relay_a_aligned else "нет"))
	lines.append("Реле B синхронизировано: %s" % ("да" if relay_b_aligned else "нет"))
	lines.append("Убежище открыто: %s" % ("да" if safehouse_open else "нет"))
	lines.append("Полевой журнал убежища: %s" % ("прочитан" if safehouse_log_found else "не найден"))
	lines.append("Терминал убежища: %s" % ("поднят" if safehouse_terminal_online else "спит"))
	lines.append("Настенная карта района: %s" % ("считана" if district_map_read else "не прочитана"))
	lines.append("")
	lines.append("Правило слоя")
	lines.append("Fracture-объекты теперь не только скрываются, но и отключают свои коллизии, когда мир в состоянии Veris.")
	journal_label.text = "\n".join(lines)

func _pulse_world_objects() -> void:
	var time_value := Time.get_ticks_msec() / 1000.0
	var portal_pulse := 0.55 + 0.45 * sin(time_value * 2.1)
	var portal_visible := world_state == WORLD_FRACTURE or focus_mode or portal_stable
	portal_rig.visible = portal_visible
	portal_light.light_energy = (1.4 + portal_pulse * 3.0) if portal_visible else 0.0

	if portal_ring_material != null:
		portal_ring_material.emission_energy_multiplier = 1.8 + portal_pulse * (2.8 if portal_stable else 1.2)
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

	var city_pulse := 0.45 + 0.55 * sin(time_value * 1.9)
	if city_rift_material != null:
		city_rift_material.emission_energy_multiplier = 1.8 + city_pulse * 2.8
	city_rift_light.light_energy = (1.0 + city_pulse * 2.4) if city_bleed_visible or world_state == WORLD_FRACTURE else 0.0

	if signal_core_material != null:
		if city_signal_restored:
			signal_core_material.emission_energy_multiplier = 1.8 + city_pulse * 1.2
		else:
			signal_core_material.emission_energy_multiplier = 0.3 + max(sin(time_value * 4.0), 0.0) * 0.25

	if matrix_core_material != null:
		if route_matrix_seen:
			matrix_core_material.emission_energy_multiplier = 1.2 + city_pulse * 0.85
			matrix_light.light_energy = 0.8 + city_pulse * 0.45
		else:
			matrix_core_material.emission_energy_multiplier = 0.25 + max(sin(time_value * 2.7), 0.0) * 0.18
			matrix_light.light_energy = 0.18 + max(sin(time_value * 2.2), 0.0) * 0.12

	if relay_a_material != null:
		if relay_a_aligned:
			relay_a_material.emission_energy_multiplier = 1.5 + city_pulse * 1.1
		else:
			relay_a_material.emission_energy_multiplier = 0.22 + max(sin(time_value * 3.1), 0.0) * 0.22

	if relay_b_material != null:
		if relay_b_aligned:
			relay_b_material.emission_energy_multiplier = 1.6 + city_pulse * 1.2
		elif focus_mode:
			relay_b_material.emission_energy_multiplier = 0.55 + max(sin(time_value * 4.4), 0.0) * 0.5
		else:
			relay_b_material.emission_energy_multiplier = 0.06

	if safehouse_terminal_material != null:
		if safehouse_terminal_online:
			safehouse_terminal_material.emission_energy_multiplier = 1.35 + city_pulse * 1.05
			safehouse_terminal_light.light_energy = 0.9 + city_pulse * 0.45
		elif stage == STAGE_SAFEHOUSE_POWER:
			safehouse_terminal_material.emission_energy_multiplier = 0.22 + max(sin(time_value * 3.4), 0.0) * 0.26
			safehouse_terminal_light.light_energy = 0.12 + max(sin(time_value * 2.7), 0.0) * 0.18
		else:
			safehouse_terminal_material.emission_energy_multiplier = 0.05
			safehouse_terminal_light.light_energy = 0.0

	if safehouse_map_material != null:
		if district_map_read:
			safehouse_map_material.emission_energy_multiplier = 1.45 + city_pulse * 1.15
			safehouse_map_light.light_energy = 1.0 + city_pulse * 0.5
		elif stage == STAGE_SAFEHOUSE_MAP:
			if focus_mode:
				safehouse_map_material.emission_energy_multiplier = 1.05 + city_pulse * 1.05
				safehouse_map_light.light_energy = 0.82 + city_pulse * 0.4
			else:
				safehouse_map_material.emission_energy_multiplier = 0.18 + max(sin(time_value * 2.9), 0.0) * 0.2
				safehouse_map_light.light_energy = 0.08
		else:
			safehouse_map_material.emission_energy_multiplier = 0.04
			safehouse_map_light.light_energy = 0.0

	for index in city_lights.size():
		var light := city_lights[index]
		if not city_entered:
			light.light_energy = 0.0
		elif city_signal_restored:
			light.light_energy = 1.2 + 0.3 * sin(time_value * 1.3 + float(index))
		else:
			light.light_energy = 0.15 + max(sin(time_value * 3.0 + float(index) * 1.7), 0.0) * 0.25

	if safehouse_open:
		safehouse_light.light_energy = 1.3 + 0.25 * sin(time_value * 1.5)
	elif stage == STAGE_SAFEHOUSE:
		safehouse_light.light_energy = 0.42 + 0.1 * sin(time_value * 2.0)
	else:
		safehouse_light.light_energy = 0.0

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
