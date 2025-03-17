extends Node

@export var parent: AllyBattler

var actionIndex: int:
	set(value):
		if value < 0 or value >= parent.attackActions.size(): return
		Audio.btn_mov.play()
		var labelToUnfocus: Label = parent.options_container.get_child(actionIndex)
		labelToUnfocus.modulate.a = 0.5
		actionIndex = value
		var labelToFocus: Label = parent.options_container.get_child(actionIndex)
		labelToFocus.modulate.a = 1
var enemyIndex: int:
	set(value):
		if value < 0 or value >= get_tree().get_nodes_in_group("enemies").size(): return
		Audio.btn_mov.play()
		var labelToUnfocus: Label = parent.options_container.get_child(enemyIndex)
		if labelToUnfocus: labelToUnfocus.modulate.a = 0.5
		enemyIndex = value
		var labelToFocus: Label = parent.options_container.get_child(enemyIndex)
		labelToFocus.modulate.a = 1

#Selection states:
enum {NOT_SELECTING, SELECTING_ATTACK, SELECTING_ENEMIES}
var currentSelectionType = NOT_SELECTING
var isSelecting: bool = false

func clear_labels():
	for label: Label in parent.options_container.get_children():
		if label: label.queue_free()

func _on_attack_button_pressed() -> void:
	clear_labels()
	#Wait until all labels are freed:
	await get_tree().create_timer(0.1).timeout
	#Populate the selection window with attacks:
	parent.selection_window.show()
	parent.button_container.hide()
	for attackingAction: AllyAction in parent.attackActions:
		var label: Label = Label.new()
		label.text = attackingAction.actionName
		label.modulate.a = 0.5
		parent.options_container.add_child(label)
	#Begin selection:
	actionIndex = 0
	isSelecting = true
	currentSelectionType = SELECTING_ATTACK

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") and isSelecting:
		if currentSelectionType == SELECTING_ATTACK: actionIndex += 1
		if currentSelectionType == SELECTING_ENEMIES: enemyIndex += 1
	if event.is_action_pressed("ui_up") and isSelecting:
		if currentSelectionType == SELECTING_ATTACK: actionIndex -= 1
		if currentSelectionType == SELECTING_ENEMIES: enemyIndex -= 1
	if event.is_action_pressed("ui_accept") and isSelecting:
		match currentSelectionType:
			SELECTING_ATTACK:
				parent.actionToPerform = parent.attackActions[actionIndex]
				currentSelectionType = SELECTING_ENEMIES
				match parent.attackActions[actionIndex].actionTargetType:
					AllyAttackAction.ActionTargetType.SINGLE_ENEMY: start_selecting_single_enemy()
					AllyAttackAction.ActionTargetType.ALL_ENEMIES: select_all_enemies_and_finish()
			SELECTING_ENEMIES:
				finish_selecting()
	if event.is_action_pressed("ui_cancel") and isSelecting:
		cancel_action()

func cancel_action() -> void:
	isSelecting = false
	currentSelectionType = null
	parent.selection_window.hide()
	parent.button_container.show()
	parent.attack_button.grab_focus()

func start_selecting_single_enemy():
	clear_labels()
	#Wait until all labels are freed:
	await get_tree().create_timer(0.1).timeout
	for enemyBattler: EnemyBattler in get_tree().get_nodes_in_group("enemies"):
		var label: Label = Label.new()
		label.text = enemyBattler.stats.name
		label.modulate.a = 0.5
		parent.options_container.add_child(label)
	enemyIndex = 0

func select_all_enemies_and_finish() -> void:
	for battler: Battler in get_tree().get_nodes_in_group("enemies"):
		parent.targetBattlers.append(battler)
	isSelecting = false
	currentSelectionType = NOT_SELECTING
	parent.selection_window.hide()
	parent.deciding_finished.emit()

func finish_selecting():
	parent.targetBattlers.append(get_tree().get_nodes_in_group("enemies")[enemyIndex])
	isSelecting = false
	currentSelectionType = NOT_SELECTING
	parent.selection_window.hide()
	parent.deciding_finished.emit()
