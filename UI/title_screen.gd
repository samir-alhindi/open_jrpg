extends CanvasLayer

var battles: Array[BattleData] 
@onready var ui_box: NinePatchRect = $UIBox
@onready var label_container: VBoxContainer = $UIBox/LabelContainer

var index: int = 0:
	set(val):
		if val < 0 or val >= battles.size(): return
		var labelToUnfocus: Label = label_container.get_child(index)
		labelToUnfocus.modulate.a = 0.5
		index = val
		var labelToFocus: Label = label_container.get_child(index)
		labelToFocus.modulate.a = 1
var isSelecting: bool = false

func _ready() -> void:
	ScreenFade.fade_into_game()
	$VBoxContainer/ViewBattlesButton.grab_focus()
	
	# Load battles from disk:
	var battlePaths: PackedStringArray = DirAccess.get_files_at("res://battle_data/")
	for battlePath: String in battlePaths:
		if battlePath.ends_with(".remap"):
			battlePath = battlePath.replace(".remap", "")
		var battle: BattleData = load("res://battle_data/" + battlePath)
		battles.append(battle)
	
	#Creating labels for the battles:
	for battle: BattleData in battles:
		var label: Label = Label.new()
		label.text = battle.battleName
		label.modulate.a = 0.5
		label_container.add_child(label)
	#Begin selecting battle:
	index = 0

func _input(event: InputEvent) -> void:
	if isSelecting:
		if event.is_action_pressed("ui_down"):
			index += 1
		elif event.is_action_pressed("ui_up"):
			index -= 1
		elif event.is_action_pressed("ui_accept"):
			ScreenFade.fade_into_black()
			await get_tree().create_timer(0.5).timeout
			Global.battle = battles[index]
			get_tree().change_scene_to_file("uid://p86u62q8dtxq")

func _on_view_battles_button_pressed() -> void:
	ui_box.show()
	isSelecting = true
	$VBoxContainer/ViewBattlesButton.release_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
