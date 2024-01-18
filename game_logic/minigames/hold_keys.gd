class_name HoldKeys extends Minigame

@onready var hold_keys_top_row: RichTextLabel = %HoldKeysTopRow
@onready var hold_keys_bottom_row: RichTextLabel = %HoldKeysBottomRow
@onready var dont_hold_keys: RichTextLabel = %DontHoldKeys

var hold_required: Array

var keys_held: Dictionary

func _ready() -> void:
	super._ready()
	hold_required = WordUtils.get_random_keycodes(6)
	call_deferred("_setup_keys_held")
	call_deferred("_show_bbcode_keys_held")


func _setup_keys_held() -> void:
	keys_held = keys_pressed.duplicate()


func _show_bbcode_keys_held() -> bool:
	var all_held = true
	var idx: int = 0
	var bbcode_string: String = ""
	var bbcode_strs: Array = []
	for held_key in hold_required:
		idx += 1
		var next_key_str = " " + OS.get_keycode_string(held_key) + " "
		if keys_held[held_key]:
			bbcode_string += ColorTextUtils.set_bbcode_color_string(next_key_str, ColorTextUtils.correct_position_color)
		else:
			bbcode_string += ColorTextUtils.set_bbcode_color_string(next_key_str, ColorTextUtils.neutral_color)
			all_held = false
		
		if idx % 3 == 0 and idx > 0:
			bbcode_strs.append(bbcode_string)
			bbcode_string = ""

	var bad_bbcode: String = " "
	var next_bad_key: String
	var bad_keys_num: int = 0
	for key_code in WordUtils.alpha_scancodes:
		if keys_held[key_code] and not key_code in hold_required:
			next_bad_key = OS.get_keycode_string(key_code)
			bad_bbcode += ColorTextUtils.set_bbcode_color_string(next_bad_key, ColorTextUtils.incorrect_position_color)
			bad_keys_num += 1
			if bad_keys_num >= 7:
				break
	
	hold_keys_top_row.parse_bbcode(bbcode_strs[0])
	hold_keys_bottom_row.parse_bbcode(bbcode_strs[1])
	
	dont_hold_keys.parse_bbcode(bad_bbcode)
	
	all_held = all_held and bad_keys_num == 0
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

	
