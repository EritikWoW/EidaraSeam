extends SceneTree

func _init():
	var args = OS.get_cmdline_args()
	var scene_path = ""
	for i in range(args.size()):
		if args[i].begins_with("--scene="):
			scene_path = args[i].split("=")[1]

	if scene_path == "":
		print("Error: No scene path provided via --scene=<path>")
		quit(1)
		return

	print("Validating scene: ", scene_path)
	var scene = load(scene_path)
	if not scene:
		print("Error: Could not load scene at ", scene_path)
		quit(1)
		return

	var instance = scene.instantiate()
	if not instance:
		print("Error: Could not instantiate scene")
		quit(1)
		return

	print("Scene instantiated successfully: ", instance.name)

	# Verify script attachment
	var script = instance.get_script()
	if script:
		print("Script attached: ", script.get_path())
	else:
		# If no script attached, try to check if it's main.tscn and if it references res://scripts/main.gd
		# This is a bit complex for a static test, but we can check if it's the right node type.
		print("Warning: No script attached to root node")

	# Check for specific nodes depending on the scene
	var nodes_to_check = []
	if scene_path.ends_with("platform_seven.tscn"):
		nodes_to_check = [
			"WorldAnchors",
			"WorldAnchors/PortalRig",
			"WorldAnchors/QuestAreas/PortalArea",
			"HUD/ObjectivePanel/MarginContainer/ObjectiveLabel",
			"HUD/PromptPanel/MarginContainer/PromptLabel"
		]
	elif scene_path.ends_with("main.tscn"):
		nodes_to_check = [
			"WorldHost",
			"FrontEnd/MenuRoot",
			"FrontEnd/MenuRoot/Backdrop/CampaignPanel/MarginContainer/VBoxContainer/Body/ChapterList"
		]

	var all_found = true
	for path in nodes_to_check:
		var node = instance.get_node_or_null(path)
		if node:
			print("Found node: ", path)
		else:
			print("Error: Missing node: ", path)
			all_found = false

	if not all_found:
		print("Printing tree for debugging:")
		_print_tree(instance, "")
		quit(1)
		return

	print("Validation complete.")
	quit(0)

func _print_tree(node, indent):
	print(indent, node.name, " (", node.get_class(), ")")
	for child in node.get_children():
		_print_tree(child, indent + "  ")
