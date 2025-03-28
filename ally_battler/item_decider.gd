extends Node

@export var parent: AllyBattler

#Selection states:
enum {NOT_SELECTING, SELECTING_ITEM, SELECTING_ALLY}
var currentSelectionType = NOT_SELECTING
var isSelecting: bool = false

var itemIndex: int:
	set(value):
		if value < 0 or value >= parent.items.size(): return
		Audio.btn_mov.play()
		var labelToUnfocus: Label = parent.options_container.get_child(itemIndex)
		if labelToUnfocus: labelToUnfocus.modulate.a = 0.5
		itemIndex = value
		var labelToFocus: Label = parent.options_container.get_child(itemIndex)
		labelToFocus.modulate.a = 1
var allyIndex: int:
	set(value):
		if value < 0 or value >= get_tree().get_nodes_in_group("allies").size(): return
		Audio.btn_mov.play()
		var labelToUnfocus: Label = parent.options_container.get_child(allyIndex)
		if labelToUnfocus: labelToUnfocus.modulate.a = 0.5
		allyIndex = value
		var labelToFocus: Label = parent.options_container.get_child(allyIndex)
		labelToFocus.modulate.a = 1

func _on_item_button_pressed() -> void:
	parent.button_container.hide()
	if parent.items.size() == 0:
		SignalBus.display_text.emit("No items left !")
		await SignalBus.text_window_closed
		await get_tree().create_timer(0.1).timeout
		parent.button_container.show()
		parent.item_button.grab_focus()
		return
	clear_labels()
	#Wait until all labels are freed:
	await get_tree().create_timer(0.1).timeout
	#Populate the selection window with item actions:
	parent.selection_window.show()
	for item: AllyAction in parent.items:
		var label: Label = Label.new()
		label.text = item.actionName
		label.modulate.a = 0.5
		parent.options_container.add_child(label)
	#Begin selection:
	itemIndex = 0
	isSelecting = true
	currentSelectionType = SELECTING_ITEM

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down") and isSelecting:
		if currentSelectionType == SELECTING_ITEM: itemIndex += 1
		if currentSelectionType == SELECTING_ALLY: allyIndex += 1
	if event.is_action_pressed("ui_up") and isSelecting:
		if currentSelectionType == SELECTING_ITEM: itemIndex -= 1
		if currentSelectionType == SELECTING_ALLY: allyIndex -= 1
	if event.is_action_pressed("ui_accept") and isSelecting:
		match currentSelectionType:
			SELECTING_ITEM:
				parent.actionToPerform = parent.items[itemIndex]
				currentSelectionType = SELECTING_ALLY
				match parent.items[itemIndex].actionTargetType:
					Item.ActionTargetType.ALL_ALLIES: select_all_allies_and_finish()
					Item.ActionTargetType.SINGLE_ALLY: start_selecting_single_ally()
			SELECTING_ALLY:
				finish_selecting()
	if event.is_action_pressed("ui_cancel") and isSelecting:
		cancel_action()

func start_selecting_single_ally() -> void:
	clear_labels()
	#Wait until all labels are freed:
	await get_tree().create_timer(0.1).timeout
	for allyBattler: AllyBattler in get_tree().get_nodes_in_group("allies"):
		var label: Label = Label.new()
		label.text = allyBattler.stats.name
		label.modulate.a = 0.5
		parent.options_container.add_child(label)
	allyIndex = 0

func select_all_allies_and_finish() -> void:
	parent.items.remove_at(itemIndex)
	for battler: Battler in get_tree().get_nodes_in_group("allies"):
		parent.targetBattlers.append(battler)
	isSelecting = false
	currentSelectionType = NOT_SELECTING
	parent.selection_window.hide()
	parent.deciding_finished.emit()

func clear_labels() -> void:
	for label: Label in parent.options_container.get_children():
		if label: label.queue_free()

func cancel_action() -> void:
	isSelecting = false
	currentSelectionType = null
	parent.selection_window.hide()
	parent.button_container.show()
	await get_tree().create_timer(0.1).timeout
	parent.item_button.grab_focus()

func finish_selecting():
	parent.items.remove_at(itemIndex)
	parent.targetBattlers.append(get_tree().get_nodes_in_group("allies")[allyIndex])
	isSelecting = false
	currentSelectionType = NOT_SELECTING
	parent.selection_window.hide()
	parent.deciding_finished.emit()
