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
	# Show UI:
	$UI.show()
	# Show battler name:
	$"%NameLabel".text = stats.name
	health_bar.max_value = self.health
	magic_bar.max_value = magicPoints
	health += 0; magicPoints += 0 # init the progress bars.
	control.theme = stats.ui_theme
	button_container.hide()
	animated_sprite_2d.scale *= stats.texture_scale
	animated_sprite_2d.flip_h = true
	animated_sprite_2d.offset.y -= 40
	if stats.can_use_magic == false:
		magic_button.queue_free()
		magic_bar.hide()
		magic_points_label.hide()
	# Load SpriteFrames:
	animated_sprite_2d.sprite_frames = stats.spriteFrames
	animated_sprite_2d.play("idle")

func decide_action() -> void:
	SignalBus.cursor_come_to_me.emit(self.global_position, true)
	if items.size() <= 0:
		item_button.hide()
	defending_manager.manage_defense_stat()
	targetBattlers.clear()
	button_container.show()
	await get_tree().create_timer(0.5).timeout
	attack_button.grab_focus()

func perform_action() -> void:
	SignalBus.cursor_come_to_me.emit(self.global_position, true)
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
			# Play attack animation:
			play_anim("attack")
			damage_actions(battler, false)
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
			# Play defending animation:
			play_anim("defend")
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
		#region Magic action:
		elif actionToPerform is AllyMagicAction:
			if actionToPerform is AllyOffensiveMagicAction:
				# Play animation:
				play_anim("offensive_magic")
				damage_actions(battler, true)
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
			elif actionToPerform is AllyHealingMagicAction:
				# Play aniamtion:
				play_anim("heal_magic")
				# Calculate actual damage amount:
				var healingAmount: int
				healingAmount = (actionToPerform.healingAmount + magicStrength / 2)
				# heal the target ally battler:
				battler.health += healingAmount
				# Display text:
				var text: String = battler.name_ + " recovered " + str(healingAmount) + " !"
				SignalBus.display_text.emit(text)
				# Play SFX of target battler getting healed:
				Audio.play_action_sound("heal")
				# Play target battler heal animation:
				battler.play_anim("heal")
				# Wait until player closes text window:
				await SignalBus.text_window_closed
				# Wait a moment:
				await get_tree().create_timer(0.1).timeout
			
			elif actionToPerform is AllyCurseMagicAction:
				var effect: StatusEffect = actionToPerform.statusEffect
				# Play aniamtion:
				play_anim("offensive_magic")
				# heal the target ally battler:
				battler.statusEffects.append(effect)
				# Display text:
				var text: String = battler.name_ + " has been inflicted with " + effect.name_ + " !"
				SignalBus.display_text.emit(text)
				# Play SFX of target battler getting healed:
				Audio.play_action_sound("cursed")
				# Play target battler curse animation:
				battler.play_anim("cursed")
				# Wait until player closes text window:
				await SignalBus.text_window_closed
				# Wait a moment:
				await get_tree().create_timer(0.1).timeout
			#endregion
			
		elif actionToPerform is AllyItemAction:
			if actionToPerform is AllyHealingItemAction:
				# heal the target ally battler:
				battler.health += actionToPerform.healthAmount
				# Display text:
				var text: String = battler.name_ + " recovered " + str(actionToPerform.healthAmount) + " !"
				SignalBus.display_text.emit(text)
				# Play SFX of target battler getting healed:
				Audio.play_action_sound("heal")
				# Play target battler heal animation:
				battler.play_anim("heal")
				# Wait until player closes text window:
				await SignalBus.text_window_closed
				# Wait a moment:
				await get_tree().create_timer(0.1).timeout
	# Clear target battlers array:
	targetBattlers.clear()
	# Signal to the battle node that we're done:
	performing_action_finished.emit()

func damage_actions(battler: Battler, isMagic: bool) -> void:
			# Calculate actual damage amount:
			var damage: int
			if not isMagic:
				damage = (actionToPerform.damageAmount + strength)
			elif isMagic:
				damage = (actionToPerform.damageAmount + magicStrength)
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
			battler.play_anim("hurt")

#For Displaying stats:
@onready var health_label: Label = %HealthLabel
@onready var magic_points_label: Label = %MagicPointsLabel
func _process(_delta: float) -> void:
	health_label.text = "Health: " + str(health)
	magic_points_label.text = "Magic points: " + str(magicPoints)

func on_button_focus_changed() -> void:
	Audio.btn_mov.play()
