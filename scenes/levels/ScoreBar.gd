class_name ScoreBar
extends TextureRect

@export var max_value: int = 50
@export var animation_duration: float = 0.5

@export var shield_1: int
@export var shield_2: int
@export var shield_3: int

@onready var progression: TextureRect = $Progression

var shield_instances: Array[TextureRect] = []
var shield_achieved: Array[bool] = [false, false, false]

var current_value: int = 0
var target_value: int = 0

func _ready():
	_create_shields()
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
	
	_check_shield_achievements(value)

func _on_animation_complete():
	current_value = target_value

func _create_shields():
	var shield_texture = preload("res://assets/image/shield.png")
	var shield_positions = [shield_1, shield_2, shield_3]
	
	for i in range(3):
		var shield = TextureRect.new()
		shield.texture = shield_texture
		shield.modulate = Color("#FFFFFFA0")
		
		var shield_size = shield_texture.get_size()
		var shield_pos_percent = float(shield_positions[i]) / float(max_value)
		shield.position.x = size.x * (shield_pos_percent) - (shield_size.x / 2.0)
		shield.position.y = (size.y / 2.0) - (shield_size.y / 2.0)
		shield.pivot_offset = shield_size / 2.0
		
		add_child(shield)
		shield_instances.append(shield)
		
func _check_shield_achievements(value: int):
	var shield_positions = [shield_1, shield_2, shield_3]
	
	for i in range(3):
		if not shield_achieved[i] and value >= shield_positions[i]:
			shield_achieved[i] = true
			_pulse_shield(i)

func _pulse_shield(shield_index: int):
	var shield = shield_instances[shield_index]
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Pulse
	tween.tween_property(shield, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(shield, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.2)
	
	# Shiny
	tween.tween_property(shield, "modulate", Color.WHITE, 0.2)
	tween.tween_property(shield, "modulate", Color("#FFFFFFA0"), 0.2).set_delay(0.2)
