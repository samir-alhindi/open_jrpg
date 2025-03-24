class_name StatusEffect extends Resource

@export_category("Status effect data")
## Name of the status effect.
@export var name_: String = "Status effect name here"
## The number of turns until the status effect disappears.
@export_range(1, 999) var effectDuration: int = 2
## SFX for the status effect:
@export var sound: AudioStream
## Sprite that signifies inflection.
@export var sprite: Texture
