class_name AllyAction extends Resource


@export_category("Text")
## The text that will be displayed right before the action is performed.
@export_multiline var actionText: String = "You performed an action !"
## Name of the action displayed when picking an action.
@export var actionName: String = "action_name"

@export_category("Sound")
## The SFX that will play right before the action is used.
@export var sound: AudioStream
