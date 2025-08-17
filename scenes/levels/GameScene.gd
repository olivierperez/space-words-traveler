extends Node2D

@onready var word_spawn_timer: Timer = $WordSpawnTimer
@onready var word_container: Node2D = $WordContainer
@onready var current_input_label: Label = $UI/CurrentInputLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var score_bar: ScoreBar = $UI/ScoreBar
@onready var active_zone: Area2D = $GameZones/ActiveZone

var word_scene = preload("res://scenes/levels/FloatingWord.tscn")
var words = ["ATTAQUER", "DEFENDRE", "BOUCLIER", "PLANETE", "VAISSEAU", "CIVILISATION", "SURVIVRE", "VOYAGER", "MOTS", "LUNETTES", "FAIBLESSE", "CHARGER", "CREATURES", "HABITE", "HABITABLE"]

var screen_size: Vector2
var current_input: String = ""
var active_words: Array = []
var total_score: int = 0

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	word_spawn_timer.timeout.connect(_spawn_word)
	word_spawn_timer.start()
	
	active_zone.body_entered.connect(_body_entered)
	active_zone.body_exited.connect(_body_exited)
	
	set_process_input(true)
	_update_score_display()

func _spawn_word():
	var word_instance: FloatingWord = word_scene.instantiate()
	word_container.add_child(word_instance)
	
	# Choisir un mot aléatoire
	var random_word = words[randi() % words.size()]
	word_instance.set_word(random_word)
	
	# Positionner le mot sur un bord aléatoire de l'écran
	var spawn_position = _get_random_border_position()
	word_instance.global_position = spawn_position
	
	# Définir la direction vers le centre (0,0)
	var center = Vector2.ZERO
	var direction = (center - spawn_position).normalized()
	word_instance.set_direction(direction)
	
	# Ajouter le mot à la liste des mots actifs
	active_words.append(word_instance)
	
	# Connecter le signal pour être notifié quand le mot devient inactif
	word_instance.word_became_inactive.connect(_on_word_became_inactive)

func _get_random_border_position() -> Vector2:
	var side = randi() % 4  # 0: haut, 1: droite, 2: bas, 3: gauche
	
	# Calculer les positions relatives au centre (0,0)
	var half_width = screen_size.x / 2
	var half_height = screen_size.y / 2

	match side:
		0:  # Haut
			return Vector2(randf_range(-half_width, half_width), -half_height - 50)
		1:  # Droite
			return Vector2(half_width + 50, randf_range(-half_height, half_height))
		2:  # Bas
			return Vector2(randf_range(-half_width, half_width), half_height + 50)
		3:  # Gauche
			return Vector2(-half_width - 50, randf_range(-half_height, half_height))
	
	return Vector2.ZERO

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
	
	# Vérifier si le mot saisi correspond à un mot actif ET dans la zone active
	for word_instance in active_words:
		if word_instance.is_word_active() and word_instance.is_in_active_zone() and word_instance.get_word() == current_input:
			# Mot trouvé ! Ajouter les points et le supprimer
			var points = word_instance.get_points()
			total_score += points
			active_words.erase(word_instance)
			word_instance.queue_free()
			print("Mot correctement tapé : ", current_input, " (+", points, " points)")
			_update_score_display()
			return
	
	# Vérifier si le mot existe mais n'est pas dans la zone active
	for word_instance in active_words:
		if word_instance.is_word_active() and word_instance.get_word() == current_input and not word_instance.is_in_active_zone():
			print("Mot trop loin ! Attendez qu'il entre dans la zone grise.")
			return
	
	print("Mot incorrect ou déjà disparu : ", current_input)

func _update_score_display():
	score_label.text = str(total_score)
	# Ajuster le pivot au centre du texte après le changement
	score_label.pivot_offset = score_label.size / 2
	_pulse_score_animation()
	
	# Update the ScoreBar
	score_bar.set_value(total_score)

func _pulse_score_animation():
	# Animation de pulse avec Tween
	var tween = create_tween()
	
	# Agrandir le score, puis revenir à la taille normale
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)



func _body_entered(body: RigidBody2D) -> void:
	if body is FloatingWord:
		body.set_active()

func _body_exited(body: RigidBody2D) -> void:
	if body is FloatingWord:
		body.set_inactive()

func _on_word_became_inactive(word_instance):
	active_words.erase(word_instance)
