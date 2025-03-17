extends Node

@export var parent: AllyBattler

var currentGroup: String
var actionIndex: int:
	set(value):
		if value < 0 or value >= parent.magicActions.size(): return
		Audio.btn_mov.play()
		var labelToUnfocus: Label = parent.options_container.get_child(actionIndex)
		labelToUnfocus.modulate.a = 0.5
		actionIndex = value
		var labelToFocus: Label = parent.options_container.get_child(actionIndex)
		labelToFocus.modulate.a = 1
var battlerIndex: int:
	set(value):
		if value < 0 or value >= get_tree().get_nodes_in_group(currentGroup).size(): return
		Audio.btn_mov.play()
		var labelToUnfocus: Label = parent.options_container.get_child(battlerIndex)
		if labelToUnfocus: labelToUnfocus.modulate.a = 0.5
		battlerIndex = value
		var labelToFocus: Label = parent.options_container.get_child(battlerIndex)
		labelToFocus.modulate.a = 1

#Selection states:
enum {NOT_SELECTING, SELECTING_ACTION, SELECTING_ENEMIES}
var currentSelectionType = NOT_SELECTING
var isSelecting: bool = false

func clear_labels():
	for label: Label in parent.options_container.get_children():
		if label: label.queue_free()

func _on_magic_button_pressed() -> void:
	clear_labels()
	#Wait until all labels are freed:
	await get_tree().create_timer(0.1).timeout
	#Populate the selection window with magic actions:
	parent.selection_window.show()
	parent.button_container.hide()
	for magicAction: AllyAction in parent.magicActions:
		var label: Label = Label.new()
		label.text = magicAction.actionName
		label.modulate.a = 0.5
		parent.options_container.add_child(label)
	#Begin selection:
	actionIndex = 0
	isSelecting = true
	currentSelectionType = SELECTING_ACTION

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") and isSelecting:
		if currentSelectionType == SELECTING_ACTION: actionIndex += 1
		if currentSelectionType == SELECTING_ENEMIES: battlerIndex += 1
	if event.is_action_pressed("ui_up") and isSelecting:
		if currentSelectionType == SELECTING_ACTION: actionIndex -= 1
		if currentSelectionType == SELECTING_ENEMIES: battlerIndex -= 1
	if event.is_action_pressed("ui_accept") and isSelecting:
		match currentSelectionType:
			SELECTING_ACTION:
				if !has_enough_magic_points(): not_enough_magic_points(); return
				var action: AllyMagicAction = parent.magicActions[actionIndex]
				parent.actionToPerform = action
				currentSelectionType = SELECTING_ENEMIES
				if action is AllyOffensiveMagicAction:
					if action.actionTargetType == AllyOffensiveMagicAction.ActionTargetType.SINGLE_ENEMY:
						start_selecting_single_enemy()
					elif action.actionTargetType == AllyOffensiveMagicAction.ActionTargetType.ALL_ENEMIES:
						select_all_enemies_and_finish()
			SELECTING_ENEMIES:
				finish_selecting()
	if event.is_action_pressed("ui_cancel") and isSelecting:
		cancel_action()

func has_enough_magic_points() -> bool:
	if parent.magicPoints < parent.magicActions[actionIndex].magicPointsCost:
		return false
	return true

func cancel_action() -> void:
	isSelecting = false
	currentSelectionType = null
	parent.selection_window.hide()
	parent.button_container.show()
	await get_tree().create_timer(0.1).timeout
	parent.magic_button.grab_focus()

func not_enough_magic_points() -> void:
	isSelecting = false
	currentSelectionType = null
	parent.selection_window.hide()
	parent.button_container.hide()
	await get_tree().create_timer(0.1).timeout
	SignalBus.display_text.emit("Not enough magic points !")
	await SignalBus.text_window_closed
	parent.button_container.show()
	await get_tree().create_timer(0.1).timeout
	parent.magic_button.grab_focus()

func start_selecting_single_enemy():
	clear_labels()
	#Wait until all labels are freed:
	await get_tree().create_timer(0.1).timeout
	for enemyBattler: EnemyBattler in get_tree().get_nodes_in_group("enemies"):
		var label: Label = Label.new()
		label.text = enemyBattler.stats.name
		label.modulate.a = 0.5
		parent.options_container.add_child(label)
	battlerIndex = 0

func select_all_enemies_and_finish() -> void:
	parent.magicPoints -= parent.magicActions[actionIndex].magicPointsCost
	for battler: Battler in get_tree().get_nodes_in_group("enemies"):
		parent.targetBattlers.append(battler)
	isSelecting = false
	currentSelectionType = NOT_SELECTING
	parent.selection_window.hide()
	parent.deciding_finished.emit()

func finish_selecting():
	parent.magicPoints -= parent.magicActions[actionIndex].magicPointsCost
	parent.targetBattlers.append(get_tree().get_nodes_in_group("enemies")[battlerIndex])
	isSelecting = false
	currentSelectionType = NOT_SELECTING
	parent.selection_window.hide()
	parent.deciding_finished.emit()
