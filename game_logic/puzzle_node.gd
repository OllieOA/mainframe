extends Node2D

@onready var puzzle_sprite: Sprite2D = %PuzzleSprite

const NORMAL_TEXTURE = preload("res://game_logic/network/puzzle_node.svg")
const ACTIVE_TEXTURE = preload("res://game_logic/network/puzzle_node_active.svg")

func activate_node() -> void:
	puzzle_sprite.texture = ACTIVE_TEXTURE
	var zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(puzzle_sprite, "scale", Vector2(1.2, 1.2), 0.2)


func deactivate_node() -> void:
	puzzle_sprite.texture = NORMAL_TEXTURE
	var zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(puzzle_sprite, "scale", Vector2(1.0, 1.0), 0.2)
