class_name BaseMinigame extends Control

@export var minigame_type: MinigameData.MinigameType

@onready var auto_hack_activate_sound: AudioStreamPlayer = %AutoHackActivateSound
@onready var prompt_text: Label = %PromptText
@onready var minigame_container: Control = %MinigameContainer
@onready var auto_hack: Button = %AutoHack
@onready var auto_hack_progress: ProgressBar = %AutoHackProgress

@onready var main_container: PanelContainer = %MainContainer
@onready var minigame_icon: TextureRect = %MinigameIcon

var minigame_id: int = -1
var minigame_base_location: Vector2i


func _ready() -> void:
	GameControl.connect("autohack_made_available", _handle_autohack_made_available)
	GameControl.connect("autohack_triggered", _handle_autohack_used)
	create_minigame(minigame_type)


func _process(delta: float) -> void:
	auto_hack_progress.value = 100.0 * (1.0 - GameControl.autohack_timer.time_left) / GameControl.autohack_time


func create_minigame(val: MinigameData.MinigameType) -> void:
	assert(len(minigame_container.get_children()) == 0, "Tried to add a minigame where one already exists!")
	
	var new_minigame: Node = MinigameData.MINIGAME_LOOKUP[val].instantiate()
	new_minigame.minigame_id = minigame_id
	prompt_text.text = MinigameData.PROMPTS_TEXT[val]
	minigame_container.add_child(new_minigame)


func kill_minigame() -> void:
	queue_free()


func deactivate_minigame() -> void:
	main_container.hide()
	minigame_icon.show()


func activate_minigame() -> void:
	main_container.show()
	minigame_icon.hide()


func _handle_autohack_made_available() -> void:
	if auto_hack.disabled:
		auto_hack.disabled = false


func _handle_autohack_used() -> void:
	if not auto_hack.disabled:
		auto_hack.disabled = true
