class_name ScoreBar
extends TextureRect

@export var max_value: int = 50
@export var animation_duration: float = 0.5

@onready var progression: TextureRect = $Progression

var current_value: int = 0
var target_value: int = 0

func _ready():
	# Initialize the progression bar to 0
	_update_progression(0)

func set_value(new_value: int):
	target_value = min(new_value, max_value)
	_animate_to_target()

func _animate_to_target():
	if target_value == current_value:
		return
	
	var tween = create_tween()
	tween.tween_method(_update_progression, current_value, target_value, animation_duration)
	tween.tween_callback(_on_animation_complete)

func _update_progression(value: int):
	current_value = value
	var progress_ratio = float(current_value) / float(max_value)
	progression.size.x = progress_ratio * progression.texture.get_width()

func _on_animation_complete():
	current_value = target_value
