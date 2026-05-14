extends Node

const CampaignData := preload("res://scripts/campaign_data.gd")

@onready var world_host: Node = $WorldHost
@onready var menu_root: Control = $FrontEnd/MenuRoot
@onready var chapter_list: ItemList = $FrontEnd/MenuRoot/Backdrop/CampaignPanel/MarginContainer/VBoxContainer/Body/ChapterList
@onready var details_label: RichTextLabel = $FrontEnd/MenuRoot/Backdrop/CampaignPanel/MarginContainer/VBoxContainer/Body/DetailsPanel/MarginContainer/DetailsLabel
@onready var start_button: Button = $FrontEnd/MenuRoot/Backdrop/CampaignPanel/MarginContainer/VBoxContainer/Footer/StartButton
@onready var continue_button: Button = $FrontEnd/MenuRoot/Backdrop/CampaignPanel/MarginContainer/VBoxContainer/Footer/ContinueButton
@onready var status_label: Label = $FrontEnd/MenuRoot/Backdrop/CampaignPanel/MarginContainer/VBoxContainer/StatusLabel
@onready var fade_rect: ColorRect = $FrontEnd/FadeRect

var current_chapter: Node = null
var chapter_ids: Array[String] = []
var selected_index := 0
var selected_chapter_id := ""

func _ready() -> void:
	_populate_chapter_list()
	_restore_selection()
	_refresh_continue_button()
	_show_menu(true)
	fade_rect.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0)

func _populate_chapter_list() -> void:
	chapter_list.clear()
	chapter_ids.clear()

	for chapter in CampaignData.get_chapters():
		var chapter_id := str(chapter.get("id", ""))
		chapter_ids.append(chapter_id)
		var label := "%s / %s" % [str(chapter.get("book", "")), str(chapter.get("title", ""))]
		if not bool(chapter.get("playable", false)):
			label += " [planned]"
		elif GameContext.has_completed(chapter_id):
			label += " [done]"
		chapter_list.add_item(label)

func _restore_selection() -> void:
	if chapter_ids.is_empty():
		return

	selected_index = int(clamp(GameContext.selected_chapter_index, 0, chapter_ids.size() - 1))
	chapter_list.select(selected_index)
	_apply_selection(selected_index)

func _apply_selection(index: int) -> void:
	if index < 0 or index >= chapter_ids.size():
		return

	selected_index = index
	selected_chapter_id = chapter_ids[index]
	var chapter := CampaignData.get_chapter(selected_chapter_id)
	details_label.text = CampaignData.build_chapter_overview(chapter, GameContext.has_completed(selected_chapter_id))
	status_label.text = "Кампания строится как набор локаций в двух состояниях: Veris и Fracture."
	start_button.disabled = not bool(chapter.get("playable", false))
	GameContext.set_selected_chapter(selected_index)

func _refresh_continue_button() -> void:
	var current_data := CampaignData.get_chapter(GameContext.current_chapter_id)
	var can_continue := GameContext.current_chapter_id != "" and not current_data.is_empty() and bool(current_data.get("playable", false))
	continue_button.disabled = not can_continue

func _launch_selected_chapter() -> void:
	_launch_chapter(selected_chapter_id)

func _launch_chapter(chapter_id: String) -> void:
	var chapter := CampaignData.get_chapter(chapter_id)
	if chapter.is_empty():
		status_label.text = "Не удалось найти выбранную главу."
		return

	if not bool(chapter.get("playable", false)):
		status_label.text = "Эта глава уже встроена в кампанию, но пока не собрана как игровая сцена."
		return

	var packed_scene := load(str(chapter.get("scene_path", ""))) as PackedScene
	if packed_scene == null:
		status_label.text = "Сцена главы не загрузилась."
		return

	_clear_current_chapter()
	current_chapter = packed_scene.instantiate()
	world_host.add_child(current_chapter)

	if current_chapter.has_signal("chapter_completed"):
		current_chapter.connect("chapter_completed", Callable(self, "_on_chapter_completed"))
	if current_chapter.has_signal("request_return_to_campaign"):
		current_chapter.connect("request_return_to_campaign", Callable(self, "_on_request_return_to_campaign"))
	if current_chapter.has_method("start_chapter"):
		current_chapter.call("start_chapter", chapter)

	GameContext.set_selected_chapter(selected_index)
	GameContext.set_current_chapter(chapter_id)
	_refresh_continue_button()
	_show_menu(false)

func _clear_current_chapter() -> void:
	if current_chapter == null:
		return
	if is_instance_valid(current_chapter):
		current_chapter.queue_free()
	current_chapter = null

func _show_menu(visible_state: bool) -> void:
	menu_root.visible = visible_state
	if visible_state:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_chapter_list_item_selected(index: int) -> void:
	_apply_selection(index)

func _on_chapter_list_item_activated(index: int) -> void:
	_apply_selection(index)
	_launch_selected_chapter()

func _on_start_pressed() -> void:
	_launch_selected_chapter()

func _on_continue_pressed() -> void:
	var target_id := GameContext.current_chapter_id
	if target_id == "":
		target_id = CampaignData.get_default_chapter_id()
	_launch_chapter(target_id)

func _on_chapter_completed(chapter_id: String) -> void:
	GameContext.mark_chapter_complete(chapter_id)
	_populate_chapter_list()
	_restore_selection()
	_refresh_continue_button()

func _on_request_return_to_campaign() -> void:
	_clear_current_chapter()
	_populate_chapter_list()
	_restore_selection()
	_refresh_continue_button()
	_show_menu(true)
	status_label.text = "Глава закрыта. Выбирай следующую локацию кампании."
