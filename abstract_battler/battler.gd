class_name Battler extends Node2D


@onready var anim: AnimationPlayer = $AnimationPlayer

var isDefeated: bool = false

signal deciding_finished
signal performing_action_finished

func _ready() -> void:
	set_process(false)

func decide_action():
	pass

func perform_action() -> void:
	pass

func defeated() -> void:
	pass

func play_anim(animationName: String) -> void:
	if animationName == "heal":
		$AnimationPlayer.play("heal")
	else:
		$AnimatedSprite2D.play(animationName)

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation != "defeated":
		$AnimatedSprite2D.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		queue_free()
