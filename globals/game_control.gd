extends Node

signal autohack_made_available()
signal autohack_triggered()
signal activated_minigame(activated_minigame_id: int)
signal deactivated_minigame(deactivated_minigame_id: int)
signal completed_minigame(completed_minigame_id: int)
signal destroyed_minigame(destroyed_minigame_id: int)
signal spawned_minigame(spawned_minigame_id: int)
signal player_str_updated(key_valid: bool, minigame_id: int)

signal heistmate_entered_view(camera_type: PuzzleNode.IconType)
signal heistmate_exited_view(camera_type: PuzzleNode.IconType)

signal overload_activated(camera_type: PuzzleNode.IconType)
signal overload_exhausted()
signal overload_combo_activated()

signal surveillance_activated()
signal escape_activated()

var autohack_level: float = 0.0
const BASE_AUTO_HACK_FILL_SPEED: float = 4.0
const MIN_AUTOHACK_FILL_SPEED: float = 1.0
var autohack_fill_speed: float = 4.0
#var autohack_fill_speed: float = 50.0
var autohack_fill_slow: float = 0.25
var autohack_available: bool = false

var overload_level: float = 0.0
var overload_active: bool = false
var overload_decay_base: float = 5.0
var overload_decay: float = 5.0
var overload_factor: float = 1.4
const MAX_OVERLOAD: float = 100.0

var detection_lookup: Dictionary = {
	PuzzleNode.IconType.CIRCLE: {
		"count": 0,
		"level": 0.0,
		"jammed": false
	},
	PuzzleNode.IconType.SQUARE: {
		"count": 0,
		"level": 0.0,
		"jammed": false
	},
	PuzzleNode.IconType.DIAMOND: {
		"count": 0,
		"level": 0.0,
		"jammed": false
	},
}

var detection_decay: float = 1.0
var detection_rate: float = 10.0
var max_detection: float = 100.0
# yag was here. finally.

var minigame_active: bool = false
var active_minigame_id: int = -1

var surveillance_active: bool = false
var calibration_active: bool = false
var escape_active: bool = false

@onready var autohack_timer: Timer = $AutohackTimer


func _ready() -> void:
	activated_minigame.connect(_handle_minigame_activated)
	deactivated_minigame.connect(_handle_minigame_deactivated)
	completed_minigame.connect(_handle_minigame_completed)
	destroyed_minigame.connect(_handle_minigame_destroyed)
	
	autohack_triggered.connect(_handle_autohack_triggered)
	
	surveillance_activated.connect(_handle_surveillance_activated)
	escape_activated.connect(_handle_escape_activated)
	
	overload_activated.connect(_handle_overload_activated)
	overload_exhausted.connect(_handle_overload_exhausted)
	
	heistmate_entered_view.connect(_handle_heistmate_entered_view)
	heistmate_exited_view.connect(_handle_heistmate_exited_view)
	
	surveillance_active = false


func _process(delta: float) -> void:
	if surveillance_active:
		update_levels(delta)
	
	if surveillance_active or escape_active:
		update_overload(delta)
		update_autohack(delta)

	if calibration_active:
		update_overload(delta)


func update_levels(delta: float) -> void:
	for detection_info in detection_lookup.values():
		if detection_info["count"] == 0 or detection_info["jammed"]:
			detection_info["level"] -= delta * detection_decay
		else:
			detection_info["level"] += delta * detection_info["count"] * detection_rate
			if detection_info["level"] >= max_detection:
				GameControl.escape_activated.emit()


func update_overload(delta: float) -> void:
	overload_level -= overload_decay * delta
	if overload_level <= 0.0:
		overload_exhausted.emit()


func update_autohack(delta: float) -> void:
	if not autohack_available:
		autohack_level += autohack_fill_speed * delta
		autohack_level = clamp(autohack_level, 0.0, 100.0)
		if autohack_level >= 100.0:
			autohack_available = true
			autohack_made_available.emit()


func _handle_minigame_activated(activated_minigame_id: int) -> void:
	minigame_active = true
	active_minigame_id = activated_minigame_id


func _handle_minigame_deactivated(deactivated_minigame_id: int) -> void:
	minigame_active = false
	active_minigame_id = -1


func _handle_minigame_completed(completed_minigame_id: int) -> void:
	minigame_active = false
	active_minigame_id = -1


func _handle_minigame_destroyed(destroyed_minigame_id: int) -> void:
	pass


func _handle_surveillance_activated() -> void:
	surveillance_active = true
	overload_level = 0.1


func _handle_escape_activated() -> void:
	surveillance_active = false
	escape_active = true
	for detection_info in detection_lookup.values():
		detection_info["level"] = max_detection


func _handle_heistmate_entered_view(camera_type: PuzzleNode.IconType) -> void:
	detection_lookup[camera_type]["count"] += 1


func _handle_heistmate_exited_view(camera_type: PuzzleNode.IconType) -> void:
	detection_lookup[camera_type]["count"] -= 1


func _handle_overload_activated(camera_type: PuzzleNode.IconType) -> void:
	overload_level = MAX_OVERLOAD
	if overload_active:
		overload_combo_activated.emit()
	overload_active = true
	detection_lookup[camera_type]["jammed"] = true
	overload_decay *= overload_factor


func _handle_overload_exhausted() -> void:
	for detection_info in detection_lookup.values():
		detection_info["jammed"] = false
	
	overload_active = false
	overload_decay = overload_decay_base


func _handle_autohack_triggered() -> void:
	autohack_available = false
	autohack_level = 0.0
	autohack_fill_speed = clamp(autohack_fill_speed - autohack_fill_slow, MIN_AUTOHACK_FILL_SPEED, autohack_fill_speed)
