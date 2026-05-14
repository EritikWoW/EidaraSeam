extends Node3D

signal chapter_completed(chapter_id: String)
signal request_return_to_campaign()

const CampaignData := preload("res://scripts/campaign_data.gd")

const WORLD_VERIS := "veris"
const WORLD_FRACTURE := "fracture"

const PHASE_INTRO := "intro"
const PHASE_FOCUS := "focus"
const PHASE_FRACTURE := "fracture"
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
	"table",
	"garden_box",
	"potato_planter",
	"Plane_008"
]

@onready var player: CharacterBody3D = $Metro/fps_controller
@onready var subway_root: Node3D = $Metro/subway
@onready var world_env: WorldEnvironment = $Metro/WorldEnvironment
@onready var directional_light: DirectionalLight3D = $Metro/DirectionalLight3D
@onready var particles: GPUParticles3D = $Metro/GPUParticles3D
@onready var dirt_piles: Node3D = $Metro/dirt_piles
@onready var random_floor_junk: Node3D = $Metro/random_floor_junk
@onready var trash_cans: Node3D = $Metro/trash_cans
@onready var cork_boards: Node3D = $Metro/cork_boards
@onready var soft_bodies: Node3D = $Metro/soft_bodies
@onready var decals: Node3D = $Metro/decals
@onready var music: AudioStreamPlayer = $Metro/sounds/music
@onready var seam: Node3D = $ChapterObjects/Seam
@onready var seam_mesh: MeshInstance3D = $ChapterObjects/Seam/SeamMesh
@onready var seam_light: OmniLight3D = $ChapterObjects/Seam/SeamLight
@onready var seam_trigger: Area3D = $ChapterObjects/SeamTrigger
@onready var fracture_goal_trigger: Area3D = $ChapterObjects/FractureGoalTrigger
@onready var resonance_trail: Node3D = $ChapterObjects/ResonanceTrail
@onready var marker_a: Node3D = $ChapterObjects/ResonanceTrail/MarkerA
@onready var marker_b: Node3D = $ChapterObjects/ResonanceTrail/MarkerB
@onready var marker_c: Node3D = $ChapterObjects/ResonanceTrail/MarkerC
@onready var title_card: Control = $HUD/TitleCard
@onready var chapter_title: Label = $HUD/TitleCard/MarginContainer/VBoxContainer/ChapterTitle
@onready var chapter_meta: Label = $HUD/TitleCard/MarginContainer/VBoxContainer/ChapterMeta
@onready var world_label: Label = $HUD/TitleCard/MarginContainer/VBoxContainer/WorldLabel
@onready var objective_label: Label = $HUD/ObjectivePanel/MarginContainer/ObjectiveLabel
@onready var prompt_label: Label = $HUD/PromptPanel/MarginContainer/PromptLabel
@onready var status_label: Label = $HUD/StatusLabel
@onready var journal_panel: Control = $HUD/JournalPanel
@onready var journal_label: RichTextLabel = $HUD/JournalPanel/MarginContainer/JournalLabel
@onready var completion_panel: Control = $HUD/CompletionPanel
@onready var return_button: Button = $HUD/CompletionPanel/MarginContainer/VBoxContainer/ReturnButton
@onready var transition_rect: ColorRect = $HUD/TransitionRect

var chapter_data: Dictionary = CampaignData.get_chapter("echo_platform_seven")
var world_state := WORLD_VERIS
var phase := PHASE_INTRO
var focus_mode := false
var has_seen_focus := false
var player_inside_seam := false
var fracture_entered := false
var chapter_finished := false
var seam_material: StandardMaterial3D
var resonance_markers: Array[Node3D] = []
var base_forward := Vector3.FORWARD
var base_right := Vector3.RIGHT

func _ready() -> void:
	seam_material = seam_mesh.material_override as StandardMaterial3D
	resonance_markers = [marker_a, marker_b, marker_c]
	seam_trigger.body_entered.connect(_on_seam_trigger_body_entered)
	seam_trigger.body_exited.connect(_on_seam_trigger_body_exited)
	fracture_goal_trigger.body_entered.connect(_on_fracture_goal_trigger_body_entered)
	return_button.pressed.connect(_on_return_button_pressed)
	transition_rect.modulate.a = 0.0
	_position_story_objects()
	_sync_chapter_copy()
	_apply_world_state(WORLD_VERIS)
	_set_phase(PHASE_INTRO)
	_refresh_journal()
	_fade_title_card()

