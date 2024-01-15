class_name Minigame extends PanelContainer

signal minigame_started()
signal minigame_completed()
signal good_key()
signal bad_key()

@export var word_utils: WordUtils
@export var color_text_utils: ColorTextUtils

@onready var good_type_sound: AudioStreamPlayer = $GoodTypeSound
@onready var bad_type_sound: AudioStreamPlayer = $BadTypeSound

var minigame_data = MinigameData.new()
var minigame_id: int = -1

var keys_pressed: Dictionary = {}
var can_backspace: bool = true
var must_hold: bool= false

var player_str: String = ""

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func _unhandled_input(event: InputEvent) -> void:
	if not GameControl.minigame_active:
		return
	
	if not GameControl.active_minigame_id != minigame_id:
		return
	
	if event.is_action_pressed("backspace_word") and can_backspace:
		player_str = player_str.substr(0, len(player_str) - 1)
		emit_signal("player_str_updated", false)
		return
	
	if event is InputEventKey:
		if event.keycode in word_utils.alpha_scancodes:
			if not keys_pressed[event.keycode]:  # Check if currently pressed - prevents double keys
				keys_pressed[event.keycode] = true
				var key_typed = ""
				key_typed = OS.get_keycode_string(event.keycode)
				player_str += key_typed
				emit_signal("player_str_updated", key_typed == "")
			
			elif not event.is_pressed():  # Allow the key to be pressed again
				keys_pressed[event.scancode] = false


func start_minigame() -> void:
	emit_signal("minigame_started")


func finish_minigame() -> void:
	emit_signal("minigame_completed")
	queue_free()  # TODO: Replace with animation


func _handle_player_str_updated(key_not_valid) -> void:
	pass  # TO BE OVERLOADED


func _play_good_key() -> void:
	good_type_sound.pitch_scale = rng.randf_range(0.95, 1.05)
	good_type_sound.play()


func _play_bad_key() -> void:
	bad_type_sound.play()
