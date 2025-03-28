## Class for offensive magic spells that allies can cast to damage enemies.

class_name OffensiveSpell extends Spell

@export_category("Magic attack data")
## How much damage this magic attack will deal.
@export_range(0, 99999999) var damageAmount: int = 50
