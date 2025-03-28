class_name Battler extends Node2D

@onready var status_effect_sprite: Sprite2D = $StatusEffectSprite
@onready var anim: AnimationPlayer = $AnimationPlayer

# Flags:
var isDefeated: bool = false
var isDisabled: bool = false

# Status effect that prevents the battler from performing an action:
var disablingStatusEffect: StatusEffect

var opponents: StringName

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
	var animPlayerAnims: Array[String] = ["heal", "cursed"]
	if animationName in animPlayerAnims:
		$AnimationPlayer.play(animationName)
	else:
		$AnimatedSprite2D.play(animationName)

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation != "defeated":
		$AnimatedSprite2D.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		queue_free()

func check_if_we_won() -> bool:
	var is_defated: Callable = func (battler: Battler) -> bool:
		return battler.isDefeated
	var battlers: Array[Battler]
	battlers.assign(get_tree().get_nodes_in_group(opponents))
	if battlers.all(is_defated):
		return true
	return false
