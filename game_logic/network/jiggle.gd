class_name Jiggle extends Node2D

@export var node_to_jiggle: Node

@export var max_jiggle_size: float = 10.0
@export var min_jiggle_time: float = 1.0

var node_base_coord: Vector2
var target_position: Vector2
var close_enough: bool = false
var rng = RandomNumberGenerator.new()

var pos_tween: Tween
var reset_tween: Tween

var jiggle_enabled: bool = false

func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	_jiggle()


func enable_jiggle() -> void:
	jiggle_enabled = true


func disable_jiggle() -> void:
	jiggle_enabled = false


func reset_position() -> void:
	disable_jiggle()
	if pos_tween == null:
		return
	pos_tween.stop()
	reset_tween = get_tree().create_tween()
	reset_tween.tween_property(node_to_jiggle, "global_position", node_base_coord, 0.1).set_ease(Tween.EASE_IN)


func _jiggle() -> void:
	if not jiggle_enabled:
		return
	if node_base_coord == null:
		return
	if target_position == Vector2.ZERO or target_position == null:
		target_position = global_position

	close_enough = global_position.distance_to(target_position) < 1.0
	
	if close_enough:
		var new_random_vector = Vector2(rng.randf_range(-max_jiggle_size, max_jiggle_size), rng.randf_range(-max_jiggle_size, max_jiggle_size))
		target_position = Vector2(node_base_coord) + new_random_vector
		pos_tween = get_tree().create_tween()
		pos_tween.tween_property(node_to_jiggle, "global_position", target_position, min_jiggle_time + randf_range(0, min_jiggle_time)).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

