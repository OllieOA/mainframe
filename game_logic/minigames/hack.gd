class_name Hack extends Minigame

@onready var hack_box: RichTextLabel = $MinigameMargins/HackBox

const TEXTBOX_SIZE = 54
const LINE_WIDTH = 14

var hack_str: String = "> "


func _ready() -> void:
	super._ready()
	can_backspace = false
	hack_box.parse_bbcode("> ")


func _handle_player_str_updated(key_not_valid: bool, updated_minigame_id: int) -> void:
	if updated_minigame_id != minigame_id:
		return
		
	hack_str = "> " + player_str
	
	var broken_lines = []
	var removed_string: String
	while len(hack_str) > LINE_WIDTH:
		removed_string = hack_str.left(LINE_WIDTH)
		broken_lines.append(removed_string + "\n")
		hack_str = hack_str.substr(LINE_WIDTH, -1)
	
	broken_lines.append(hack_str)
	
	hack_str = ""

	for line in broken_lines:
		hack_str += line
	
	var bbcode_hack_str: String = "> " + ColorTextUtils.set_bbcode_color_string(hack_str.substr(2, -1), ColorTextUtils.correct_position_color)
	
	hack_box.parse_bbcode(bbcode_hack_str)
	
	emit_signal("good_key", minigame_id)
	
	if len(player_str) >= TEXTBOX_SIZE:
		finish_minigame()
	
	
