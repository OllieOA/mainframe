extends Node

signal autohack_made_available()
signal autohack_triggered()
signal activated_minigame(activated_minigame_id: int)
signal deactivated_minigame(deactivated_minigame_id: int)
signal completed_minigame(completed_minigame_id: int)
signal destroyed_minigame(destroyed_minigame_id: int)
signal spawned_minigame(spawned_minigame_id: int)
signal player_str_updated(key_valid: bool, minigame_id: int)

signal surveillance_activated()
signal escape_activated()

var autohack_time: float = 4.0
var autohack_time_increase: float = 0.5
var autohack_available: bool = false

var red_detection_level: float = 0.0
var green_detection_level: float = 0.0
var blue_detection_level: float = 0.0

var detection_rate: float = 1.0

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
