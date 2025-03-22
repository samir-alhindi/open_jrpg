extends ColorRect

const TITLE_SCREEN = preload("res://title_screen.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		get_tree().change_scene_to_packed(TITLE_SCREEN)
