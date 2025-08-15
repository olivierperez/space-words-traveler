class_name FloatingWord
extends RigidBody2D

signal word_became_inactive(word_instance)

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var speed: float = 50.0
var direction: Vector2 = Vector2.ZERO
var word: String = ""
var is_active: bool = true
var screen_center: Vector2

var _is_in_active_zone: bool = false

func _ready():
	# Animation d'apparition
	animation_player.play("fade_in")
	screen_center = Vector2.ZERO  # Le centre du jeu est maintenant en (0,0)

func _physics_process(delta):
	# Déplacer le mot vers le centre en utilisant move_and_collide
	var velocity = direction * speed
	move_and_collide(velocity * delta)
	
	# Vérifier si le mot est à moins de 100px du centre
	var distance_to_center = global_position.distance_to(screen_center)
	if distance_to_center < 100 and is_active:
		is_active = false
		word_became_inactive.emit(self)
		animation_player.play("fade_out")
		await animation_player.animation_finished
		queue_free()
	
	# Supprimer le mot s'il sort de l'écran (relatif au centre 0,0)
	var screen_size = get_viewport().get_visible_rect().size
	var half_width = screen_size.x / 2
	var half_height = screen_size.y / 2
	if global_position.x < -half_width - 200 or global_position.x > half_width + 200 or \
	   global_position.y < -half_height - 200 or global_position.y > half_height + 200:
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

func is_in_active_zone() -> bool:
	return _is_in_active_zone

func set_active():
	_is_in_active_zone = true

func _on_label_resized() -> void:
	if label == null: return
	var word_width = label.size.x
	var word_height = label.size.y
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(word_width, word_height)
	collision_shape.shape = rect_shape
