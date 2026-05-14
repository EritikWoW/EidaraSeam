extends RefCounted

const CHAPTERS := [
	{
		"id": "echo_platform_seven",
		"book": "ECHO",
		"chapter_label": "Book I / Chapter 1",
		"title": "The Subway's Hum",
		"scene_path": "res://scenes/chapters/platform_seven.tscn",
		"playable": true,
		"status": "Playable vertical slice",
		"normal_state": "Late, almost normal Veris: working platform, train, station lights and unsettling hum beneath the surface.",
		"fracture_state": "Same station after memory-slip: dirt, barricades, purple light, soft debris and broken spatial logic.",
		"goal": "Hear the hum, see the seam and take the first conscious step into the Fracture.",
		"future_hook": "Roman, the flute boy and the Platform Seven disaster become the gateway into Eidara."
	},
	{
		"id": "echo_cartographer_lantern",
		"book": "ECHO",
		"chapter_label": "Book I / Chapter 2",
		"title": "The Cartographer's Lantern",
		"scene_path": "",
		"playable": false,
		"status": "Design ready",
		"normal_state": "Quiet service rooms and archive corridors where the city map still looks rational.",
		"fracture_state": "Memory lanterns, false schemes and paths that lead across, not away.",
		"goal": "Teach the player to read the city as a map of desire rather than a transport network.",
		"future_hook": "The transition to Mechanary and deeper Eidara logic begins here."
	},
	{
		"id": "echo_mechanary_heart",
		"book": "ECHO",
		"chapter_label": "Book I / Chapters 5-10",
		"title": "Mechanary to Heart of Eidara",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Remnants of understandable urban architecture and human memory.",
		"fracture_state": "Mechanaries, seams, catwalks and rooms that remember too literally.",
		"goal": "Shift the game from a mystical subway to full-scale navigation through Eidara.",
		"future_hook": "Revelation of the Echo nature and Roman's truth."
	},
	{
		"id": "fracture_second_hum",
		"book": "FRACTURE",
		"chapter_label": "Book II / Chapters 1-2",
		"title": "The Subway's Second Hum",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Morning Veris with a functioning transport system and a sense of routine.",
		"fracture_state": "Sudden disappearance of one layer of sound and a city that starts speaking in instructions.",
		"goal": "Introduce Lena and Marek as grounded witnesses to the expanding crisis.",
		"future_hook": "Second hum shifts the game from a personal story to an ensemble one."
	},
	{
		"id": "fracture_library_unfinished",
		"book": "FRACTURE",
		"chapter_label": "Book II / Chapters 5-7",
		"title": "The Library of Unfinished Things",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Archives, studios and service rooms that could still be mistaken for reality.",
		"fracture_state": "Unfinished objects, glass corridors and spaces that remove reflections.",
		"goal": "Turn memory, recording and incompleteness into full gameplay mechanics.",
		"future_hook": "Irena, Thomas and Sol form the new core of the party."
	},
	{
		"id": "fracture_platform_seven_again",
		"book": "FRACTURE",
		"chapter_label": "Book II / Chapter 10",
		"title": "Platform Seven, Again",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Repeat of the familiar station with an unsettling sense of déjà vu.",
		"fracture_state": "A group of heroes gathers at the black door and is forced to answer the city with their own rhythm.",
		"goal": "Return the player to the same location but through an ensemble and accumulated memory.",
		"future_hook": "The transition to the third tone begins here."
	},
	{
		"id": "fracture_third_tone",
		"book": "FRACTURE",
		"chapter_label": "Book II / Epilogue",
		"title": "The Third Tone",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "City systems, maps and schemes that still try to look solid.",
		"fracture_state": "A tone in the gap between all systems, a new seam-line on the map and a city that learned a new note.",
		"goal": "Close the second book on a systemic level and open the way to the next cycle.",
		"future_hook": "Jun receives proof that the city has become something more than infrastructure."
	}
]

static func get_chapters() -> Array:
	var result: Array = []
	for chapter in CHAPTERS:
		result.append((chapter as Dictionary).duplicate(true))
	return result

static func get_chapter(chapter_id: String) -> Dictionary:
	for chapter in CHAPTERS:
		if str(chapter.get("id", "")) == chapter_id:
			return chapter.duplicate(true)
	return {}

static func get_default_chapter_id() -> String:
	for chapter in CHAPTERS:
		if bool(chapter.get("playable", false)):
			return str(chapter.get("id", ""))
	if CHAPTERS.is_empty():
		return ""
	return str(CHAPTERS[0].get("id", ""))

static func build_chapter_overview(chapter: Dictionary, completed: bool = false) -> String:
	if chapter.is_empty():
		return "Chapter not found."

	var lines: Array[String] = []
	lines.append("%s / %s" % [str(chapter.get("book", "EIDARA")), str(chapter.get("chapter_label", ""))])
	lines.append(str(chapter.get("title", "")))
	lines.append("")
	lines.append("Status: %s" % ("Completed in current build" if completed else str(chapter.get("status", "In development"))))
	lines.append("")
	lines.append("Normal World")
	lines.append(str(chapter.get("normal_state", "")))
	lines.append("")
	lines.append("Fracture")
	lines.append(str(chapter.get("fracture_state", "")))
	lines.append("")
	lines.append("Gameplay Goal")
	lines.append(str(chapter.get("goal", "")))
	lines.append("")
	lines.append("Next")
	lines.append(str(chapter.get("future_hook", "")))
	lines.append("")
	lines.append("Campaign Rule")
	lines.append("Each chapter is built as a single location in two states: Veris and Fracture.")
	return "\n".join(lines)
