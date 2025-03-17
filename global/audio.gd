extends Node

@onready var btn_mov: AudioStreamPlayer = $BtnMov
@onready var btn_pressed: AudioStreamPlayer = $BtnPressed
@onready var action: AudioStreamPlayer = $Action
@onready var action_effect: AudioStreamPlayer = $ActionEffect
@onready var lost: AudioStreamPlayer = $Lost
@onready var down: AudioStreamPlayer = $Down
@onready var won: AudioStreamPlayer = $Won



var sound_types: Dictionary = {
	"hurt" : preload("res://assets/SFX/hurt.wav"),
	"heal" : preload("res://assets/SFX/heal.ogg"),
	"defend" : preload("res://assets/SFX/defend.wav")
}

func play_action_sound(actionType: StringName) -> void:
	action_effect.stream = sound_types[actionType]
	action_effect.play()
