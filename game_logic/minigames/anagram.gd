class_name Anagram extends Minigame

@onready var anagram_prompt: RichTextLabel = %AnagramPrompt
@onready var anagram_response: RichTextLabel = %AnagramResponse

var correct_word: String = ""
var jumbled_word: String = ""

func _ready() -> void:
	correct_word = word_utils.get_random_words(1, 4, 6)[0]
	jumbled_word = correct_word
	
	while not _jumbled_okay():
		jumbled_word = jumble(correct_word)
	
	var bbcode_jumbled_word = ""
	for idx in range(len(jumbled_word)):
		if jumbled_word[idx] == correct_word[idx]:
			bbcode_jumbled_word += color_text_utils.set_bbcode_color_string(jumbled_word[idx], color_text_utils.correct_position_color)
		else:
			bbcode_jumbled_word += color_text_utils.set_bbcode_color_string(jumbled_word[idx], color_text_utils.neutral_color)

	anagram_prompt.parse_bbcode("  " + bbcode_jumbled_word)
	anagram_response.text = "> " + player_str

	start_minigame()


func jumble(input_str: String) -> String:
	var input_string_as_array: Array[String] = []
	for each_character in input_str:
		input_string_as_array.append(each_character)
	
	var jumbled_string: String = ""

	while len(input_string_as_array) > 0:
		jumbled_string += input_string_as_array.pop_at(rng.randi() % input_string_as_array.size())
	return jumbled_string


func _jumbled_okay() -> bool:
	var idx = 0
	var correct_places = 0
	while idx < len(correct_word):
		if correct_word[idx] == jumbled_word[idx]:
			correct_places += 1
		idx += 1

	var word_correctness = float(correct_places) / float(len(correct_word)) 

	if word_correctness >= 0.35 and word_correctness <= 0.6:
		return true
	
	return false


func _handle_player_str_updated(key_not_valid: bool) -> void:
	if len(player_str) > len(correct_word):
		emit_signal("bad_key")
		return

	anagram_response.text = "> " + player_str
	emit_signal("good_key")

	# Detect the win
	if player_str == correct_word:
		finish_minigame()


func _handle_minigame_complete() -> void:
	var bbcode_player_str = color_text_utils.set_bbcode_color_string(player_str, color_text_utils.correct_position_color)
	anagram_response.parse_bbcode("> " + bbcode_player_str)
