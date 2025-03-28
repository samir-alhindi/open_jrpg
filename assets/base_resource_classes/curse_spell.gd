## Class for curse magic spells that allies can cast to curse enemies.[br]
##
## When an enemy is cursed; It is inflected with a status effect that disables them from
## performing actions.[br]
## Each curse needs to have a [StatusEffect] object that it can inflect.


class_name CurseSpell extends Spell

## The status effect that this action will inflect.
@export var statusEffect: StatusEffect
