class_name HeistMate extends CharacterBody2D

@onready var heist_nav: NavigationAgent2D = $HeistNav
@onready var action_progress: TextureProgressBar = $ActionProgress


enum State {
	IDLE, 
	PACKING, 
	PACKED, 
	HEADING, 
	ARRIVED, 
	UNLOADING, 
	UNLOADED, 
	FULL,
	RETURNING, 
	RETURNED, 
	PILFERING
	}

var heistmate_speed: float
var heist_ref: BaseHeist

var target_loot_object: BaseLoot
var next_path_position: Vector2

var packing_speed: float = 50.0
var unloading_speed: float = 75.0

const UNENCUMBERED_SPEED: float = 2000.0
const ENCUMBERED_SPEED: float = 800.0

var state: State = State.IDLE
var inventory: Array[float]


func _ready() -> void:
	inventory = []
	heist_nav.path_desired_distance = 4.0
	heist_nav.target_desired_distance = 4.0
	
	heistmate_speed = UNENCUMBERED_SPEED


func set_movement_target(target_pos: Vector2) -> void:
	heist_nav.target_position = target_pos


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			target_loot_object = heist_ref.get_loot_object()
			set_movement_target(target_loot_object.global_position)
			state = State.HEADING
		State.HEADING:
			_move(delta)
			if heist_nav.is_navigation_finished():
				state = State.ARRIVED
		State.ARRIVED:
			action_progress.value = 0.0
			action_progress.show()
			state = State.PACKING
		State.PACKING:
			action_progress.value += packing_speed * delta
			if action_progress.value >= 100.0:
				action_progress.hide()
				inventory.append(target_loot_object.price)
				print(inventory)
				if len(inventory) == 3:
					state = State.RETURNING
				else:
					state = State.IDLE
		State.FULL:
			heistmate_speed = ENCUMBERED_SPEED
			set_movement_target(heist_ref.escape_area.global_position)
			state = State.RETURNING
		State.RETURNING:
			_move(delta)
			if heist_nav.is_navigation_finished():
				state = State.RETURNED
		State.RETURNED:
			action_progress.value = 0.0
			action_progress.show()
			state = State.UNLOADING
		State.UNLOADING:
			action_progress.value += unloading_speed * delta
			if action_progress.value >= 100.0:
				heist_ref.loot_pile.append(inventory.pop_front())
				if len(inventory) > 0:
					action_progress.value = 0
				else:
					state = State.IDLE


func _move(delta: float) -> void:
	next_path_position = heist_nav.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * heistmate_speed * delta
	move_and_slide()
