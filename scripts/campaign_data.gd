extends RefCounted

const CHAPTERS := [
	{
		"id": "echo_platform_seven",
		"book": "ECHO",
		"chapter_label": "Book I / Chapter 1",
		"title": "The Subway's Hum",
		"scene_path": "res://scenes/chapters/platform_seven.tscn",
		"playable": true,
		"status": "Playable prototype",
		"normal_state": "Поздний, почти обычный Veris: рабочая платформа, поезд, станцийный свет и тревожный гул под поверхностью.",
		"fracture_state": "Та же станция после memory-slip: грязь, баррикады, фиолетовый свет, мягкие завалы и нарушенная логика пространства.",
		"goal": "Услышать гул, увидеть seam и сделать первый осознанный шаг в разлом.",
		"future_hook": "Roman, мальчик с флейтой и катастрофа Platform Seven становятся входом в Eidara."
	},
	{
		"id": "echo_cartographer_lantern",
		"book": "ECHO",
		"chapter_label": "Book I / Chapter 2",
		"title": "The Cartographer's Lantern",
		"scene_path": "",
		"playable": false,
		"status": "Design ready",
		"normal_state": "Тихие помещения обслуживания и архивные коридоры, где карта города еще выглядит рациональной.",
		"fracture_state": "Фонари памяти, ложные схемы и проходы, которые ведут across, а не away.",
		"goal": "Научить игрока читать город как карту желаний, а не как транспортную сеть.",
		"future_hook": "Отсюда начнется переход к Mechanary и deeper Eidara logic."
	},
	{
		"id": "echo_mechanary_heart",
		"book": "ECHO",
		"chapter_label": "Book I / Chapters 5-10",
		"title": "Mechanary to Heart of Eidara",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Остатки понятной городской архитектуры и человеческой памяти.",
		"fracture_state": "Механарии, швы, катwalks и комнаты, которые помнят слишком буквально.",
		"goal": "Сместить игру из мистического метро в полноценную навигацию по Eidara.",
		"future_hook": "Раскрытие природы Echo и Roman's truth."
	},
	{
		"id": "fracture_second_hum",
		"book": "FRACTURE",
		"chapter_label": "Book II / Chapters 1-2",
		"title": "The Subway's Second Hum",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Утренний Veris с работающей транспортной системой и ощущением рутины.",
		"fracture_state": "Внезапное исчезновение одного слоя звука и город, который начинает говорить инструкциями.",
		"goal": "Ввести Lena и Marek как grounded witnesses к расширяющемуся кризису.",
		"future_hook": "Second hum меняет игру из личной истории в ансамблевую."
	},
	{
		"id": "fracture_library_unfinished",
		"book": "FRACTURE",
		"chapter_label": "Book II / Chapters 5-7",
		"title": "The Library of Unfinished Things",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Архивы, студии и служебные комнаты, которые еще можно принять за реальность.",
		"fracture_state": "Незавершенные предметы, стеклянные коридоры и пространства, удаляющие отражения.",
		"goal": "Сделать память, запись и незавершенность полноценными механиками.",
		"future_hook": "Irena, Thomas и Sol формируют новое ядро партии."
	},
	{
		"id": "fracture_platform_seven_again",
		"book": "FRACTURE",
		"chapter_label": "Book II / Chapter 10",
		"title": "Platform Seven, Again",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Повтор знакомой станции с тревожным ощущением déjà vu.",
		"fracture_state": "Группа героев собирается у черной двери и вынуждена ответить городу своим ритмом.",
		"goal": "Вернуть игрока в ту же локацию, но уже через ансамбль и накопленную память.",
		"future_hook": "Отсюда начинается переход к third tone."
	},
	{
		"id": "fracture_third_tone",
		"book": "FRACTURE",
		"chapter_label": "Book II / Epilogue",
		"title": "The Third Tone",
		"scene_path": "",
		"playable": false,
		"status": "Campaign planned",
		"normal_state": "Системы города, карты и схемы, которые еще пытаются выглядеть твердо.",
		"fracture_state": "Тон в промежутке между всеми системами, новая seam-line на карте и город, научившийся новой ноте.",
		"goal": "Закрыть вторую книгу на системном уровне и открыть путь к следующему циклу.",
		"future_hook": "Jun получает доказательство, что город стал чем-то большим, чем инфраструктура."
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
		return "Глава не найдена."

	var lines: Array[String] = []
	lines.append("%s / %s" % [str(chapter.get("book", "EIDARA")), str(chapter.get("chapter_label", ""))])
	lines.append(str(chapter.get("title", "")))
	lines.append("")
	lines.append("Статус: %s" % ("Завершена в текущем билде" if completed else str(chapter.get("status", "В работе"))))
	lines.append("")
	lines.append("Обычный мир")
	lines.append(str(chapter.get("normal_state", "")))
	lines.append("")
	lines.append("Разлом")
	lines.append(str(chapter.get("fracture_state", "")))
	lines.append("")
	lines.append("Игровая цель")
	lines.append(str(chapter.get("goal", "")))
	lines.append("")
	lines.append("Дальше")
	lines.append(str(chapter.get("future_hook", "")))
	lines.append("")
	lines.append("Правило кампании")
	lines.append("Каждая глава строится как одна локация в двух состояниях: Veris и Fracture.")
	return "\n".join(lines)
