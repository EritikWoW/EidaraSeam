extends SceneTree

func _init():
	print("Starting static validation...")

	var scenes_to_test = [
		"res://scenes/main.tscn",
		"res://scenes/chapters/platform_seven.tscn"
	]

	for scene_path in scenes_to_test:
		print("Testing scene: ", scene_path)
		var scene = load(scene_path)
		if scene == null:
			print("FAILED: Could not load scene: ", scene_path)
			quit(1)
			return

		var instance = scene.instantiate()
		if instance == null:
			print("FAILED: Could not instantiate scene: ", scene_path)
			quit(1)
			return

		print("SUCCESS: Scene ", scene_path, " loaded and instantiated correctly.")
		instance.free()

	print("Validation complete. All scenes loaded successfully.")
	quit(0)
