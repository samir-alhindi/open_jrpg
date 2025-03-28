extends Node

@onready var battlers := $Battlers.get_children()
@onready var text_window: NinePatchRect = $TextWindow
@onready var text_label: Label = $TextWindow/Label
@onready var battle_music: AudioStreamPlayer = $BattleMusic

@export var battleData: BattleData
var battlersSortedSpeed: Array

const ALLY_BATTLER = preload("res://ally_battler/ally_battler.tscn")
const ENEMY_BATTLER = preload("res://enemy_battler/enemy_battler.tscn")

func _ready() -> void:
	# Load battle data:
	battleData = Global.battle
	# Load assets:
	$Background.texture = battleData.background
	$Background.scale = battleData.scale
	RenderingServer.set_default_clear_color(Color.BLACK)
	$Background.modulate.a = battleData.opacity
	battle_music.stream = battleData.battleMusic
	battle_music.play()
	# Load allies:
	load_battlers(battleData.allies, ALLY_BATTLER, $AllySpawnCircle)
	# Load enemies:
	load_battlers(battleData.enemies, ENEMY_BATTLER, $EnemySpawnCircle)
	SignalBus.display_text.connect(display_text)
	SignalBus.cursor_come_to_me.connect(on_cursor_come_to_me)
	SignalBus.battle_won.connect(on_battle_won)
	SignalBus.battle_lost.connect(on_battle_lost)
	ScreenFade.fade_into_game()
	rename_enemies()
	let_battlers_decide_actions()

func rename_enemies() -> void:
	# Dict to keep track of num of repeated enemies:
	var names: Dictionary = {}
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy: EnemyBattler in enemies:
		# Check if this enemy is repeated:
		if enemy.name_ in names:
			# It's repeated: Add a number to it's name
			enemy.name_ += " " + str(names[enemy.name_] + 1)
			var temp: String = enemy.name_
			var formated: String = temp.erase(len(temp) - 2, 2)
			# Increase the count of this repeated enemy
			names[formated] += 1
			# Special case where we rename the 1st duplicated enemy:
			if names[formated] == 2:
				# Find the enemy:
				for enemy_: EnemyBattler in enemies:
					if enemy_.name_ == formated:
						enemy_.name_ += " 1"
						break
		# 1st time seeing this enemy:
		else:
			names[enemy.name_] = 1
			enemy.name_ = enemy.name_ # Force label to update.

@warning_ignore("shadowed_variable")
func load_battlers(battlers: Array, battlerFile: PackedScene, circle: Marker2D) -> void:
	for i: int in range(len(battlers)):
		var allyScene: Battler = battlerFile.instantiate()
		allyScene.stats = battlers[i]
		$Battlers.add_child(allyScene)
		var all: int = battlers.size()
		@warning_ignore("integer_division")
		var calc: float = 360 / all
		circle.rotation_degrees = calc * i
		# Spawn Battler in the middle if there's only 1:
		if battlers.size() == 1:
			allyScene.global_position = circle.global_position
		else:
			allyScene.global_position = circle.get_node("SpawnPoint").global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and text_window.visible:
		text_window.hide()
		SignalBus.text_window_closed.emit()

func let_battlers_decide_actions() -> void:
	for battler: Battler in battlers:
		if battler.isDefeated: continue
		battler.set_process(true)
		battler.decide_action()
		await battler.deciding_finished
		battler.set_process(false)
	battlersSortedSpeed.clear()
	battlersSortedSpeed = battlers.duplicate()
	battlersSortedSpeed.sort_custom(sort_battlers_by_speed)
	let_battlers_perform_action()

func sort_battlers_by_speed(a: Battler, b: Battler) -> bool:
	if a.speed > b.speed:
		return true
	return false

func let_battlers_perform_action() -> void:
	for battler: Battler in battlersSortedSpeed:
		if battler.isDefeated: continue
		battler.set_process(true)
		battler.perform_action()
		await battler.performing_action_finished
		battler.set_process(false)
	free_defeated_battlers()
	await get_tree().create_timer(0.01).timeout # Wait till all are freed.
	let_battlers_decide_actions()

func free_defeated_battlers() -> void:
	for battler: Battler in battlers:
		if battler.isDefeated:
			battler.remove_from_group("enemies")
			battler.remove_from_group("allies")
			battler.reparent(self)
			battler.anim.play("fade_out")
	await get_tree().create_timer(0.01).timeout #Wait till all are freed.
	battlers.clear()
	battlers = $Battlers.get_children()

func display_text(text: String) -> void:
	text_window.show()
	text_label.text = text

func on_cursor_come_to_me(my_position: Vector2, is_ally: bool) -> void:
	var offset: Vector2
	if is_ally:
		$Cursor/AnimationPlayer.play("point_at_ally")
		offset = Vector2(-32, 32)
	else:
		$Cursor/AnimationPlayer.play("point_at_enemy")
		offset = Vector2(32, 32)
	var finalValue: Vector2 = my_position + offset
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Cursor, "global_position", finalValue, 0.1)

func on_battle_won() -> void:
	$Cursor/AnimationPlayer.play("fade")
	SignalBus.display_text.emit("Battle won !")
	battle_music.playing = false
	Audio.won.play()
	await SignalBus.text_window_closed
	ScreenFade.fade_into_black()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("uid://0xc8hpp1566k")

func on_battle_lost() -> void:
	$Cursor/AnimationPlayer.play("fade")
	SignalBus.display_text.emit("Battle lost...")
	Audio.lost.play()
	await SignalBus.text_window_closed
	ScreenFade.fade_into_black()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("uid://0xc8hpp1566k")
