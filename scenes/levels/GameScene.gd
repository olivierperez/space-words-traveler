extends Node2D

@onready var word_spawn_timer: Timer = $WordSpawnTimer
@onready var word_container: Node2D = $WordContainer
@onready var back_button: Button = $UI/BackButton
@onready var current_input_label: Label = $UI/CurrentInputLabel

var word_scene = preload("res://scenes/levels/FloatingWord.tscn")
var words = ["ATTAQUER", "DEFENDRE", "BOUCLIER", "PLANETE", "VAISSEAU", "CIVILISATION", "SURVIVRE", "VOYAGER", "MOTS", "LUNETTES", "FAIBLESSE", "CHARGER", "CREATURES", "HABITE", "HABITABLE"]

var screen_size: Vector2
var current_input: String = ""
var active_words: Array = []

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	word_spawn_timer.timeout.connect(_spawn_word)
	word_spawn_timer.start()
	back_button.pressed.connect(_on_back_button_pressed)
	set_process_input(true)

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
	
	# Ajouter le mot à la liste des mots actifs
	active_words.append(word_instance)
	
	# Connecter le signal pour être notifié quand le mot devient inactif
	word_instance.word_became_inactive.connect(_on_word_became_inactive)

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

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			_check_word()
			current_input = ""
		elif event.keycode == KEY_BACKSPACE:
			current_input = current_input.substr(0, current_input.length() - 1)
		elif event.unicode > 0:
			current_input += char(event.unicode).to_upper()
		
		# Mettre à jour l'affichage de la saisie
		current_input_label.text = "Saisie : " + current_input

func _check_word():
	if current_input.is_empty():
		return
	
	# Vérifier si le mot saisi correspond à un mot actif
	for word_instance in active_words:
		if word_instance.is_word_active() and word_instance.get_word() == current_input:
			# Mot trouvé ! Le supprimer
			active_words.erase(word_instance)
			word_instance.queue_free()
			print("Mot correctement tapé : ", current_input)
			return
	
	print("Mot incorrect ou déjà disparu : ", current_input)

func _on_word_became_inactive(word_instance):
	# Retirer le mot inactif de la liste
	active_words.erase(word_instance)
