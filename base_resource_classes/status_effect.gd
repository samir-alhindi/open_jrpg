## Class for status effects that disable enemies from performing any actions.
##
## A status effect disables an enemy for a set amount of turns and then gets cured automatically.

class_name StatusEffect extends Resource

@export_category("Main data")
## Name of the status effect.
@export var name_: String = "Status effect name here"
## The number of turns until the status effect disappears.
@export_range(1, 999) var effectDuration: int = 2

@export_category("Audio and Sprite")
## SFX for the status effect:
@export var sound: AudioStream
## Sprite that signifies inflection (appears above battler's heads).
@export var sprite: Texture
## The scale of the sprite.
@export var scale: float = 1

@export_category("Text")
## Text to display when status effect takes places:
@export var text: String = "Is under a status effect !"
## Text to display when status effect is removed:
@export var removalText: String = "The status effect disappeared !"
