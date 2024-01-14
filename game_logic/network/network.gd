class_name Network
extends Node2D

const HEX_RADIUS = 300
const PUZZLE_NODE = preload("res://game_logic/network/puzzle_node.tscn")
var node_lookup: Dictionary = {}

func _ready() -> void:
	_populate_network()
	node_lookup[3].activate_node()


func _populate_network() -> void:
	var base_screen_transform = DisplayServer.window_get_size()
	print(base_screen_transform)
	var screen_center = Vector2i(base_screen_transform.x / 2, base_screen_transform.y / 2)
	
	var curr_angle: float = 0.0
	var hex_points: Array = []
	
	for _i in range(6):
		var new_point = Vector2i(HEX_RADIUS * cos(curr_angle), HEX_RADIUS * sin(curr_angle)) + screen_center
		hex_points.append(new_point)
		curr_angle += 60 * PI/180
	
	var curr_idx = 0
	for point in hex_points:
		var new_node = PUZZLE_NODE.instantiate()
		add_child(new_node)
		new_node.position = point
		node_lookup[curr_idx] = new_node
		curr_idx += 1
		
