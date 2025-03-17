extends CanvasLayer

@export var battles: Array[PackedScene]
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
	#Creating labels for the battles:
	for battle: PackedScene in battles:
		var label: Label = Label.new()
		var battleInstant = battle.instantiate()
		label.text = battleInstant.battleName
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
			get_tree().change_scene_to_packed(battles[index])

func _on_view_battles_button_pressed() -> void:
	ui_box.show()
	isSelecting = true
	$VBoxContainer/ViewBattlesButton.release_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
