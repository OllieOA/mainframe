extends Node

enum MinigameType {
	ANAGRAM,  # Find the anagram of a word with some letters pre-filled
	ALPHABET,  # Type the alphabet
	HOLD_KEYS,  # Hold all the keys at the same time
	#KEYBOARD_TOGGLE,  # Set all buttons with short letter sequences to on
	CAPITALS,  # Type the capitalised letters
	#PROMPT,  # Type the three prompted words in order
	#GRID,  # Find the word in a 4x4 grid
	#LONGEST,  # Type the longest word
	#SHORTEST,  # Type the shortest word
}

const PROMPTS_TEXT = {
	MinigameType.ANAGRAM: "Unscramble this!",
	MinigameType.ALPHABET: "Type the alphabet!",
	MinigameType.HOLD_KEYS: "Hold these keys!",
	MinigameType.CAPITALS: "Find the word!"
}

const MINIGAME_LOOKUP = {
	MinigameType.ANAGRAM: preload("res://game_logic/minigames/anagram.tscn"),
	MinigameType.ALPHABET: preload("res://game_logic/minigames/alphabet.tscn"),
	MinigameType.HOLD_KEYS: preload("res://game_logic/minigames/hold_keys.tscn"),
	MinigameType.CAPITALS: preload("res://game_logic/minigames/capitals.tscn")
}
