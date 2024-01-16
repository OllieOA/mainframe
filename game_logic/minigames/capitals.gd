class_name Capitals extends Minigame

@onready var capitals_prompt: RichTextLabel = $MinigameMargins/CapitalsPrompt


const TEXTBOX_SIZE = 56
const LINE_WIDTH = 14

var correct_word: String = ""
var noise_string: String = ""
var curr_index: int = 0

var insert_indices: Array = []

func _ready() -> void:
	rng.randomize()
	correct_word = WordUtils.get_random_words(1, 6, 8)[0]
	can_backspace = false
	
	noise_string = "> "
	while len(noise_string) < TEXTBOX_SIZE:
		noise_string += WordUtils.alphabet[rng.randi() % len(WordUtils.alphabet)].to_lower()
	
	print("noise_string:" + noise_string)
	
	while len(insert_indices) < len(correct_word):
		var rand_index = rng.randi_range(5, TEXTBOX_SIZE - 1)
		if not rand_index in insert_indices:
			insert_indices.append(rand_index)

	insert_indices.sort()
	print("inserting "+ str(insert_indices))
	
	for idx in range(len(correct_word)):
		noise_string[insert_indices[idx]] = correct_word[idx]
	
	# TODO FIX THIS STALL
	
	# Insert newlines
	var broken_lines = []
	while len(noise_string) > 0:
		var removed_string = noise_string.left(LINE_WIDTH)
		broken_lines.append(removed_string + "\n")
		noise_string.erase(0, LINE_WIDTH)

	print("broken lines: " + str(broken_lines))

	for line in broken_lines:
		noise_string += line

	# Rebuild insert_indices
	insert_indices = []
	for idx in range(len(noise_string)):
		if noise_string[idx] in WordUtils.alphabet:
			insert_indices.append(idx)

	var full_bbcode_str = _build_bbcode_capitals()
	capitals_prompt.parse_bbcode(full_bbcode_str)


func _build_bbcode_capitals() -> String:
	var full_bbcode_str = ""
	var prev_index := 0
	for idx in range(curr_index):
		var target_substr = noise_string.substr(prev_index, insert_indices[idx] - prev_index)
		var target_char = noise_string[insert_indices[idx]]
		prev_index = insert_indices[idx] + 1

		full_bbcode_str += ColorTextUtils.set_bbcode_color_string(target_substr, ColorTextUtils.inactive_color)
		full_bbcode_str += ColorTextUtils.set_bbcode_color_string(target_char, ColorTextUtils.correct_position_color)

	if curr_index == len(correct_word):
		full_bbcode_str += ColorTextUtils.set_bbcode_color_string(noise_string.substr(prev_index), ColorTextUtils.inactive_color)
	else:
		full_bbcode_str += ColorTextUtils.set_bbcode_color_string(noise_string.substr(prev_index), ColorTextUtils.neutral_color)

	return full_bbcode_str


func _handle_player_str_updated(key_not_valid: bool, updated_minigame_id: int) -> void:
	if updated_minigame_id != minigame_id:
		return
	
	var correct_key = correct_word[curr_index]

	if key_not_valid:
		emit_signal("bad_key")
	elif player_str[-1] != correct_key:
		player_str = player_str.substr(0, len(player_str) - 1)
		emit_signal("bad_key")
	else:
		curr_index += 1
		emit_signal("good_key")

	# Update color
	var full_bbcode_str = _build_bbcode_capitals()
	capitals_prompt.parse_bbcode(full_bbcode_str)

	if player_str == correct_word:
		finish_minigame()
