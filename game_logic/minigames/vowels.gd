class_name Vowels extends Minigame

@onready var vowels_prompt: RichTextLabel = $MinigameMargins/VowelsPrompt

var correct_str: String = ""
var prompt_str: String = ""
var words: Array
var curr_index: int = 0
var prompt_index: int = 0
var vowels_indices: Array = []


func _ready() -> void:
	super._ready()
	can_backspace = false
	words = WordUtils.get_random_words(3, 4, 7)
	
	prompt_str = "> "
	for word in words:
		prompt_str += word + " "
		for each_char in word:
			correct_str += each_char if each_char in WordUtils.vowels else ""
	
	for each_char in prompt_str:
		if each_char in WordUtils.vowels:
			vowels_indices.append(prompt_index)
		prompt_index += 1
	
	vowels_prompt.parse_bbcode(_build_bbcode_consonants())


func _build_bbcode_consonants() -> String:
	var full_bbcode_str = ""
	var prev_index := 0
	for idx in range(curr_index):
		var target_substr = prompt_str.substr(prev_index, vowels_indices[idx] - prev_index)
		var target_char = prompt_str[vowels_indices[idx]]
		prev_index = vowels_indices[idx] + 1

		full_bbcode_str += ColorTextUtils.set_bbcode_color_string(target_substr, ColorTextUtils.inactive_color)
		full_bbcode_str += ColorTextUtils.set_bbcode_color_string(target_char, ColorTextUtils.correct_position_color)

	if curr_index == len(correct_str):
		full_bbcode_str += ColorTextUtils.set_bbcode_color_string(prompt_str.substr(prev_index), ColorTextUtils.inactive_color)
	else:
		full_bbcode_str += ColorTextUtils.set_bbcode_color_string(prompt_str.substr(prev_index), ColorTextUtils.neutral_color)

	return full_bbcode_str


func _handle_player_str_updated(key_not_valid: bool, updated_minigame_id: int) -> void:
	if updated_minigame_id != minigame_id:
		return

	var correct_key = correct_str[curr_index]

	if key_not_valid:
		emit_signal("bad_key", minigame_id)
	elif player_str[-1] != correct_key:
		player_str = player_str.substr(0, len(player_str) - 1)
		emit_signal("bad_key", minigame_id)
	else:
		curr_index += 1
		emit_signal("good_key", minigame_id)

	vowels_prompt.parse_bbcode(_build_bbcode_consonants())

	if player_str == correct_str:
		finish_minigame()
