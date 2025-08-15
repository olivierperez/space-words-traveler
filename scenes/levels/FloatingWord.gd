extends Node2D

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var speed: float = 100.0
var direction: Vector2 = Vector2.ZERO
var word: String = ""

func _ready():
	# Animation d'apparition
	animation_player.play("fade_in")

func _process(delta):
	# Déplacer le mot vers le centre
	global_position += direction * speed * delta
	
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
