class_name SurveillanceLevels extends MarginContainer

@onready var circle_surveillance_level: TextureProgressBar = %CircleSurveillanceLevel
@onready var square_surveillance_level: TextureProgressBar = %SquareSurveillanceLevel
@onready var diamond_surveillance_level: TextureProgressBar = %DiamondSurveillanceLevel
@onready var circle_surveillance_container: HBoxContainer = %CircleSurveillanceContainer
@onready var square_surveillance_container: HBoxContainer = %SquareSurveillanceContainer
@onready var diamond_surveillance_container: HBoxContainer = %DiamondSurveillanceContainer

@onready var overload_level: TextureProgressBar = %OverloadLevel

@onready var container_lookup: Dictionary = {
	PuzzleNode.IconType.CIRCLE: {
		"container": circle_surveillance_container,
		"progress_bar": circle_surveillance_level
	},
	PuzzleNode.IconType.SQUARE: {
		"container": square_surveillance_container,
		"progress_bar": square_surveillance_level
	},
	PuzzleNode.IconType.DIAMOND: {
		"container": diamond_surveillance_container,
		"progress_bar": diamond_surveillance_level
	}
}


func _ready() -> void:
	GameControl.overload_activated.connect(_handle_overload_activated)
	GameControl.overload_exhausted.connect(_handle_overload_exhausted)


func _process(delta: float) -> void:
	circle_surveillance_level.value = GameControl.detection_lookup[PuzzleNode.IconType.CIRCLE]["level"]
	square_surveillance_level.value = GameControl.detection_lookup[PuzzleNode.IconType.SQUARE]["level"]
	diamond_surveillance_level.value = GameControl.detection_lookup[PuzzleNode.IconType.DIAMOND]["level"]
	
	overload_level.value = GameControl.overload_level


func _handle_overload_activated(icon_type) -> void:
	container_lookup[icon_type]["container"].modulate = Color.GRAY


func _handle_overload_exhausted() -> void:
	for icon_type in container_lookup:
		container_lookup[icon_type]["container"].modulate = PuzzleNode.COLOR_LOOKUP[icon_type]["active"]
