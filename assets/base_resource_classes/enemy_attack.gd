class_name EnemyAttack extends EnemyAction

enum ActionTargetType {
	SINGLE_ALLY, ## This action targets 1 singular ally battler in this battle.
	ALL_ALLIES, ## This action targets all the ally battlers in this battle.
	}

@export_category("Attack data")
## Which battler(s) type this action will target.
@export var actionTargetType: ActionTargetType = ActionTargetType.SINGLE_ALLY
## How much damage this attack will deal.
@export_range(0, 999999, 5) var damageAmount: int = 50
