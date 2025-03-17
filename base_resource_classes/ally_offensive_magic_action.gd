class_name AllyOffensiveMagicAction extends AllyMagicAction

@export_category("Magic attack data")
enum ActionTargetType {
	SINGLE_ENEMY, ## This action targets 1 singular enemy battler in this battle.
	ALL_ENEMIES, ## This action targets all the enemy battlers in this battle.
	}
## The number of enemies this magic attack targets.
@export var actionTargetType: ActionTargetType = 0
## How much damage this magic attack will deal.
@export_range(0, 99999999) var damageAmount: int = 50
