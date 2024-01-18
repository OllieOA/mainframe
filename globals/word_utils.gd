extends Node

const word_list_path = "res://globals/wordlist.json"

var word_list: Array
var valid_scancodes: Array
var special_scancodes := [KEY_PERIOD]
var alpha_scancodes: Array
var alphabet: Array

const SPECIAL_LOOKUP = {
	KEY_PERIOD: ".",
}

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	generate_all()


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
	valid_scancodes = alpha_scancodes.duplicate()
	valid_scancodes += special_scancodes


func get_random_words(target_num_words: int, min_word_length: int, max_word_length: int) -> Array:
	if len(word_list) == 0:
		generate_all()

	var strings = []

	while len(strings) < target_num_words:
		var rand_choice = word_list[rng.randi() % word_list.size()]
		if not rand_choice in strings and len(rand_choice) <= max_word_length and len(rand_choice) >= min_word_length:
			strings.append(rand_choice)
	
	return strings


func get_random_letters(target_num_letters: int) -> Array:
	assert(target_num_letters <= 25, "Too many letters selected!")
	
	if len(alphabet) == 0:
		generate_all()

	var mutator_alphabet = alphabet.duplicate()
	mutator_alphabet.shuffle()
	return mutator_alphabet.slice(0, target_num_letters)


func get_random_keycodes(target_num_keycodes: int) -> Array:
	assert(target_num_keycodes <= 25, "Too many keycodes selected!")
	
	if len(alpha_scancodes) == 0:
		generate_all()

	var mutator_scancodes: Array = alpha_scancodes.duplicate()
	mutator_scancodes.shuffle()
	return mutator_scancodes.slice(0, target_num_keycodes)
