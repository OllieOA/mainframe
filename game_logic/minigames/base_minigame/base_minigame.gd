class_name BaseMinigame extends Panel

signal minigame_complete(score)
signal player_str_updated(key_not_valid)

signal good_key()
signal bad_key()

@onready var good_type_sound: AudioStreamPlayer = $GoodTypeSound
@onready var bad_type_sound: AudioStreamPlayer = $BadTypeSound

enum MinigameType {
	ANAGRAM,  # Find the anagram of a word with some letters pre-filled
	KEYBOARD_HOLD,  # Hold all the keys at the same time
	KEYBOARD_TOGGLE,  # Set all buttons with short letter sequences to on
	CAPITALS,  # Type the capitalised letters
	PROMPT,  # Type the three prompted words in order
	GRID,  # Find the word in a 4x4 grid
	LONGEST,  # Type the longest word
	SHORTEST,  # Type the shortest word
}

var minigame_active: bool = false
var keys_pressed: Dictionary = {}
var can_backspace: bool = true
var must_hold: bool= false

var player_str: String = ""

var word_utils = preload("res://game_logic/minigames/utils/word_utils.tres")
var color_text_utils = preload("res://game_logic/minigames/utils/color_text_utils.tres")

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	connect("player_str_updated", _handle_player_str_updated)
	connect("bad_key", _play_bad_key)
	connect("good_key", _play_good_key)


func _unhandled_input(event: InputEvent) -> void:
	if not minigame_active:
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
	minigame_active = true


func _play_good_key() -> void:
	good_type_sound.pitch_scale = rng.randf_range(0.95, 1.05)
	good_type_sound.play()


func _play_bad_key() -> void:
	bad_type_sound.play()


func _handle_player_str_updated(key_not_valid) -> void:
	pass  # TO BE OVERLOADED
