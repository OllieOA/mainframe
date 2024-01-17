class_name HoldKeys extends Minigame

@onready var hold_keys_prompt: RichTextLabel = $MinigameMargins/HoldKeysPrompt

var hold_required: Array
var keys_held: Dictionary

func _ready() -> void:
	super._ready()
	hold_required = WordUtils.get_random_keycodes(rng.randi_range(6, 8))
	call_deferred("_setup_keys_held")
	call_deferred("_show_bbcode_keys_held")


func _setup_keys_held() -> void:
	keys_held = keys_pressed.duplicate()


func _show_bbcode_keys_held() -> bool:
	var all_held = true
	var bbcode_string: String = ""
	var idx: int = 0
	for held_key in hold_required:
		idx += 1
		var next_key_str = " " + OS.get_keycode_string(held_key) + " "
		if keys_held[held_key]:
			bbcode_string += ColorTextUtils.set_bbcode_color_string(next_key_str, ColorTextUtils.correct_position_color)
		else:
			bbcode_string += ColorTextUtils.set_bbcode_color_string(next_key_str, ColorTextUtils.neutral_color)
			all_held = false
		
		if idx % 3 == 0 and idx > 0:
			bbcode_string += "\n"
	
	hold_keys_prompt.parse_bbcode(bbcode_string)
	print(all_held)
	return all_held


func _unhandled_input(event: InputEvent) -> void:
	# Needs a custom one
	if not event is InputEventKey:
		return
	
	if not GameControl.minigame_active:
		return
	
	if GameControl.active_minigame_id != minigame_id:
		return
	
	if event.keycode in keys_held:
		if event.is_pressed():
			keys_held[event.keycode] = true
		else:
			keys_held[event.keycode] = false
	
	_show_bbcode_keys_held()
	if _show_bbcode_keys_held():
		finish_minigame()


func _handle_player_str_updated(key_not_valid: bool, updated_minigame_id: int) -> void:
	if updated_minigame_id != minigame_id:
		return

	
