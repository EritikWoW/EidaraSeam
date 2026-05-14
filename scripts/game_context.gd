extends Node

const SAVE_PATH := "user://eidara_progress.cfg"

var current_chapter_id := ""
var selected_chapter_index := 0
var completed_chapters: Array[String] = []

func _ready() -> void:
	load_progress()

func has_completed(chapter_id: String) -> bool:
	return completed_chapters.has(chapter_id)

func mark_chapter_complete(chapter_id: String) -> void:
	if not completed_chapters.has(chapter_id):
		completed_chapters.append(chapter_id)
	current_chapter_id = chapter_id
	save_progress()

func set_selected_chapter(index: int) -> void:
	selected_chapter_index = max(index, 0)
	save_progress()

func set_current_chapter(chapter_id: String) -> void:
	current_chapter_id = chapter_id
	save_progress()

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return

	selected_chapter_index = int(config.get_value("progress", "selected_chapter_index", 0))
	current_chapter_id = str(config.get_value("progress", "current_chapter_id", ""))

	completed_chapters.clear()
	var stored_completed: Array = config.get_value("progress", "completed_chapters", [])
	for chapter_id in stored_completed:
		completed_chapters.append(str(chapter_id))

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "selected_chapter_index", selected_chapter_index)
	config.set_value("progress", "current_chapter_id", current_chapter_id)
	config.set_value("progress", "completed_chapters", completed_chapters)
	config.save(SAVE_PATH)
