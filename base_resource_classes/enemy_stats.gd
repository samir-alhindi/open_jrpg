@tool
class_name EnemyStats extends Resource

@export_category("Main traits")
## The battler's display name in battle.
@export var name: String
## How much will the texture will be up/down scalled ?
@export var texture_scale: float = 1.0

@export_category("Actions")
## The attacks that the battler can perform.
@export var actions: Array[EnemyAction]

@export_category("Numbers")
## Battler is defeated when it reaches zero.
@export_range(0, 5000) var health: int = 120
## Added to the attack action's strength.
@export_range(1, 99999999) var strength: int = 50
## Lets you take less damage from attacks.
@export_range(0, 100) var defense: int = 10
## Added to magic action's strength.
@export_range(1, 99999999) var magicStrength: int = 10
## The battler with the highest speed acts first.
@export_range(0, 50) var speed: int = 10

@export_category("Text")
## This text will appear when your battler is knocked out.
@export_multiline var defeatedText: String

func create_sprite_frames() -> SpriteFrames:
	var spriteFramesInstance: SpriteFrames = SpriteFrames.new()
	spriteFramesInstance.remove_animation("default")
	spriteFramesInstance.add_animation("attack")
	spriteFramesInstance.add_animation("hurt")
	spriteFramesInstance.add_animation("defend")
	spriteFramesInstance.add_animation("defeated")
	for animation: String in spriteFramesInstance.get_animation_names():
		spriteFramesInstance.set_animation_loop(animation, false)
	spriteFramesInstance.add_animation("idle")
	return spriteFramesInstance

@export_category("Sprites")
@export var createTemplate: bool = false:
	set(value):
		spriteFrames = create_sprite_frames()

@export var spriteFrames: SpriteFrames
