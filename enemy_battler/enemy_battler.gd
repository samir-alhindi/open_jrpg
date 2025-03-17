class_name EnemyBattler extends Battler

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var stats: EnemyStats
@onready var actions: Array[EnemyAction] = stats.actions

var actionChances: Array = []
var random: RandomNumberGenerator
var actionToPerform: EnemyAction
var targetBattlers: Array[Battler]
var none: int = 0

@onready var health: int = stats.health:
	set(value):
		health = value
		health_label.text = "Health: " + str(health)
@onready var strength: int = stats.strength:
	set(value):
		strength = value
		strength_label.text = "Strength: " + str(strength)
@onready var magicStrength: int = stats.magicStrength
@onready var defense: int = stats.defense:
	set(value):
		defense = value
		defense_label.text = "Defense: " + str(defense)
@onready var speed: int = stats.speed
@onready var name_: String = stats.name
@onready var defeatedText: String = stats.defeatedText
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	randomize()
	animated_sprite_2d.scale *= stats.texture_scale
	random = RandomNumberGenerator.new()
	for action: EnemyAction in actions:
		actionChances.append(action.enemyActionChance)
	# Load SpriteFrames:
	animated_sprite_2d.sprite_frames = stats.spriteFrames
	animated_sprite_2d.play("idle")

func decide_action():
	actionToPerform = actions[random.rand_weighted(actionChances)]
	if actionToPerform.actionTargetType == EnemyAction.ActionTargetType.SINGLE_ALLY:
		targetBattlers.append(get_tree().get_nodes_in_group("allies").pick_random())
	elif actionToPerform.actionTargetType == EnemyAction.ActionTargetType.ALL_ALLIES:
		targetBattlers.assign(get_tree().get_nodes_in_group("allies").duplicate())
	elif actionToPerform.actionTargetType == EnemyAction.ActionTargetType.SINGLE_ENEMY:
		targetBattlers.append(get_tree().get_nodes_in_group("enemies").pick_random())
	await get_tree().create_timer(0.01).timeout
	self.deciding_finished.emit()

func perform_action() -> void:
	SignalBus.display_text.emit(name_+" "+actionToPerform.actionText)
	Audio.action.stream = actionToPerform.sound; Audio.action.play(); #Sound.
	await SignalBus.text_window_closed
	for battler: Battler in targetBattlers:
		#Check if the ally is dead before attacking:
		if battler.isDefeated:
			SignalBus.display_text.emit(battler.name_+" has already been defeated !")
			await SignalBus.text_window_closed
			await get_tree().create_timer(0.1).timeout
			continue
		#Regular ally attacking/whatever:
		var actionAmount: float = (actionToPerform.amount + self.get(actionToPerform.actionPerformerEnhancerVariable) + battler.get(actionToPerform.targetBattlerEnhancerVariable)) 
		actionAmount = clamp(actionAmount, -5000, 0) if actionToPerform.amount < 0 else clamp(actionAmount, 0, 5000)
		var newAmount: float = battler.get(actionToPerform.targetBattlerVariable) + actionAmount
		battler.set(actionToPerform.targetBattlerVariable, newAmount)
		var formatedText: String = actionAftermathTexts[actionToPerform.actionAftermathTextType] % [battler.name_, abs(actionAmount)]
		SignalBus.display_text.emit(formatedText); Audio.play_action_sound(actionToPerform.animation_and_sound); battler.play_anim(actionToPerform.animation_and_sound);
		await SignalBus.text_window_closed
		await get_tree().create_timer(0.1).timeout
		#Check if ally has been defeated:
		if battler.health <= 0:
			Audio.down.play()
			battler.anim.play("defeated")
			await get_tree().create_timer(1.0).timeout #Wait till anim is done
			SignalBus.display_text.emit(battler.defeatedText)
			await SignalBus.text_window_closed
			battler.isDefeated = true
	targetBattlers.clear()
	self.performing_action_finished.emit()

#Debugging:
@onready var health_label: Label = %HealthLabel
@onready var strength_label: Label = %StrengthLabel
@onready var defense_label: Label = %DefenseLabel
func _process(delta: float) -> void:
	health_label.text = "Health: " + str(health)
