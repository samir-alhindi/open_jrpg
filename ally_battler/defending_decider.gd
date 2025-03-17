extends Node

@export var parent: Battler

var isDefending: bool = false

func _on_defend_button_pressed() -> void:
	Audio.btn_mov.play()
	isDefending = true
	parent.actionToPerform = parent.defendAction
	parent.targetBattlers.append(parent)
	parent.button_container.hide()
	parent.deciding_finished.emit()

func manage_defense_stat() -> void:
	if isDefending:
		parent.defense -= parent.defendAction.defenseAmount
		isDefending = false
