## Class for ally attack actions.
##
## Basically just an attack.

class_name Attack extends AllyAction

@export_category("Attack data")
enum ActionTargetType {
	SINGLE_ENEMY, ## This action targets 1 singular enemy battler in this battle.
	ALL_ENEMIES, ## This action targets all the enemy battlers in this battle.
	}
## The number of enemies this attack targets.
@export var actionTargetType: ActionTargetType = ActionTargetType.SINGLE_ENEMY
## How much damage this attack will deal.
@export_range(0, 999999, 5) var damageAmount: int = 50
