extends Node

@onready var battlers := $Battlers.get_children()
@onready var text_window: NinePatchRect = $TextWindow
@onready var text_label: Label = $TextWindow/Label
@onready var battle_music: AudioStreamPlayer = $BattleMusic
## Display name for the battle in the main menu.
@export var battleName: String
var battlersSortedSpeed: Array

func _ready() -> void:
	SignalBus.display_text.connect(display_text)
	ScreenFade.fade_into_game()
	let_battlers_decide_actions()

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
