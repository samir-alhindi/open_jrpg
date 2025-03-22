class_name AllyItemAction extends AllyAction

@export_category("Item data")
enum ActionTargetType {
	SINGLE_ALLY, ## This action targets 1 singular ally battler in this battle.
	ALL_ALLIES, ## This action targets all the ally battlers in this battle.
	}
## The number of allies this item can be used on.
@export var actionTargetType: ActionTargetType = ActionTargetType.SINGLE_ALLY
