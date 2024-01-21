class_name SurveillanceCamera extends Node2D

@onready var collision_area: Area2D = $CollisionArea
@onready var view_area: CollisionPolygon2D = %ViewArea

@export var camera_type: PuzzleNode.IconType
@export var cone_width_deg: float = 28 # degrees - matches sprite
@export var view_distance: float = 140.0
@export var show_debug: bool = true

@export var max_rotation_deg: float = 15.0
var base_rotation_rad: float
var max_rotation_rad: float

@export var rotation_speed: float = 1.0
@export_range(-1, 1) var rotation_direction: int = 0

@export_flags_2d_physics var collision_layer_mask: int = 0

var cone_width_rad: float
var angle_step: float

var ray_points: Array[Vector2]
var poly_points: PackedVector2Array

const MIN_TIME: float = 100  # ms
const NUM_RAYS: int = 35

var last_update_time: float = 0.0
var scrolling_texture: Texture
var debug_rays: Array
var poly_color: Color

var overloaded: bool = false
var heistmate_in_view: bool = false
var heistmate_seen_this_frame: bool = false


func _ready() -> void:
	base_rotation_rad = rotation
	if rotation_direction == 0:
		rotation_direction = [-1, 1].pick_random()
	cone_width_rad = deg_to_rad(cone_width_deg)
	angle_step = cone_width_rad * 2 / float(NUM_RAYS)
	max_rotation_rad = deg_to_rad(max_rotation_deg)
	debug_rays = []
	
	GameControl.overload_activated.connect(_handle_overload_activated)
	GameControl.overload_exhausted.connect(_handle_overload_exhausted)


func _physics_process(delta: float) -> void:
	if abs(rotation - base_rotation_rad) > max_rotation_rad:
		rotation_direction *= -1
	
	rotation += rotation_direction * delta * rotation_speed * 0.1

	if Time.get_ticks_msec() - last_update_time > MIN_TIME:
		last_update_time = Time.get_ticks_msec()
		update_cone()


func _draw() -> void:
	draw_colored_polygon(poly_points, poly_color)
	
	if not show_debug:
		return
	for point in ray_points:
		draw_line(Vector2(0, 0), point, Color.RED)


func update_cone() -> void:
	pass
	# Cast all rays - walls only! (if we cast rays to heistmates it will be spiky)
	_cast_all_rays()
	_build_shape_params()
	_update_collision_polygon()
	GameControl.detection_lookup[camera_type]["count"] = len(collision_area.get_overlapping_bodies())
	#heistmate_seen_this_frame = len(collision_area.get_overlapping_bodies()) > 0
	#if not heistmate_in_view and heistmate_seen_this_frame:
		#heistmate_in_view = true
		#GameControl.emit_signal("heistmate_entered_view", camera_type)
	#
	#if heistmate_in_view and not heistmate_seen_this_frame:
		#heistmate_in_view = false
		#GameControl.emit_signal("heistmate_exited_view", camera_type)
	
	# Then update drawing
	queue_redraw()


func _cast_all_rays():
	ray_points = []
	
	# Create straight line, rotate it to the minimum angle, and then step up
	var next_ray: Vector2 
	
	var full_ray_point: Vector2
	var straight_vector: Vector2 = Vector2(view_distance, 0)
	var wall_query: PhysicsRayQueryParameters2D
	var collision_check: Dictionary
	var collision_point: Vector2

	for ray_num in range(NUM_RAYS + 1):
		full_ray_point = global_position + straight_vector.rotated(global_rotation - cone_width_rad + ray_num * angle_step)
		
		wall_query = PhysicsRayQueryParameters2D.create(global_position, full_ray_point, collision_layer_mask)
		collision_check = get_world_2d().direct_space_state.intersect_ray(wall_query)
		next_ray = collision_check.get("position", full_ray_point)
		
		ray_points.append(to_local(next_ray))


func _build_shape_params() -> void:
	poly_points = [Vector2(0, 0)]
	for point in ray_points:
		poly_points.append(point)
	poly_points.append(Vector2(0, 0))


func _update_collision_polygon() -> void:
	view_area.polygon.clear()
	view_area.polygon = poly_points


func _handle_overload_activated(icon_type: PuzzleNode.IconType) -> void:
	if icon_type != camera_type:
		return
	
	poly_color = Color.DIM_GRAY
	poly_color.a = 0.4


func _handle_overload_exhausted() -> void:
	poly_color = PuzzleNode.COLOR_LOOKUP[camera_type]["active"]
	poly_color.a = 0.4
