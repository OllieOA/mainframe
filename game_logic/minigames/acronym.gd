class_name Acronym extends Minigame

var correct_acronym: String = ""
var prompt_words: String = ""
var words: Array

@onready var acronym_prompt: RichTextLabel = $MinigameMargins/AcronymBox/AcronymPrompt
@onready var acronym_response: RichTextLabel = $MinigameMargins/AcronymBox/AcronymResponse


func _ready() -> void:
	super._ready()
	words = WordUtils.get_random_words(4, 4, 8)
	for word in words:
		correct_acronym += word[0]
		prompt_words += ColorTextUtils.set_bbcode_color_string(word, ColorTextUtils.neutral_color) + " "
	
	acronym_prompt.parse_bbcode(prompt_words)
	acronym_response.parse_bbcode("> ")


func _handle_player_str_updated(key_not_valid: bool, updated_minigame_id: int) -> void:
	if updated_minigame_id != minigame_id:
		return
	
	if len(player_str) > len(correct_acronym):
		emit_signal("bad_key", minigame_id)
		player_str = player_str.substr(0, len(player_str) - 1)
		return
	
	var bbcode_player_str = "> "
	var idx = 0
	var next_color: Color
	for each_char in player_str:
		next_color = ColorTextUtils.incorrect_position_color
		if each_char == correct_acronym[idx]:
			next_color = ColorTextUtils.correct_position_color
		bbcode_player_str += ColorTextUtils.set_bbcode_color_string(each_char, next_color)
		idx += 1
	
	acronym_response.parse_bbcode(bbcode_player_str)
	
	if player_str == correct_acronym:
		finish_minigame()
	
	if len(player_str) == 0:
		return
	if player_str[-1] == correct_acronym[len(player_str) - 1]:
		emit_signal("good_key", minigame_id)
	else:
		emit_signal("bad_key", minigame_id)
