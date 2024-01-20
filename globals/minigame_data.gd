extends Node

enum MinigameType {
	ANAGRAM,  # Find the anagram of a word with some letters pre-filled
	ALPHABET,  # Type the alphabet
	HOLD_KEYS,  # Hold all the keys at the same time
	CAPITALS,  # Type the capitalised letters
	HACK,  # Mash keys to hack
	#PROMPT,  # Type the three prompted words in order
	#WORDSEARCH,  # Find the word in a 4x4 grid
	#LONGEST,  # Type the longest word
	#SHORTEST,  # Type the shortest word
	#ACRONYM,  # Type the acronym of the words
	#FORTUNE,  # Guess the letters
	#VOWELS,  # Type only the vowels
	#CONSONANTS,  # Type only the consonants
}

const PROMPTS_TEXT = {
	MinigameType.ANAGRAM: "Unscramble this anagram!",
	MinigameType.ALPHABET: "Type the alphabet!",
	MinigameType.HOLD_KEYS: "Hold only these keys!",
	MinigameType.CAPITALS: "Find the word in capitals!",
	MinigameType.HACK: "Hack! (Type anything)"
}

const MINIGAME_LOOKUP = {
	MinigameType.ANAGRAM: preload("res://game_logic/minigames/anagram.tscn"),
	MinigameType.ALPHABET: preload("res://game_logic/minigames/alphabet.tscn"),
	MinigameType.HOLD_KEYS: preload("res://game_logic/minigames/hold_keys.tscn"),
	MinigameType.CAPITALS: preload("res://game_logic/minigames/capitals.tscn"),
	MinigameType.HACK: preload("res://game_logic/minigames/hack.tscn")
}
