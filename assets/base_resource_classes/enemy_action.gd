class_name EnemyAction extends Resource

@export_category("Main traits")
## How often the enemy battlers will perform this action.
@export_range(0.0, 1.0, 0.05) var enemyActionChance = 1.0
## The text that will be displayed right before the action is performed.
@export_multiline var actionText: String
## The SFX that will play right before the action is used.
@export var sound: AudioStream
