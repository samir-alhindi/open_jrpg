class_name AllyBattler extends Battler

@onready var control: Control = %Control
@onready var selection_window: NinePatchRect = $UI/Control/SelectionWindow
@onready var options_container: VBoxContainer = $UI/Control/SelectionWindow/OptionsContainer
@onready var button_container: HBoxContainer = %ButtonContainer
@onready var attack_button: Button = %AttackButton
@onready var magic_button: Button = %MagicButton
@onready var item_button: Button = %ItemButton
@onready var defending_manager: Node = $DefendingDecider_Manager
@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar
@onready var magic_bar: ProgressBar = $VBoxContainer/MagicBar
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

## Contains actions, sprites, UI theme, ect.
@export var stats: AllyStats

@onready var health: int = stats.health:
	set(value):
		if value >= max_health:
			health = max_health
		else:
			health = value
		health_label.text = "Health: " + str(health)
		health_bar.value = health
@onready var magicPoints: int = stats.magicPoints:
	set(value):
		magicPoints = value
		magic_points_label.text = "Magic points: " + str(magicPoints)
		magic_bar.value = value
@onready var max_health: int = stats.health
@onready var strength: int = stats.strength
@onready var magicStrength: int = stats.magicStrength
@onready var defense: int = stats.defense
@onready var speed: int = stats.speed
@onready var name_: String = stats.name
@onready var defeatedText: String = stats.defeatedText

@onready var attackActions: Array[AllyAttackAction] = stats.attackActions
@onready var defendAction: AllyDefendAction = stats.defendAction
@onready var magicActions: Array[AllyMagicAction] = stats.magicActions
@onready var items: Array[AllyItemAction] = stats.items

var actionToPerform: AllyAction
var targetBattlers: Array[Battler]
var none: int = 0

func _ready() -> void:
	health_bar.max_value = self.health
	magic_bar.max_value = magicPoints
	health += 0; magicPoints += 0 # init the progress bars.
	control.theme = stats.ui_theme
	button_container.hide()
	animated_sprite_2d.scale *= stats.texture_scale
	animated_sprite_2d.flip_h = true
	animated_sprite_2d.offset.y -= 30
	if stats.can_use_magic == false:
		magic_button.queue_free()
		magic_bar.hide()
		magic_points_label.hide()
	# Load SpriteFrames:
	animated_sprite_2d.sprite_frames = stats.spriteFrames
	animated_sprite_2d.play("idle")

func decide_action() -> void:
	if items.size() <= 0:
		item_button.hide()
	defending_manager.manage_defense_stat()
	targetBattlers.clear()
	button_container.show()
	await get_tree().create_timer(0.5).timeout
	attack_button.grab_focus()

#func perform_action() -> void:
	#SignalBus.display_text.emit(name_+" "+actionToPerform.actionText)
	#Audio.action.stream = actionToPerform.sound; Audio.action.play(); #Sound.
	#await SignalBus.text_window_closed
	#for battler: Battler in targetBattlers:
		##Check if we're attacking/whatever a dead battler:
		#if battler.isDefeated:
			#SignalBus.display_text.emit(battler.name_+" has already been defeated !")
			#await SignalBus.text_window_closed
			#await get_tree().create_timer(0.1).timeout
			#continue
		##Regular battler attacking/whatever:
		#var actionAmount: float = (actionToPerform.amount + self.get(actionToPerform.actionPerformerEnhancerVariable) + battler.get(actionToPerform.targetBattlerEnhancerVariable)) 
		#actionAmount = clamp(actionAmount, -5000, 0) if actionToPerform.amount < 0 else clamp(actionAmount, 0, 5000)
		#var newAmount: float = battler.get(actionToPerform.targetBattlerVariable) + actionAmount
		#battler.set(actionToPerform.targetBattlerVariable, newAmount)
		#var formatedText: String = actionAftermathTexts[actionToPerform.actionAftermathTextType] % [battler.name_, abs(actionAmount)]
		#SignalBus.display_text.emit(formatedText); Audio.play_action_sound(actionToPerform.animation_and_sound); battler.play_anim(actionToPerform.animation_and_sound);
		#await SignalBus.text_window_closed
		#await get_tree().create_timer(0.1).timeout
		#if battler.health <= 0:
			#Audio.down.play()
			#battler.play_anim("defeated")
			#await get_tree().create_timer(1.0).timeout #Wait till anim is done
			#SignalBus.display_text.emit(battler.defeatedText)
			#await SignalBus.text_window_closed
			#battler.isDefeated = true
	#performing_action_finished.emit()


func perform_action() -> void:
	SignalBus.display_text.emit(name_+" "+actionToPerform.actionText)
	#play action sound:
	Audio.action.stream = actionToPerform.sound
	Audio.action.play()
	await SignalBus.text_window_closed
	for battler: Battler in targetBattlers:
		##Check if we're targeting a dead battler:
		if battler.isDefeated:
			SignalBus.display_text.emit(battler.name_+" has already been defeated !")
			await SignalBus.text_window_closed
			await get_tree().create_timer(0.1).timeout
			continue
		# check action type:
		#region Attack action:
		if actionToPerform is AllyAttackAction:
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
				#endregion
		#region Defend action:
		elif actionToPerform is AllyDefendAction:
			var defenseAmount: int = actionToPerform.defenseAmount
			# Increase our defense stat:
			self.defense += defenseAmount
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
		elif actionToPerform is AllyMagicAction:
			pass
	# Clear target battlers array:
	targetBattlers.clear()
	# Signal to the battle node that we're done:
	performing_action_finished.emit()

#For Displaying stats:
@onready var health_label: Label = %HealthLabel
@onready var magic_points_label: Label = %MagicPointsLabel
@onready var strength_label: Label = %StrengthLabel
@onready var defense_label: Label = %DefenseLabel
func _process(delta: float) -> void:
	health_label.text = "Health: " + str(health)
	magic_points_label.text = "Magic points: " + str(magicPoints)

func on_button_focus_changed() -> void:
	Audio.btn_mov.play()
