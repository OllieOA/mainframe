class_name WordUtils extends Resource

const word_list_path = "res://utils/wordlist.json"

var word_list: Array
var valid_scancodes: Array
var special_scancodes := [KEY_PERIOD]
var alpha_scancodes: Array
var alphabet: Array

const SPECIAL_LOOKUP = {
	KEY_PERIOD: ".",
}

var rng = RandomNumberGenerator.new()


func generate_all() -> void:
	rng.randomize()
	_generate_word_list()
	_generate_alphabet()


func _generate_word_list() -> void:
	var f = FileAccess.open(word_list_path, FileAccess.READ)

	var json = f.get_as_text()
	word_list = JSON.parse_string(json)

	var word_list_upper = []
	for word in word_list:
		word_list_upper.append(word.to_upper())

	word_list = word_list_upper


func _generate_alphabet() -> void:
	alpha_scancodes = range(KEY_A, KEY_Z + 1)
	for each_scancode in alpha_scancodes:
		alphabet.append(OS.get_keycode_string(each_scancode))

	# Set other scancodes
	valid_scancodes = alpha_scancodes
	valid_scancodes += special_scancodes
	
	print(alpha_scancodes)
