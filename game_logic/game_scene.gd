class_name GameScene extends Node2D

@onready var network: Network = $Network
@onready var minigames: CanvasLayer = %Minigames


const MINIGAME_CONSTRUCTOR_SCENE = preload("res://game_logic/minigames/base_minigame/minigame_constructor.tscn")

const MINIGAME_SPAWN_LOCATIONS: Array = [
	Vector2i(1480 + 40, 360),
	Vector2i(1440 + 40, 630),
	Vector2i(120 + 40, 630),
	Vector2i(80, 360),
	Vector2i(120 + 40, 50),
	Vector2i(1440, 50),
]

var minigame_lookup: Dictionary
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	network.connect("network_node_activated", _handle_network_node_activated)
	network.connect("network_node_deactivated", _handle_network_node_deactivated)
	GameControl.connect("completed_minigame", _handle_minigame_completed)
	
	var idx = 0
	for minigame_spawn_location in MINIGAME_SPAWN_LOCATIONS:
		_spawn_minigame(idx, minigame_spawn_location, PuzzleNode.icon_type_map[idx % 3])
		
		idx += 1


func _spawn_minigame(minigame_id: int, minigame_spawn_location: Vector2i, icon_type: PuzzleNode.IconType) -> void:
	var new_minigame: Node = MINIGAME_CONSTRUCTOR_SCENE.instantiate()
	new_minigame.minigame_id = minigame_id
	new_minigame.minigame_icon_type = icon_type
	
	var acceptable_minigames_lookup: Dictionary = {}
	
	for minigame in minigame_lookup.values():
		if minigame == null:
			continue
		if minigame.minigame_type not in acceptable_minigames_lookup:
			acceptable_minigames_lookup[minigame.minigame_type] = 0
		acceptable_minigames_lookup[minigame.minigame_type] += 1

	var acceptable_minigames: Array = []
	for minigame in MinigameData.MinigameType.values():
		if acceptable_minigames_lookup.get(minigame, 0) < 2:
			acceptable_minigames.append(minigame)

	var minigame_choice = acceptable_minigames.pick_random()
	minigames.add_child(new_minigame)

	new_minigame.create_minigame(minigame_choice)
	
	#new_minigame.create_minigame(MinigameData.MinigameType.ANAGRAM)
	#new_minigame.create_minigame(MinigameData.MinigameType.ALPHABET)
	#new_minigame.create_minigame(MinigameData.MinigameType.CAPITALS)
	#new_minigame.create_minigame(MinigameData.MinigameType.HOLD_KEYS)
	#new_minigame.create_minigame(MinigameData.MinigameType.HACK)
	#new_minigame.create_minigame(MinigameData.MinigameType.ACRONYM)
	#new_minigame.create_minigame(MinigameData.MinigameType.CONSONANTS)
	#new_minigame.create_minigame(MinigameData.MinigameType.VOWELS)
	#new_minigame.create_minigame(MinigameData.MinigameType.PROMPT)
	new_minigame.deactivate_minigame()
	new_minigame.global_position = minigame_spawn_location
	new_minigame.minigame_base_location = minigame_spawn_location
	minigame_lookup[minigame_id] = new_minigame


func _handle_network_node_activated(node_id: int) -> void:
	minigame_lookup[node_id].activate_minigame()


func _handle_network_node_deactivated(node_id: int) -> void:
	if minigame_lookup[node_id] == null:
		return
	minigame_lookup[node_id].deactivate_minigame()


func _handle_minigame_completed(completed_minigame_id: int) -> void:
	GameControl.overload_activated.emit(minigame_lookup[completed_minigame_id].minigame_icon_type)
	for each_node in minigame_lookup:
		if minigame_lookup[each_node] == null and completed_minigame_id != each_node:
			_spawn_minigame(each_node, MINIGAME_SPAWN_LOCATIONS[each_node], PuzzleNode.icon_type_map[each_node % 3])
			GameControl.emit_signal("spawned_minigame", each_node)
