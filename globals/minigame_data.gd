extends Node

enum MinigameType {
	ANAGRAM,  # Find the anagram of a word with some letters pre-filled
	KEYBOARD_HOLD,  # Hold all the keys at the same time
	KEYBOARD_TOGGLE,  # Set all buttons with short letter sequences to on
	CAPITALS,  # Type the capitalised letters
	PROMPT,  # Type the three prompted words in order
	GRID,  # Find the word in a 4x4 grid
	LONGEST,  # Type the longest word
	SHORTEST,  # Type the shortest word
}

const PROMPTS_TEXT = {
	MinigameType.ANAGRAM: "Unscramble this!"
}

const MINIGAME_LOOKUP = {
	MinigameType.ANAGRAM: preload("res://game_logic/minigames/anagram.tscn")
}
