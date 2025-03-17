extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func fade_into_black() -> void:
	animation_player.play("fade_into_black")

func fade_into_game() -> void:
	animation_player.play("fade_into_game")
