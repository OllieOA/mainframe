class_name Prompt extends Minigame

@onready var prompt: RichTextLabel = $MinigameMargins/Prompt

var correct_str: String = ""
var prompt_str: String = ""
var prompt_str_index: int = 0
var curr_idx: int = 0
var words: Array


func _ready() -> void:
	super._ready()
	can_backspace = false
	words = WordUtils.get_random_words(randi_range(3, 4), 4, 7)

	for word in words:
		correct_str += word

	prompt.parse_bbcode(_build_bbcode_prompt())


func _build_bbcode_prompt() -> String:
	prompt_str_index = 0
	var bbcode_str = "> "
	var target_color: Color

	for word in words:
		for each_char in word:
			
			if prompt_str_index < len(player_str):
				target_color = ColorTextUtils.correct_position_color
			else:
				target_color = ColorTextUtils.neutral_color
			bbcode_str += ColorTextUtils.set_bbcode_color_string(each_char, target_color)
			prompt_str_index += 1
		bbcode_str += " "
	
	return bbcode_str


func _handle_player_str_updated(key_not_valid: bool, updated_minigame_id: int) -> void:
	if updated_minigame_id != minigame_id:
		return
	
	if len(player_str) > len(correct_str):
		emit_signal("bad_key", minigame_id)
		player_str = player_str.substr(0, len(player_str) - 1)
		return
	
	var correct_key = correct_str[curr_idx]
	if key_not_valid:
		emit_signal("bad_key", minigame_id)
	elif player_str[-1] != correct_key:
		player_str = player_str.substr(0, len(player_str) - 1)
		emit_signal("bad_key", minigame_id)
	else:
		curr_idx += 1
		emit_signal("good_key", minigame_id)

	prompt.parse_bbcode(_build_bbcode_prompt())
	
	if player_str == correct_str:
		finish_minigame()
