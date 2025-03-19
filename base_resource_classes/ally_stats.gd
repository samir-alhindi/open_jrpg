@tool
class_name AllyStats extends Resource

@export_category("Main traits")
## The battler's display name in battle.
@export var name: String
## The UI theme for the battler:
@export var ui_theme: Theme
## How much will the texture will be up/down scalled ?
@export var texture_scale: float = 1.0
## Can this battler use magical abilities ? (allies only).
@export var can_use_magic: bool = true

@export_category("Actions")
## The attacks that the battler can perform.
@export var attackActions: Array[AllyAttackAction]
## The battler's defend action.
@export var defendAction: AllyDefendAction = load("uid://dtv4tf41ul5p")
## The magic actions of the batller.
@export var magicActions: Array[AllyMagicAction]
## The items in the battler's inventory.
@export var items: Array[AllyItemAction]

@export_category("Numbers")
## Battler is defeated when it reaches zero.
@export_range(1, 99999999) var health: int = 120
## Used to cast magical abilities.
@export_range(0, 1000) var magicPoints: int = 20
## Strength is in negative because it makes calculations easier 
@export_range(1, 99999999) var strength: int = -50 
## Lets you take less damage from attacks.
@export_range(0, 100) var defense: int = 10
## Magic strength is in negative because it makes calculations easier 
@export_range(1, 99999999) var magicStrength: int = -10
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
	spriteFramesInstance.add_animation("heal_magic")
	spriteFramesInstance.add_animation("offensive_magic")
	for animation: String in spriteFramesInstance.get_animation_names():
		spriteFramesInstance.set_animation_loop(animation, false)
		spriteFramesInstance.set_animation_speed(animation, 8.0)
	spriteFramesInstance.add_animation("idle")
	return spriteFramesInstance

@export_category("Sprites")
@export var createTemplate: bool = false:
	set(value):
		spriteFrames = create_sprite_frames()

@export var spriteFrames: SpriteFrames
