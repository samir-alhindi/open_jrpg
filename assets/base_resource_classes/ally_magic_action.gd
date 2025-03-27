class_name AllyMagicAction extends AllyAction

enum TargetNum {
	SINGLE,
	ALL,
}

@export_category("Magic data")
## How many magic points are required to use this magic action.
@export_range(0, 9999999) var magicPointsCost: int = 5
## How many targets will this magic action target.
@export var targetNum: TargetNum = TargetNum.SINGLE
