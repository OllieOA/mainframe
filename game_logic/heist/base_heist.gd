class_name BaseHeist extends Node2D

signal updated_pile()
signal updated_pilfered()

@onready var loot_objects: Node2D = $LootObjects
@onready var heist_mates: Node2D = $HeistMates
@onready var escape_area: Area2D = $EscapeArea
@onready var loot_pile_sprite: Sprite2D = $EscapeArea/LootPileSprite

@onready var pilfered_take_amount: Label = %PilferedTakeAmount
@onready var potential_take_amount: Label = %PotentialTakeAmount

var loot_pile_thresholds: Array[float] = [
	900000.0,
	500000.0,
	100000.0,
	10000.0,
	0.0
]

var loot_pile: Array[float]
var looted_objects: Array[float]

var heistmate_lookup: Array[HeistMate]
var loot_lookup: Array[BaseLoot]

var potential_take: float = 0.0
var potential_take_shown: float = 0.0
var potential_take_str: String = ""
var pilfered_take: float = 0.0
var pilfered_take_shown: float = 0.0
var pilfered_take_str: String = ""

var potential_update_tween: PropertyTweener
var pilfered_update_tween: PropertyTweener


func _ready() -> void:
	loot_pile = []
	for heistmate in heist_mates.get_children():
		heistmate_lookup.append(heistmate)
		heistmate.heist_ref = self

	for loot in loot_objects.get_children():
		loot_lookup.append(loot)
	
	updated_pile.connect(_handle_updated_pile)
	updated_pilfered.connect(_handle_updated_pilfered)


func _process(delta: float) -> void:
	#print(potential_take_shown)
	pilfered_take_str = _make_money_str(pilfered_take_shown)
	potential_take_str = _make_money_str(potential_take_shown)
	
	pilfered_take_amount.text = pilfered_take_str
	potential_take_amount.text = potential_take_str


func _make_money_str(value: float) -> String:
	var int_val = int(value)
	var new_str = ""
	
	while int_val > 1000:
		new_str += ",%03d" % (int_val % 1000)
		int_val /= 1000
	
	return "$" + str(int_val) + new_str


func _sum_array(arr: Array[float]) -> float:
	var sum: float = 0.0
	for ele in arr:
		sum += ele
	
	return sum


func get_loot_object() -> BaseLoot:
	for loot_object in loot_lookup:
		if loot_object == null:
			continue
		if not loot_object.targeted:
			loot_object.targeted = true
			return loot_object
			
	return null


func add_to_pile(value: float) -> void:
	loot_pile.append(value)
	potential_take = _sum_array(loot_pile)
	loot_pile.sort()
	updated_pile.emit()


func remove_from_pile() -> float:
	var loot_object = loot_pile.pop_back()
	potential_take = _sum_array(loot_pile)
	updated_pile.emit()
	if loot_object == null:
		return 0.0
	return loot_object


func add_to_pilfered(value: float) -> void:
	pilfered_take += value
	updated_pilfered.emit()


func _handle_updated_pile() -> void:
	#if potential_update_tween != null:
		#if potential_update_tween.is_running():
			#potential_update_tween.stop()
	
	potential_update_tween = get_tree().create_tween().tween_property(self, "potential_take_shown", potential_take, 0.5).set_ease(Tween.EASE_IN)
	
	loot_pile_sprite.frame = 0
	for loot_idx in range(len(loot_pile_thresholds)):
		if potential_take > loot_pile_thresholds[loot_idx]:
			loot_pile_sprite.frame = len(loot_pile_thresholds) - loot_idx
			break


func _handle_updated_pilfered() -> void:
	#if pilfered_update_tween != null:
		#if pilfered_update_tween.is_running():
			#pilfered_update_tween.stop()
	
	pilfered_update_tween = get_tree().create_tween().tween_property(self, "pilfered_take_shown", pilfered_take, 0.5).set_ease(Tween.EASE_IN)