func start_chapter(data: Dictionary) -> void:
	if not data.is_empty():
		chapter_data = data.duplicate(true)
	_sync_chapter_copy()
	_refresh_journal()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("journal"):
		journal_panel.visible = not journal_panel.visible

	if world_state == WORLD_VERIS and Input.is_action_just_pressed("focus"):
		_toggle_focus()

	if Input.is_action_just_pressed("interact"):
		_try_cross_seam()

	if chapter_finished and Input.is_action_just_pressed("ui_accept"):
		_on_return_button_pressed()

	_update_prompt()
	_pulse_story_objects()

func _position_story_objects() -> void:
	base_forward = -player.global_transform.basis.z.normalized()
	base_right = player.global_transform.basis.x.normalized()

	var player_head := player.global_position + Vector3.UP * 1.2
	var seam_position := player.global_position + base_forward * 14.0 + base_right * 1.4 + Vector3.UP * 1.15

	seam.global_position = seam_position
	seam.look_at(player_head, Vector3.UP, true)
	seam_trigger.global_position = seam_position

	marker_a.global_position = player.global_position + base_forward * 23.0 + base_right * 1.6 + Vector3.UP * 1.0
	marker_b.global_position = player.global_position + base_forward * 33.0 + base_right * -1.4 + Vector3.UP * 1.0
	marker_c.global_position = player.global_position + base_forward * 44.0 + base_right * 1.2 + Vector3.UP * 1.0
	fracture_goal_trigger.global_position = player.global_position + base_forward * 54.0 + Vector3.UP * 1.0

func _sync_chapter_copy() -> void:
	chapter_title.text = str(chapter_data.get("title", "The Subway's Hum"))
	chapter_meta.text = "%s / %s" % [str(chapter_data.get("book", "ECHO")), str(chapter_data.get("chapter_label", "Book I / Chapter 1"))]
	_refresh_world_label()

func _refresh_world_label() -> void:
	var world_name := "Veris" if world_state == WORLD_VERIS else "Fracture"
	world_label.text = "Состояние мира: %s" % world_name

func _toggle_focus() -> void:
	focus_mode = not focus_mode
	seam.visible = focus_mode or fracture_entered
	_apply_focus_visual()
	_refresh_journal()

	if focus_mode and not has_seen_focus:
		has_seen_focus = true
		_set_phase(PHASE_FOCUS)
		_set_status("Фокус раскрывает не магию, а скрытую геометрию обычного мира.")

func _try_cross_seam() -> void:
	if chapter_finished:
		return
	if not player_inside_seam:
		return
	if fracture_entered:
		return
	if not focus_mode:
		_set_status("Шов не держится без Focus. Сначала нужно увидеть трещину.")
		return

	fracture_entered = true
	focus_mode = false
	_apply_world_state(WORLD_FRACTURE)
	_play_fracture_transition()
	_set_phase(PHASE_FRACTURE)
	_set_status("Обычный Верис остался позади. Теперь станция показывает свою рану.")

func _apply_world_state(next_state: String) -> void:
	world_state = next_state
	var in_fracture := world_state == WORLD_FRACTURE

	seam.visible = focus_mode or in_fracture
	fracture_goal_trigger.monitoring = in_fracture
	_set_tree_visible(dirt_piles, in_fracture)
	_set_tree_visible(random_floor_junk, in_fracture)
	_set_tree_visible(soft_bodies, in_fracture)
	_set_selected_decals_visible(in_fracture)
	_set_subway_children_visible(FRACTURE_SUBWAY_PREFIXES, in_fracture)
	_set_resonance_visible(in_fracture)
	_set_fracture_trash_state(in_fracture)
	_apply_focus_visual()
	_apply_environment_state(in_fracture)
	_refresh_world_label()
	_refresh_journal()

