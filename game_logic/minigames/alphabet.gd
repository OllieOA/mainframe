class_name Alphabet extends Minigame

@onready var alphabet_prompt: RichTextLabel = $MinigameMargins/AlphabetPrompt

var correct_word := ""
var curr_index := 0

const LINEBREAKS = [
	"H",
	"Q"
]

func _ready() -> void:
	super._ready()
	can_backspace = false
	call_deferred("_populate_alphabet")

func _populate_alphabet() -> void:
	for character in WordUtils.alphabet:
		correct_word += character

	can_backspace = false
	# Update color
	var full_bbcode_str = _build_bbcode_alpha_string()
	alphabet_prompt.parse_bbcode(full_bbcode_str)


func _build_bbcode_alpha_string() -> String:
	var full_bbcode_str = ""
	full_bbcode_str += ColorTextUtils.set_bbcode_color_string("> ", ColorTextUtils.neutral_color)
	full_bbcode_str += ColorTextUtils.set_bbcode_color_string(player_str, ColorTextUtils.correct_position_color)
	full_bbcode_str += ColorTextUtils.set_bbcode_color_string(correct_word.substr(curr_index), ColorTextUtils.neutral_color)

	for linebreak in LINEBREAKS:
		var linebreak_idx = full_bbcode_str.find(linebreak)

		var completed_portion = full_bbcode_str.substr(0, linebreak_idx + 1)
		var incomplete_portion = full_bbcode_str.substr(linebreak_idx + 1, len(full_bbcode_str))
		full_bbcode_str = completed_portion + "\n" + incomplete_portion

	return full_bbcode_str


func _handle_player_str_updated(key_not_valid: bool, updated_minigame_id: int) -> void:
	if updated_minigame_id != minigame_id:
		return

	var correct_key = correct_word[curr_index]

	if key_not_valid:
		emit_signal("bad_key", minigame_id)
	elif player_str[-1] != correct_key:
		player_str = player_str.substr(0, len(player_str) - 1)
		emit_signal("bad_key", minigame_id)
	else:
		curr_index += 1
		emit_signal("good_key", minigame_id)

	# Update color
	var full_bbcode_str = _build_bbcode_alpha_string()
	alphabet_prompt.parse_bbcode(full_bbcode_str)

	if player_str == correct_word:
		finish_minigame()
