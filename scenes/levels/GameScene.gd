extends Node2D

@onready var word_spawn_timer: Timer = $WordSpawnTimer
@onready var word_container: Node2D = $WordContainer
@onready var back_button: Button = $UI/BackButton

var word_scene = preload("res://scenes/levels/FloatingWord.tscn")
var words = ["ATTACK", "DEFEND", "SHIELD", "PLANET", "SPACESHIP", "CIVILIZATION", "SURVIVE", "TRAVEL", "WORDS", "GLASSES", "WEAKNESS", "CHARGE", "MOBS", "INHABITED", "LIVEABLE"]

var screen_size: Vector2

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	word_spawn_timer.timeout.connect(_spawn_word)
	word_spawn_timer.start()
	back_button.pressed.connect(_on_back_button_pressed)

func _spawn_word():
	var word_instance = word_scene.instantiate()
	word_container.add_child(word_instance)
	
	# Choisir un mot aléatoire
	var random_word = words[randi() % words.size()]
	word_instance.set_word(random_word)
	
	# Positionner le mot sur un bord aléatoire de l'écran
	var spawn_position = _get_random_border_position()
	word_instance.global_position = spawn_position
	
	# Définir la direction vers le centre
	var center = screen_size / 2
	var direction = (center - spawn_position).normalized()
	word_instance.set_direction(direction)

func _get_random_border_position() -> Vector2:
	var side = randi() % 4  # 0: haut, 1: droite, 2: bas, 3: gauche
	
	match side:
		0:  # Haut
			return Vector2(randf_range(0, screen_size.x), -50)
		1:  # Droite
			return Vector2(screen_size.x + 50, randf_range(0, screen_size.y))
		2:  # Bas
			return Vector2(randf_range(0, screen_size.x), screen_size.y + 50)
		3:  # Gauche
			return Vector2(-50, randf_range(0, screen_size.y))
	
	return Vector2.ZERO

func _on_back_button_pressed():
	SceneTransition.change_scene("res://scenes/menus/main/MainMenu.tscn")
