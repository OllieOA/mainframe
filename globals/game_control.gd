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

signal surveillance_activated()
signal escape_activated()

var autohack_time: float = 4.0
var autohack_time_increase: float = 0.5
var autohack_available: bool = false

var overload_level: float = 100.0
var overload_decay_base: float = 10.0
var overload_decay: float = 10.0  # TODO Set up combo effect
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
var escape_active: bool = false

@onready var autohack_timer: Timer = $AutohackTimer


func _ready() -> void:
	autohack_timer.autostart = false
	autohack_timer.connect("timeout", _handle_autohack_timeout)
	
	connect("activated_minigame", _handle_minigame_activated)
	connect("deactivated_minigame", _handle_minigame_deactivated)
	connect("completed_minigame", _handle_minigame_completed)
	connect("destroyed_minigame", _handle_minigame_destroyed)
	
	connect("surveillance_activated", _handle_surveillance_activated)
	connect("escape_activated", _handle_escape_activated)
	
	overload_activated.connect(_handle_overload_activated)
	overload_exhausted.connect(_handle_overload_exhausted)
	
	connect("heistmate_entered_view", _handle_heistmate_entered_view)
	connect("heistmate_exited_view", _handle_heistmate_exited_view)
	
	# TEMP
	surveillance_active = true


func _process(delta: float) -> void:
	if surveillance_active:
		update_levels(delta)
	update_overload(delta)


func update_levels(delta: float) -> void:
	for detection_info in detection_lookup.values():
		if detection_info["count"] == 0 or detection_info["jammed"]:
			detection_info["level"] -= delta * detection_decay
		else:
			detection_info["level"] += delta * detection_info["count"] * detection_rate
			if detection_info["level"] >= max_detection:
				GameControl.escape_activated.emit()


func update_overload(delta: float ) -> void:
	overload_level -= overload_decay * delta
	if overload_level <= 0.0:
		overload_exhausted.emit()


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


func _handle_autohack_timeout() -> void:
	autohack_time += autohack_time_increase
	autohack_timer.wait_time = autohack_time
	emit_signal("autohack_made_available")


func _handle_surveillance_activated() -> void:
	surveillance_active = true


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
	detection_lookup[camera_type]["jammed"] = true


func _handle_overload_exhausted() -> void:
	for detection_info in detection_lookup.values():
		detection_info["jammed"] = false
