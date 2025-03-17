class_name Battler extends Node2D

@onready var action_decider: Node = $ActionDecider
@onready var anim: AnimationPlayer = $AnimationPlayer

var isDefeated: bool = false

var actionAftermathTexts := {
	"took damage" : "%s took %d damage !",
	"defend self" : "%s's defense increased by %d !",
	"heal" : "%s recovered %d health!"
}

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
	$AnimatedSprite2D.play(animationName)

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation != "defeated":
		$AnimatedSprite2D.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
