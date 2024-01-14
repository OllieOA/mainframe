class_name ColorTextUtils extends Resource

@export var correct_position_color: Color = Color("#639765")
@export var incorrect_position_color: Color = Color("#a65455")
@export var active_position_color: Color = Color("#4682b4")
@export var neutral_color: Color = Color("#acacac")
@export var neutral_color_dark: Color = Color("#121212")
@export var inactive_color: Color = Color("#444444")

func set_bbcode_color_string(string: String, color: Color) -> String:
	# False for no alpha
	var bbcode_str = "[color=#" + color.to_html(false) + "]" + string + "[/color]"
	return bbcode_str