func _apply_environment_state(in_fracture: bool) -> void:
	var env := world_env.environment
	if env != null:
		env.adjustment_enabled = true
		if in_fracture:
			env.adjustment_brightness = 0.62
			env.adjustment_contrast = 1.28
			env.adjustment_saturation = 0.48
		elif focus_mode:
			env.adjustment_brightness = 0.82
			env.adjustment_contrast = 1.18
			env.adjustment_saturation = 0.55
		else:
			env.adjustment_brightness = 1.08
			env.adjustment_contrast = 0.98
			env.adjustment_saturation = 1.02

	if in_fracture:
		directional_light.light_color = Color(0.713726, 0.658824, 0.980392, 1)
		directional_light.light_energy = 0.78
		directional_light.light_indirect_energy = 9.0
		particles.visible = true
		particles.emitting = true
		music.volume_db = -16.0
	else:
		directional_light.light_color = Color(1, 0.980392, 0.921569, 1)
		directional_light.light_energy = 1.12
		directional_light.light_indirect_energy = 14.0
		particles.visible = false
		particles.emitting = false
		music.volume_db = -24.0

func _apply_focus_visual() -> void:
	var env := world_env.environment
	if env == null:
		return
	if world_state == WORLD_FRACTURE:
		return

	if focus_mode:
		env.adjustment_brightness = 0.82
		env.adjustment_contrast = 1.18
		env.adjustment_saturation = 0.55
	else:
		env.adjustment_brightness = 1.08
		env.adjustment_contrast = 0.98
		env.adjustment_saturation = 1.02

func _set_phase(next_phase: String) -> void:
	phase = next_phase
	match phase:
		PHASE_INTRO:
			objective_label.text = "Осмотрись в обычном Верисе. Это еще не разлом: станция должна чувствоваться почти нормальной."
		PHASE_FOCUS:
			objective_label.text = "Найди seam в привычном мире. Подойди к нему и нажми E, чтобы пересечь границу."
		PHASE_FRACTURE:
			objective_label.text = "Ты в Fracture-состоянии станции. Следуй за резонансными маркерами вглубь платформы."
		PHASE_COMPLETE:
			objective_label.text = "Глава завершена. Возвращайся в кампанию и двигайся к следующим локациям."
	_refresh_journal()

func _update_prompt() -> void:
	if chapter_finished:
		prompt_label.text = "Enter — в кампанию   |   Tab — журнал"
		return

	if world_state == WORLD_VERIS:
		if player_inside_seam and focus_mode:
			prompt_label.text = "E — пересечь seam   |   Tab — журнал"
		elif player_inside_seam:
			prompt_label.text = "Q — Focus, чтобы удержать seam   |   Tab — журнал"
		else:
			prompt_label.text = "Q — Focus   |   Tab — журнал"
		return

	prompt_label.text = "Следуй за светом разлома вдоль платформы   |   Tab — журнал"

func _refresh_journal() -> void:
	var lines: Array[String] = []
	lines.append("EIDARA / Кампания")
	lines.append("")
	lines.append("Текущая глава")
	lines.append("%s / %s" % [str(chapter_data.get("book", "ECHO")), str(chapter_data.get("title", ""))])
	lines.append("")
	lines.append("Модель уровня")
	lines.append("Каждая ключевая локация существует в двух состояниях.")
	lines.append("Veris: почти нормальный мир, где тревога прячется под рутиной.")
	lines.append("Fracture: та же геометрия после memory-slip, когда город показывает свою рану.")
	lines.append("")
	lines.append("Текущее состояние")
	lines.append("Состояние мира: %s" % ("Veris" if world_state == WORLD_VERIS else "Fracture"))
	lines.append("Фаза: %s" % _phase_label())
	lines.append("Focus использован: %s" % ("да" if has_seen_focus else "нет"))
	lines.append("Разлом пересечен: %s" % ("да" if fracture_entered else "нет"))
	lines.append("")
	lines.append("Дизайн главы")
	lines.append("Обычный мир: %s" % str(chapter_data.get("normal_state", "")))
	lines.append("Разлом: %s" % str(chapter_data.get("fracture_state", "")))
	lines.append("")
	lines.append("Карта кампании")
	for chapter in CampaignData.get_chapters():
		var marker := "•"
		if str(chapter.get("id", "")) == str(chapter_data.get("id", "")):
			marker = ">"
		var state_text := "playable" if bool(chapter.get("playable", false)) else "planned"
		var completion := " / done" if GameContext.has_completed(str(chapter.get("id", ""))) else ""
		lines.append("%s %s — %s [%s%s]" % [marker, str(chapter.get("book", "")), str(chapter.get("title", "")), state_text, completion])
	journal_label.text = "\n".join(lines)

