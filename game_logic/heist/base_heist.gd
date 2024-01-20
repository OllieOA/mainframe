class_name BaseHeist extends Node2D

@onready var loot_objects: Node2D = $LootObjects
@onready var heist_mates: Node2D = $HeistMates
@onready var escape_area: Area2D = $EscapeArea

var loot_pile: Array[float]
var looted_objects: Array[float]

var heistmate_lookup: Array[HeistMate]
var loot_lookup: Array[BaseLoot]

func _ready() -> void:
	loot_pile = []
	for heistmate in heist_mates.get_children():
		heistmate_lookup.append(heistmate)
		heistmate.heist_ref = self

	for loot in loot_objects.get_children():
		loot_lookup.append(loot)


func get_loot_object() -> BaseLoot:
	for loot_object in loot_lookup:
		if not loot_object.targeted:
			loot_object.targeted = true
			return loot_object
			
	return null
