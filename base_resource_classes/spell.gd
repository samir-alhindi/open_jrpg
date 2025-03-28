## Abstract class that all ally spell actions inherit from.
## Magic spells need MP (Magic points) in order to be cast.[br]
## Do [b]not[/b] instance this class, Instead instance one of the non-abstract child classes,
## Such as [OffensiveSpell], [HealingSpell], or [CurseSpell].

class_name Spell extends AllyAction

enum TargetNum {
	SINGLE,
	ALL,
}

@export_category("Magic data")
## How many magic points are required to use this magic action.
@export_range(0, 9999999) var magicPointsCost: int = 5
## How many targets will this magic action target.
@export var targetNum: TargetNum = TargetNum.SINGLE
