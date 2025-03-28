## Class for all the ally battlers (party member).
##
## This class takes an [AllyStats] resource that contains all of the ally's data, 
## If you're trying to create an ally then create an [AllyStats] resoruce and then fill
##  in everything and finaly add it into a battle [BattleData] resource.

class_name AllyBattler extends Battler

## Parent of UI buttons and selection windows.
@onready var control: Control = %Control
## Menu where action names and battler names appear when selecting.
@onready var selection_window: NinePatchRect = $UI/Control/SelectionWindow
## [VBoxContainer] that contains [Label]s with battler/action names.
@onready var options_container: VBoxContainer = $UI/Control/SelectionWindow/OptionsContainer
## [HBoxContainer] that contains all the UI buttons (attack button, defend button, ect...).
@onready var button_container: HBoxContainer = %ButtonContainer
## Displays list of possible attacks when clicked.
@onready var attack_button: Button = %AttackButton
## Displays list of possible spells when clicked.
@onready var magic_button: Button = %MagicButton
## Displays list of avalible items when clicked.
@onready var item_button: Button = %ItemButton
## handles the defense stat.
@onready var defending_manager: Node = $DefendingDecider_Manager
## Ally's health bar.
@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar
## Ally's magic points bar.
@onready var magic_bar: ProgressBar = $VBoxContainer/MagicBar
## [AnimatedSprite2D] that displays all Ally animations.
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
## Displays the Ally's health.
@onready var health_label: Label = %HealthLabel
## Displays the Ally's MP (magic points).
@onready var magic_points_label: Label = %MagicPointsLabel
## Most important variable, 
## contains actions, sprites, UI theme, ect...
@export var stats: AllyStats

## Ally dies when it reaches zero.
@onready var health: int = stats.health:
	set(value):
		if value >= max_health:
			health = max_health
		else:
			health = value
		health_label.text = "Health: " + str(health)
		health_bar.value = health
## Required for casting magic spells.
@onready var magicPoints: int = stats.magicPoints:
	set(value):
		magicPoints = value
		magic_points_label.text = "Magic points: " + str(magicPoints)
		magic_bar.value = value
## Ally's health can't exceed this.
@onready var max_health: int = stats.health
## How much physical damage the Ally can do.
@onready var strength: int = stats.strength
## How potent this Ally's spells are.
@onready var magicStrength: int = stats.magicStrength
## Reduces damage from enemies.
@onready var defense: int = stats.defense
## The battler with the highest speed gets to act first.
@onready var speed: int = stats.speed
## Display name for the Ally in battle.
@onready var name_: String = stats.name
## Gets displayed when this Ally dies.
@onready var defeatedText: String = stats.defeatedText

## All the possible attacks this Ally can perform.
@onready var attackActions: Array[Attack] = stats.attackActions
## This action is performed when the Ally defends.
@onready var defendAction: Defend = stats.defendAction
## All spells that this Ally can use.
@onready var magicActions: Array[Spell] = stats.magicActions
## All items in this Ally's inventory.
@onready var items: Array[Item] = stats.items.duplicate()

## The [AllyAction] that this Ally will do when it can act.
var actionToPerform: AllyAction
## All the [Battler]s ([AllyBattler]s, [EnemyBattler]s) that this Ally's next action will target.
var targetBattlers: Array[Battler]

func _ready() -> void:
	check_abstract_classes()
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
	animated_sprite_2d.offset += stats.offset
	#init other stuff:
	opponents = "enemies"

## This method checks if the user has accidentally put an abstract class resource
## into one of the [AllyAction] lists.
func check_abstract_classes() -> void:
	# check all the spell actions:
	for action: AllyAction in magicActions:
		# Do nothing if it's one of the normal inetended child classes:
		if action is HealingSpell or action is OffensiveSpell or action is CurseSpell:
			pass
		# This is an abstract class; Throw error:
		else:
			@warning_ignore("shadowed_variable")
			var name_ := action.actionName
			var class_ = action.get_script().get_global_name()
			var path_ := action.resource_path
			var error := "The action \"%s\" at: \"%s\" is an instance of the abstract class \"%s\"."
			error += "\nMake the action inherit \"OffensiveSpell\" or \"HealingSpell\" or \"CurseSpell\"."
			var formated := error % [name_, path_, class_]
			assert(false, formated)

