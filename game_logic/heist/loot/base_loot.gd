class_name BaseLoot extends Node2D

@onready var loot_sprite: Sprite2D = $LootSprite

var targeted: bool = false
@export var price: float = 0.0

const FIRST_THRESHOLD = 20000
const SECOND_THRESHOLD = 80000


func _ready() -> void:
	if price > SECOND_THRESHOLD:
		loot_sprite.frame = 2
	elif price > FIRST_THRESHOLD:
		loot_sprite.frame = 1
	else:
		loot_sprite.frame = 0
