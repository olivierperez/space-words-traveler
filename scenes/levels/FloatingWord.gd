extends Node2D

signal word_became_inactive(word_instance)

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var speed: float = 50.0
var direction: Vector2 = Vector2.ZERO
var word: String = ""
var is_active: bool = true
var screen_center: Vector2

func _ready():
	# Animation d'apparition
	animation_player.play("fade_in")
	screen_center = get_viewport().get_visible_rect().size / 2

func _process(delta):
	# Déplacer le mot vers le centre
	global_position += direction * speed * delta
	
	# Vérifier si le mot est à moins de 100px du centre
	var distance_to_center = global_position.distance_to(screen_center)
	if distance_to_center < 100 and is_active:
		is_active = false
		word_became_inactive.emit(self)
		animation_player.play("fade_out")
		await animation_player.animation_finished
		queue_free()
	
	# Supprimer le mot s'il sort de l'écran
	var screen_size = get_viewport().get_visible_rect().size
	if global_position.x < -200 or global_position.x > screen_size.x + 200 or \
	   global_position.y < -200 or global_position.y > screen_size.y + 200:
		queue_free()

func set_word(new_word: String):
	word = new_word
	label.text = word

func set_direction(new_direction: Vector2):
	direction = new_direction

func is_word_active() -> bool:
	return is_active

func get_word() -> String:
	return word
