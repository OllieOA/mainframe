class_name GameScene extends Node2D

@onready var network: Network = $Network
@onready var minigames: CanvasLayer = %Minigames
@onready var surveillance_bars: CanvasLayer = $SurveillanceBars


const MINIGAME_CONSTRUCTOR_SCENE = preload("res://game_logic/minigames/base_minigame/minigame_constructor.tscn")

const MINIGAME_SPAWN_LOCATIONS: Array = [
	Vector2i(1480, 360),
	Vector2i(1440, 700),
	Vector2i(120, 700),
	Vector2i(80, 360),
	Vector2i(120, 20),
	Vector2i(1440, 20),
]

var minigame_lookup: Dictionary

func _ready() -> void:
	network.connect("network_node_activated", _handle_network_node_activated)
	network.connect("network_node_deactivated", _handle_network_node_deactivated)
	
	var idx = 0
	for minigame_spawn_location in MINIGAME_SPAWN_LOCATIONS:
		var new_minigame: Node = MINIGAME_CONSTRUCTOR_SCENE.instantiate()
		
		new_minigame.minigame_id = idx
		minigames.add_child(new_minigame)
		new_minigame.deactivate_minigame()
		new_minigame.global_position = minigame_spawn_location
		new_minigame.minigame_base_location = minigame_spawn_location
		
		minigame_lookup[idx] = new_minigame
		
		idx += 1


func _handle_network_node_activated(node_id: int) -> void:
	minigame_lookup[node_id].activate_minigame()


func _handle_network_node_deactivated(node_id: int) -> void:
	minigame_lookup[node_id].deactivate_minigame()
