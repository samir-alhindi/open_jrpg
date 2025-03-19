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
	battle_music.stream = battleData.battleMusic
	battle_music.play()
	# Load allies:
	load_battlers(battleData.allies, ALLY_BATTLER, $AllySpawnCircle)
	# Load enemies:
	load_battlers(battleData.enemies, ENEMY_BATTLER, $EnemySpawnCircle)
	SignalBus.display_text.connect(display_text)
	ScreenFade.fade_into_game()
	let_battlers_decide_actions()

func load_battlers(battlers: Array, battlerFile: PackedScene, circle: Marker2D) -> void:
	for i: int in range(len(battlers)):
		var allyScene: Battler = battlerFile.instantiate()
		allyScene.stats = battlers[i]
		$Battlers.add_child(allyScene)
		var all: int = battlers.size()
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
	if check_if_allies_won(): battle_won()
	elif check_if_enemies_won():battle_lost()
	else: let_battlers_decide_actions()

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

func check_if_allies_won() -> bool:
	if get_tree().get_nodes_in_group("enemies").size() <= 0:
		return true
	return false

func check_if_enemies_won() -> bool:
	if get_tree().get_nodes_in_group("allies").size() <= 0:
		return true
	return false

func battle_won() -> void:
	SignalBus.display_text.emit("Battle won !")
	battle_music.playing = false
	Audio.won.play()
	await SignalBus.text_window_closed
	ScreenFade.fade_into_black()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("uid://0xc8hpp1566k")

func battle_lost() -> void:
	SignalBus.display_text.emit("Battle lost...")
	Audio.lost.play()
	await SignalBus.text_window_closed
	ScreenFade.fade_into_black()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("uid://0xc8hpp1566k")
