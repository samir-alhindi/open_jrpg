## Class for every enemy battler.
##
## This class takes an [EnemyStats] resource that contains all of the enemy's data, 
## If you're trying to create an enemy then create an [EnemyStats] resoruce and then fill
##  in everything and finaly add it into a battle [BattleData] resource.


class_name EnemyBattler extends Battler

## Most important variable, conatins all the enemy's data.
@export var stats: EnemyStats
## 2nd most important variable, contains all the [EnemyAction] that this enemy
## can possibly perform.
@onready var actions: Array[EnemyAction] = stats.actions

## This variable is related to how the enemy can randomaly choose [EnemyAction]s
## from [member EnemyBattler.actions] based on specific weights, 
## look into [method RandomNumberGenerator.rand_weighted] to learn more.
var actionChances: Array = []
## [RandomNumberGenerator] object.
var random: RandomNumberGenerator
## The action that this enemy will perfom when [method EnemyBattler.perform_action] is called.
var actionToPerform: EnemyAction
var targetBattlers: Array[Battler]

# Defending stuff:
var isDefending: bool = false
var defendAmount: int

@onready var health: int = stats.health
@onready var strength: int = stats.strength
@onready var magicStrength: int = stats.magicStrength
@onready var defense: int = stats.defense
@onready var speed: int = stats.speed
@onready var name_: String = stats.name_:
	set(val):
		name_ = val
		%NameLabel.text = val
@onready var defeatedText: String = stats.defeatedText
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	check_abstract_classes()
	randomize()
	animated_sprite_2d.scale *= stats.texture_scale
	random = RandomNumberGenerator.new()
	for action: EnemyAction in actions:
		actionChances.append(action.enemyActionChance)
	# Load SpriteFrames:
	animated_sprite_2d.sprite_frames = stats.spriteFrames
	animated_sprite_2d.play("idle")
	animated_sprite_2d.offset += stats.offset
	# init other stuff:
	opponents = "allies"

func decide_action() -> void:
	handle_defense()
	# Battler can't decide since it's disabled (asleep, paralyzed, etc...).
	if isDisabled:
		actionToPerform = null
		targetBattlers.clear()
		await get_tree().create_timer(0.01).timeout
		self.deciding_finished.emit()
		return
	actionToPerform = actions[random.rand_weighted(actionChances)]
	if actionToPerform is EnemyAttack:
		if actionToPerform.actionTargetType == EnemyAttack.ActionTargetType.SINGLE_ALLY:
			targetBattlers.append(get_tree().get_nodes_in_group("allies").pick_random())
		elif actionToPerform.actionTargetType == EnemyAttack.ActionTargetType.ALL_ALLIES:
			targetBattlers.assign(get_tree().get_nodes_in_group("allies").duplicate())
	elif actionToPerform is EnemyDefend:
		targetBattlers.append(self)
	await get_tree().create_timer(0.01).timeout
	self.deciding_finished.emit()

func perform_action() -> void:
	SignalBus.cursor_come_to_me.emit(self.global_position, false)
	#region Status effect logic:
	# Check if self is inflected with disabling status effect (sleep, paralysis, ect...):
	if disablingStatusEffect != null:
		# Decrement effect duration by 1 since 1 turn has passed:
		disablingStatusEffect.effectDuration -= 1
		# Check if status effect duration is over:
		if disablingStatusEffect.effectDuration <= 0:
			# Enable the battler again:
			isDisabled = false
			# Display text showing it's been removed:
			SignalBus.display_text.emit(name_ + " " + disablingStatusEffect.removalText)
			# Remove status effect:
			disablingStatusEffect = null
			status_effect_sprite.texture = null
			# End turn:
			await SignalBus.text_window_closed
			performing_action_finished.emit()
			return
		# Display message and sound:
		SignalBus.display_text.emit(name_ + " " + disablingStatusEffect.text)
		Audio.status_effect.stream = disablingStatusEffect.sound
		Audio.status_effect.play()
		await SignalBus.text_window_closed
		# Prevent battler from playing this turn:
		performing_action_finished.emit()
		return
	#endregion
	SignalBus.display_text.emit(name_+" "+actionToPerform.actionText)
	#play action sound:
	Audio.action.stream = actionToPerform.sound
	Audio.action.play()
	await SignalBus.text_window_closed
	for battler: Battler in targetBattlers:
		#Check if we're targeting a dead battler:
		if battler.isDefeated:
			SignalBus.display_text.emit(battler.name_+" has already been defeated !")
			await SignalBus.text_window_closed
			await get_tree().create_timer(0.1).timeout
			continue
		# check action type:
		#region Attack action:
		if actionToPerform is EnemyAttack:
			# Play attack animation:
			play_anim("attack")
			# Calculate actual damage amount:
			var damage: int = (actionToPerform.damageAmount + strength)
			damage = damage - battler.defense
			# Make sure we don't deal negative damage:
			damage = clamp(damage, 0, 9999999)
			# Hurt the target battler:
			battler.health -= damage
			# Display text:
			var text: String = battler.name_ + " took " + str(damage) + " !"
			SignalBus.display_text.emit(text)
			# Play SFX of target battler getting hurt:
			Audio.play_action_sound("hurt")
			# Play target battler hurt animation:
			battler.play_anim("hurt");
			# Wait until player closes text window:
			await SignalBus.text_window_closed
			# Wait a moment:
			await get_tree().create_timer(0.1).timeout
			# Check if target battler died
			if battler.health <= 0:
				# Set the battler to the "defeated" state:
				battler.isDefeated = true
				# Play battler dead sound:
				Audio.down.play()
				# Make target battler play death aniamtion:
				battler.play_anim("defeated")
				#Wait till anim is done
				await get_tree().create_timer(1.0).timeout
				# Display the battler's uniqe death text:
				SignalBus.display_text.emit(battler.defeatedText)
				# Wait until player closes text window:
				await SignalBus.text_window_closed
				# Check if enemies have won:
				if check_if_we_won() == true:
					SignalBus.battle_lost.emit()
					return
				#endregion
		#region Defend action:
		elif actionToPerform is EnemyDefend:
			# Play defending animation:
			play_anim("defend")
			var defenseAmount: int = actionToPerform.defenseAmount
			# Increase our defense stat:
			self.defense += defenseAmount
			# Save the increased amount for later use:
			defendAmount = defenseAmount
			# Change state:
			isDefending = true
			# Display text:
			var text: String = battler.name_ + "'s defense increased by " + str(defenseAmount) + " !"
			SignalBus.display_text.emit(text)
			# Play SFX of self defending:
			Audio.play_action_sound("defend")
			# Play self defense animation:
			battler.play_anim("defend");
			# Wait until player closes text window:
			await SignalBus.text_window_closed
			# Wait a moment:
			await get_tree().create_timer(0.1).timeout
			#endregion
	# Clear target battlers array:
	targetBattlers.clear()
	# Signal to the battle node that we're done:
	performing_action_finished.emit()

func check_abstract_classes() -> void:
	for action: EnemyAction in actions:
		if action is EnemyAttack or action is EnemyDefend:
			pass
		# This is an abstract class; Throw error:
		else:
			var class_ = action.get_script().get_global_name()
			var path_ := action.resource_path
			var error := "The action at: \"%s\" is an instance of the abstract class \"%s\"."
			error += "\nMake the action inherit \"EnemyAttack\" or \"EnemyDefend\"."
			var formated := error % [path_, class_]
			assert(false, formated)

## Handles the defense stat.
func handle_defense() -> void:
	if isDefending:
		defense -= defendAmount
		isDefending = false
