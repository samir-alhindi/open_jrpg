class_name EnemyAction extends Resource

enum ActionTargetType {
	SINGLE_ALLY, ## This action targets 1 singular ally battler in this battle.
	SINGLE_ENEMY, ## This action targets 1 singular enemy battler in this battle.
	ALL_ENEMIES, ## This action targets all the enemy battlers in this battle.
	ALL_ALLIES, ## This action targets all the ally battlers in this battle.
	} 

@export_category("Main traits")
## Which battler(s) type this action will target.
@export var actionTargetType: ActionTargetType
## Which variable in the target battler script will this action change ?
@export_enum(
"health",
"defense",
) var targetBattlerVariable: String = "health"
## Which variable in the script of the battler
## performing the action will enhance this action's effect.
@export_enum(
	"strength",
	"magicStrength",
	"none"
) var actionPerformerEnhancerVariable: String = "strength"
## Which variable in the script of the target battler
## will make the effect of this action less severe ?
@export_enum(
	"none",
	"defense",
) var targetBattlerEnhancerVariable: String  = "none"

@export_category("Numbers")
## The amount the action will do.
@export_range(-1000, 1000, 5) var amount: int = 0
## How often the enemy battlers will perform this action.
@export_range(0.0, 1.0, 0.05) var enemyActionChance

@export_category("Text")
## Which type of dialouge will appear after the action is finished
@export_enum(
	"took damage",
	"defend self",
	"heal"
) var actionAftermathTextType: String = "took damage"
## The text that will be displayed right before the action is performed.
@export_multiline var actionText: String

@export_category("Sound and Animation")
## The SFX that will play right before the action is used.
@export var sound: AudioStream
## The types of animation and SFX that the target battler will play after the action is performed.
@export_enum(
	"hurt",
	"heal",
	"defend",
) var animation_and_sound: String = "hurt"
