## Abstract class that [AllyBattler] and [EnemyBattler] inherit from.

class_name Battler extends Node2D

## Sprite that displays an icon indicating the battler is suffering from 
## a [StatusEffect].
@onready var status_effect_sprite: Sprite2D = $StatusEffectSprite
## Contains some animations.
@onready var anim: AnimationPlayer = $AnimationPlayer

# Flags:
## indicates whether the battler is dead or alive.
var isDefeated: bool = false
## indicates whether the battler is suffering from a [StatusEffect]
##  that disables them from Performing any actions.
var isDisabled: bool = false

## Status effect that prevents the battler from performing an action, 
##  it is set to [code]null[/code] if no status effect is currently inflected.
var disablingStatusEffect: StatusEffect

## This [String] is [code]"enemies"[/code] for the allies, and [code]"allies"[/code] for the enemies, 
## it's used in [method Battler.check_if_we_won].
var opponents: StringName

## Emited after the battler has chosen an action to perform.
@warning_ignore("unused_signal")
signal deciding_finished
## Emited after the battler has finished acting.
@warning_ignore("unused_signal")
signal performing_action_finished

func _ready() -> void:
	set_process(false)

## Lets the battler decide an action that they will perform when [method Battler.perform_action]
## is called.
func decide_action():
	pass

## Lets the battler perform the action that they chose in [method Battler.decide_action]
func perform_action() -> void:
	pass

## This method decides whether the animation is meant to be played by the [AnimationPlayer]
## or by the [AnimatedSprite2D].
func play_anim(animationName: String) -> void:
	var animPlayerAnims: Array[String] = ["heal", "cursed"]
	if animationName in animPlayerAnims:
		$AnimationPlayer.play(animationName)
	else:
		$AnimatedSprite2D.play(animationName)

## This method makes the battler play the [code]"idle"[/code] animation again after finishing
## any other animation except for [code]"defeated"[/code].
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation != "defeated":
		$AnimatedSprite2D.play("idle")

## This method simply frees the battler from memory if it's [code]"fade_out"[/code] animation
## is finished.
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		queue_free()

## Gets called everytime a battler is defeated, The [AllyBattler]s use it to
## check if the battle has been won, The [EnemyBattler]s use it to check if 
## the battle has been lost.
func check_if_we_won() -> bool:
	var is_defated: Callable = func (battler: Battler) -> bool:
		return battler.isDefeated
	var battlers: Array[Battler]
	battlers.assign(get_tree().get_nodes_in_group(opponents))
	if battlers.all(is_defated):
		return true
	return false
