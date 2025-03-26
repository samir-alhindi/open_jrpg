class_name BattleData extends Resource

@export_category("Assets")
## Display name for the battle in the main menu.
@export var battleName: String
## The background.
@export var background: Texture
## Background scale.
@export var scale: Vector2 = Vector2(1, 1)
## Background music
@export var battleMusic: AudioStream

@export_category("Battlers")
## All the ally party members in this battle.
@export var allies: Array[AllyStats]
## All the enemies in this battle.
@export var enemies: Array[EnemyStats]