func _phase_label() -> String:
	match phase:
		PHASE_INTRO:
			return "обычный гул"
		PHASE_FOCUS:
			return "шов найден"
		PHASE_FRACTURE:
			return "внутри разлома"
		PHASE_COMPLETE:
			return "глава завершена"
		_:
			return "неизвестно"

func _pulse_story_objects() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var seam_pulse := 0.5 + 0.5 * sin(t * 2.2)
	if seam_material != null:
		seam_material.emission_energy_multiplier = 2.2 + seam_pulse * 1.8
	seam_light.light_energy = (0.7 + seam_pulse * 0.8) if seam.visible else 0.0

	for index in resonance_markers.size():
		var marker := resonance_markers[index]
		var pulse := 0.6 + 0.4 * sin(t * 2.0 + float(index) * 0.8)
		if marker.has_node("Mesh"):
			var mesh: MeshInstance3D = marker.get_node("Mesh")
			mesh.scale = Vector3.ONE * (0.9 + pulse * 0.2)
		if marker.has_node("Light"):
			var light: OmniLight3D = marker.get_node("Light")
			light.light_energy = (0.9 + pulse * 0.7) if marker.visible else 0.0

func _set_tree_visible(root: Node, visible_state: bool) -> void:
	if root is Node3D:
		root.visible = visible_state
	for child in root.get_children():
		_set_tree_visible(child, visible_state)

func _set_selected_decals_visible(visible_state: bool) -> void:
	for decal_name in FRACTURE_GRAFFITI:
		if decals.has_node(decal_name):
			var decal: Node3D = decals.get_node(decal_name)
			decal.visible = visible_state

func _set_subway_children_visible(prefixes: Array, visible_state: bool) -> void:
	for child in subway_root.get_children():
		if child is Node3D:
			for prefix in prefixes:
				if String(child.name).begins_with(String(prefix)):
					child.visible = visible_state
					break

func _set_fracture_trash_state(in_fracture: bool) -> void:
	if trash_cans.has_node("trashcan2"):
		var broken_can: Node3D = trash_cans.get_node("trashcan2")
		broken_can.visible = in_fracture
	if trash_cans.has_node("trashcan7"):
		var normal_can: Node3D = trash_cans.get_node("trashcan7")
		normal_can.visible = not in_fracture
	if cork_boards is Node3D:
		cork_boards.visible = true
	if trash_cans is Node3D:
		trash_cans.visible = true

func _set_resonance_visible(visible_state: bool) -> void:
	resonance_trail.visible = visible_state
	for marker in resonance_markers:
		marker.visible = visible_state

func _set_status(message: String) -> void:
	status_label.text = message

func _play_fracture_transition() -> void:
	var tween := create_tween()
	tween.tween_property(transition_rect, "modulate:a", 0.72, 0.28)
	tween.tween_property(transition_rect, "modulate:a", 0.0, 0.65)

func _fade_title_card() -> void:
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(title_card, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func() -> void:
		title_card.visible = false
	)

func _on_seam_trigger_body_entered(body: Node) -> void:
	if body != player:
		return
	player_inside_seam = true
	if world_state == WORLD_VERIS and focus_mode:
		_set_status("Теперь видно, где обычный мир расходится по шву.")

func _on_seam_trigger_body_exited(body: Node) -> void:
	if body != player:
		return
	player_inside_seam = false

func _on_fracture_goal_trigger_body_entered(body: Node) -> void:
	if body != player:
		return
	if chapter_finished or not fracture_entered:
		return

	chapter_finished = true
	_set_phase(PHASE_COMPLETE)
	_set_status("Platform Seven собрана как двусоставная локация: Veris и Fracture.")
	completion_panel.visible = true
	return_button.grab_focus()
	chapter_completed.emit(str(chapter_data.get("id", "echo_platform_seven")))

func _on_return_button_pressed() -> void:
	request_return_to_campaign.emit()
