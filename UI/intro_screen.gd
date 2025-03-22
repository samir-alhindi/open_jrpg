extends ColorRect

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		get_tree().change_scene_to_file("uid://0xc8hpp1566k")
