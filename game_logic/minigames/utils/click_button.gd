class_name ClickButton extends Button

@onready var button_click_sound: AudioStreamPlayer = $ButtonClickSound

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	connect("button_down", on_button_down)


func on_button_down() -> void:
	button_click_sound.pitch_scale = rng.rand_range(0.9, 1.1)
	button_click_sound.play()
