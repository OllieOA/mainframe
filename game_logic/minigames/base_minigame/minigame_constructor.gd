class_name BaseMinigame extends Panel

signal minigame_complete(score)
signal player_str_updated(key_not_valid)

@export var minigame_type: MinigameData.MinigameType

@onready var prompt_text: Label = $MinigameComponents/PromptText
@onready var auto_hack: Button = $MinigameComponents/AutoHack
@onready var auto_hack_progress: ProgressBar = $MinigameComponents/AutoHackProgress
@onready var auto_hack_activate_sound: AudioStreamPlayer = $AutoHackActivateSound

@onready var minigame_container: MarginContainer = $MinigameComponents/MinigameContainer


func _ready() -> void:
	GameControl.connect("autohack_made_available", _handle_autohack_made_available)
	GameControl.connect("autohack_triggered", _handle_autohack_used)
	create_minigame(minigame_type)


func _process(delta: float) -> void:
	auto_hack_progress.value = 100.0 * (1.0 - GameControl.autohack_timer.time_left) / GameControl.autohack_time


func create_minigame(val: MinigameData.MinigameType) -> void:
	assert(len(minigame_container.get_children()) == 0, "Tried to add a minigame where one already exists!")
	var new_minigame: Node = MinigameData.MINIGAME_LOOKUP[val].instantiate()
	prompt_text.text = MinigameData.PROMPTS_TEXT[val]
	minigame_container.add_child(new_minigame)
	
	new_minigame.connect("minigame_completed", _handle_minigame_completed)


func _handle_autohack_made_available() -> void:
	if auto_hack.disabled:
		auto_hack.disabled = false


func _handle_autohack_used() -> void:
	if not auto_hack.disabled:
		auto_hack.disabled = true


func _handle_minigame_completed() -> void:
	GameControl.emit_signal("minigame_complete")
