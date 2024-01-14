extends Node2D

@onready var puzzle_sprite: Sprite2D = %PuzzleSprite

const NORMAL_TEXTURE = preload("res://game_logic/network/puzzle_node.svg")
const ACTIVE_TEXTURE = preload("res://game_logic/network/puzzle_node_active.svg")

var node_base_coord: Vector2i
var node_enabled: bool = true

var target_position: Vector2
var close_enough: bool = false

var max_jiggle_size: float = 10.0
var min_jiggle_time: float = 1.0

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	_jiggle()


func _jiggle() -> void:
	if node_base_coord == null:
		return
	if target_position == Vector2.ZERO or target_position == null:
		target_position = global_position

	close_enough = global_position.distance_to(target_position) < 1.0
	
	if close_enough:
		var new_random_vector = Vector2(rng.randf_range(-max_jiggle_size, max_jiggle_size), rng.randf_range(-max_jiggle_size, max_jiggle_size))
		target_position = Vector2(node_base_coord) + new_random_vector
		
		var pos_tween = get_tree().create_tween()
		pos_tween.tween_property(self, "global_position", target_position, min_jiggle_time + randf_range(0, min_jiggle_time)).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func activate_node() -> void:
	puzzle_sprite.texture = ACTIVE_TEXTURE
	var zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(puzzle_sprite, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_IN_OUT)


func deactivate_node() -> void:
	puzzle_sprite.texture = NORMAL_TEXTURE
	var zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(puzzle_sprite, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_IN_OUT)


func disable_node() -> void:
	if node_enabled:
		node_enabled = false
		var zoom_tween = get_tree().create_tween()
		zoom_tween.tween_property(puzzle_sprite, "scale", Vector2(0.8, 0.8), 0.1).set_ease(Tween.EASE_IN_OUT)
		
		var color_tween = get_tree().create_tween()
		color_tween.tween_property(puzzle_sprite, "modulate", Color(0.6, 0.6, 0.6, 0.8), 0.1)


func enable_node() -> void:
	if not node_enabled:
		node_enabled = true
		activate_node()


func _check_to_enabled() -> void:
	if not node_enabled:
		enable_node()
