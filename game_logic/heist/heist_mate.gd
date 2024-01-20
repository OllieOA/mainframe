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
	LEAVING,
	PILFERING,
	EXTRACTING
	}

var heistmate_speed: float
var heist_ref: BaseHeist
var exiting_triggered: bool = false

var target_loot_object: BaseLoot
var next_path_position: Vector2

var pilfering_speed: float = 100.0
var packing_speed: float = 50.0
var unloading_speed: float = 75.0

const UNENCUMBERED_SPEED: float = 2000.0
const ENCUMBERED_SPEED: float = 800.0

var state: State = State.IDLE
var inventory: Array[float]
const INV_SIZE: int = 2


func _ready() -> void:
	inventory = []
	heist_nav.path_desired_distance = 5.0
	heist_nav.target_desired_distance = 2.0
	
	heistmate_speed = UNENCUMBERED_SPEED


func set_movement_target(target_pos: Vector2) -> void:
	heist_nav.target_position = target_pos


func _start_action() -> void:
	action_progress.value = 0.0
	action_progress.show()


func _stop_action() -> void:
	action_progress.value = 0.0
	action_progress.hide()
	


func check_state(delta: float) -> void:
	match state:
		State.IDLE:
			target_loot_object = heist_ref.get_loot_object()
			if target_loot_object == null:
				set_movement_target(heist_ref.escape_area.global_position)
				state = State.LEAVING
				exiting_triggered = true
			else:
				set_movement_target(target_loot_object.global_position)
				state = State.HEADING
		State.HEADING:
			_move(delta)
			if heist_nav.is_navigation_finished():
				state = State.ARRIVED
		State.ARRIVED:
			_start_action()
			state = State.PACKING
		State.PACKING:
			action_progress.value += packing_speed * delta
			if action_progress.value >= 100.0:
				action_progress.hide()
				inventory.append(target_loot_object.price)
				if len(inventory) == INV_SIZE:
					state = State.FULL
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
			_start_action()
			state = State.UNLOADING
		State.UNLOADING:
			action_progress.value += unloading_speed * delta
			if action_progress.value >= 100.0:
				heist_ref.loot_pile.append(inventory.pop_front())
				if len(inventory) > 0:
					action_progress.value = 0.0
				else:
					state = State.UNLOADED
		State.UNLOADED:
			_stop_action()
			heistmate_speed = UNENCUMBERED_SPEED
			if exiting_triggered:
				state = State.PILFERING
			else:
				state = State.IDLE
		State.LEAVING:
			_move(delta)
			if heist_nav.is_navigation_finished():
				if len(inventory) > 0:
					_start_action()
					state = State.UNLOADING
				else:
					state = State.PILFERING
		State.PILFERING:
			_start_action()
			if len(inventory) == 0:
				action_progress.value += packing_speed * delta
				if action_progress.value >= 100.0:
					if len(heist_ref.loot_pile) == 0:
						state = State.EXTRACTING
					inventory.append(heist_ref.loot_pile.pop_front())
					action_progress.value = 0.0
			else:
				action_progress.value += pilfering_speed * delta
				if action_progress.value >= 100.0:
					heist_ref.looted_objects.append(inventory.pop_front())
					action_progress.value = 0.0
		State.EXTRACTING:
			queue_free()


func _physics_process(delta: float) -> void:
	check_state(delta)


func _move(delta: float) -> void:
	next_path_position = heist_nav.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * heistmate_speed * delta
	move_and_slide()
