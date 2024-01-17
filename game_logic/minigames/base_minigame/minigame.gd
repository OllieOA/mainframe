class_name Minigame extends Panel

signal good_key(active_minigame_id: int)
signal bad_key(active_minigame_id: int)

@onready var good_type_sound: AudioStreamPlayer = $GoodTypeSound
@onready var bad_type_sound: AudioStreamPlayer = $BadTypeSound

var minigame_id: int = -1

var keys_pressed: Dictionary
var can_backspace: bool = true
var must_hold: bool = false

var player_str: String

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	
	GameControl.connect("player_str_updated", _handle_player_str_updated)
	GameControl.connect("completed_minigame", _handle_minigame_complete)
	connect("good_key", _play_good_key)
	connect("bad_key", _play_bad_key)
	call_deferred("_create_game")


func _create_game() -> void:
	player_str = ""
	keys_pressed = {}
	for each_scancode in WordUtils.valid_scancodes:
		keys_pressed[each_scancode] = false


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	
	if not GameControl.minigame_active:
		return
	
	if GameControl.active_minigame_id != minigame_id:
		return
	
	if event.is_action_pressed("backspace_word") and can_backspace:
		player_str = player_str.substr(0, len(player_str) - 1)
		GameControl.emit_signal("player_str_updated", false, minigame_id)
		return

	if event.keycode in WordUtils.alpha_scancodes:
		if not keys_pressed[event.keycode]:  # Check if currently pressed - prevents double keys
			keys_pressed[event.keycode] = true
			var key_typed = ""
			key_typed = OS.get_keycode_string(event.keycode)
			player_str += key_typed
			GameControl.emit_signal("player_str_updated", key_typed == "", minigame_id)
		
		elif not event.is_pressed():  # Allow the key to be pressed again
			keys_pressed[event.keycode] = false


func finish_minigame() -> void:
	GameControl.emit_signal("completed_minigame", minigame_id)


func _handle_player_str_updated(key_not_valid: bool, updated_minigame_id: int) -> void:
	pass  # TO BE OVERLOADED


func _handle_minigame_complete(completed_minigame_id: int) -> void:
	pass  # TO BE OVERLOADED


func _play_good_key(active_minigame_id: int) -> void:
	if active_minigame_id != GameControl.active_minigame_id:
		return
	good_type_sound.pitch_scale = rng.randf_range(0.95, 1.05)
	good_type_sound.play()


func _play_bad_key(active_minigame_id: int) -> void:
	if active_minigame_id != GameControl.active_minigame_id:
		return
	bad_type_sound.play()