## Allows player to choose an [AllyAction] ([Attack], [Defend], [Item], ect...)
## that this [AllyBattler] will perform.
func decide_action() -> void:
	SignalBus.cursor_come_to_me.emit(self.global_position, true)
	if items.size() <= 0:
		item_button.hide()
	defending_manager.manage_defense_stat()
	targetBattlers.clear()
	button_container.show()
	await get_tree().create_timer(0.5).timeout
	attack_button.grab_focus()

## Lets the [AllyBattler] perform the [AllyAction] that they chose in
## [method AllyBattler.decide_action]
func perform_action() -> void:
	SignalBus.cursor_come_to_me.emit(self.global_position, true)
	SignalBus.display_text.emit(name_+" "+actionToPerform.actionText)
	#play action sound:
	Audio.action.stream = actionToPerform.sound
	Audio.action.play()
	await SignalBus.text_window_closed
	#region Dead battlers:
	for battler: Battler in targetBattlers:
		# Check if we're targeting a dead battler:
		if battler.isDefeated:
			# Change the battler to another battler if the current one is dead:
			var targetGroup: String
			if battler is EnemyBattler:
				targetGroup = "enemies"
			elif battler is AllyBattler:
				targetGroup = "allies"
			# Change target to another battler:
			if targetBattlers.size() == 1:
				var battlers: Array[Battler]
				battlers.assign(get_tree().get_nodes_in_group(targetGroup))
				var index: int = battlers.find(battler)
				index += 1
				index %= battlers.size()
				while battlers[index].isDefeated:
					index += 1
					index %= battlers.size()
				battler = battlers[index]
			# Ignore the dead battlers in group actions:
			elif targetBattlers.size() > 1:
				continue
	#endregion
		# check action type:
		#region Attack action:
		if actionToPerform is Attack:
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
				# Check if allies won:
				if check_if_we_won() == true:
					SignalBus.battle_won.emit()
					return
				#endregion
		#region Defend action:
		elif actionToPerform is Defend:
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
		elif actionToPerform is Spell:
			if actionToPerform is OffensiveSpell:
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
					# Check if allies won:
					if check_if_we_won() == true:
						SignalBus.battle_won.emit()
						return
			elif actionToPerform is HealingSpell:
				# Play aniamtion:
				play_anim("heal_magic")
				# Calculate actual damage amount:
				var healingAmount: int
				@warning_ignore("integer_division")
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
			
			elif actionToPerform is CurseSpell:
				var effect: StatusEffect = actionToPerform.statusEffect
				# Play aniamtion:
				play_anim("offensive_magic")
				
				# Disabling status effect (sleep, paralysis, ect...):
				if effect is StatusEffect:
					# Check if target is already inflected with a disabling status effect:
					if battler.disablingStatusEffect != null:
						@warning_ignore("confusable_local_declaration")
						var text: String = battler.name_ + " already can't act !"
						SignalBus.display_text.emit(text)
						await SignalBus.text_window_closed
						# Wait a moment:
						await get_tree().create_timer(0.1).timeout
						continue
					# Inflect the status effect:
					battler.disablingStatusEffect = effect.duplicate()
					battler.isDisabled = true
					battler.status_effect_sprite.texture = effect.sprite
					battler.status_effect_sprite.scale = Vector2(1, 1)
					battler.status_effect_sprite.scale *= effect.scale
				# Display text:
				var text: String = battler.name_ + " has been inflicted with " + effect.name_ + " !"
				SignalBus.display_text.emit(text)
				# Play SFX of target battler getting cursed:
				Audio.play_action_sound("cursed")
				# Play target battler curse animation:
				battler.play_anim("cursed")
				# Wait until player closes text window:
				await SignalBus.text_window_closed
				# Wait a moment:
				await get_tree().create_timer(0.1).timeout
			#endregion
			
		elif actionToPerform is Item:
			if actionToPerform is Item:
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

## Method that calculates damage done to [EnemyBattler]s by performing
## [Attack]s and [OffensiveSpell]s.
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

## Updates health and magic points labels.
func _process(_delta: float) -> void:
	health_label.text = "Health: " + str(health)
	magic_points_label.text = "Magic points: " + str(magicPoints)

## Plays a UI sound.
func on_button_focus_changed() -> void:
	Audio.btn_mov.play()
