class_name Network
extends Node2D

const HEX_RADIUS = 320
const PUZZLE_NODE = preload("res://game_logic/network/puzzle_node.tscn")

var active_node = 0

var node_lookup: Dictionary = {}
var all_connected_nodes: Dictionary = {}
var all_backup_nodes: Dictionary = {}

var polyline_spec: PackedVector2Array

func _ready() -> void:
	_populate_network()
	node_lookup[active_node].activate_node()
	
	for i in range(6):
		all_connected_nodes[i] = [wrap(i - 1, 0, 6), wrap(i + 1, 0, 6)]
		all_backup_nodes[i] = [wrap(i - 2, 0, 6), wrap(i + 2, 0, 6)]


func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	polyline_spec = _get_lines()
	draw_polyline(polyline_spec, Color.WEB_GRAY, 5.0, true)


func _get_lines() -> PackedVector2Array:
	var connection_points: PackedVector2Array = []
	for base_node in all_connected_nodes:
		if node_lookup[base_node].node_enabled:
			connection_points.append(node_lookup[base_node].global_position)

	connection_points.append(connection_points[0])
	return connection_points


func _populate_network() -> void:
	var base_screen_transform = DisplayServer.window_get_size()
	var screen_center = Vector2i(base_screen_transform.x / 2, base_screen_transform.y / 2)
	
	var curr_angle: float = 0.0
	var hex_points: Array = []
	
	for _i in range(6):
		var new_point = Vector2i(int(HEX_RADIUS * cos(curr_angle)), int(HEX_RADIUS * sin(curr_angle))) + screen_center
		hex_points.append(new_point)
		curr_angle += 60 * PI/180
	
	var curr_idx = 0
	for point in hex_points:
		var new_node = PUZZLE_NODE.instantiate()
		add_child(new_node)
		new_node.global_position = point
		new_node.node_base_coord = point
		node_lookup[curr_idx] = new_node
		new_node.set_icon_type(curr_idx % 3)
		curr_idx += 1


func _move_to_node(new_node: int, backup_node: int) -> void:
	var move_to = new_node
	if not node_lookup[new_node].node_enabled:
		move_to = backup_node
	
	node_lookup[active_node].deactivate_node()
	node_lookup[move_to].activate_node()
	active_node = move_to


func _try_move(event: InputEvent) -> void:
	var connected_nodes = all_connected_nodes[active_node]
	var backup_nodes = all_backup_nodes[active_node]
	
	var node_option = 0
	for each_node in connected_nodes:
		var vert_diff = node_lookup[each_node].node_base_coord.y - node_lookup[active_node].node_base_coord.y
		var horiz_diff = node_lookup[each_node].node_base_coord.x - node_lookup[active_node].node_base_coord.x
		var backup_node = backup_nodes[node_option]
		if event.is_action_pressed("move_left") and horiz_diff < 0:
			_move_to_node(each_node, backup_node)
		elif event.is_action_pressed("move_right") and horiz_diff > 0:
			_move_to_node(each_node, backup_node)
		
		elif event.is_action_pressed("move_up") and vert_diff < 0:
			_move_to_node(each_node, backup_node)
		elif event.is_action_pressed("move_down") and vert_diff > 0:
			_move_to_node(each_node, backup_node)
		
		node_option += 1
	
	node_lookup[0].disable_node()


func _unhandled_input(event: InputEvent) -> void:
	_try_move(event)
