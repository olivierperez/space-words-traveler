extends Control

@onready var quit_dialog = %QuitDialog
@onready var start_button: Button = %StartButton
@onready var levels_container: GridContainer = %LevelsContainer


func _ready():
	ProgressionService.init()
	_add_levels_button()


func _on_start_button_pressed(level: int):
	LevelConfig.set_level(level)
	SceneTransition.change_scene("res://scenes/levels/GameScene.tscn")


func _on_credits_button_pressed():
	SceneTransition.change_scene("res://scenes/menus/credits/CreditsMenu.tscn")


func _on_quit_button_pressed():
	_ask_to_confirm_quit()


func _on_quit_dialog_confirmed():
	get_tree().quit()


func _ask_to_confirm_quit():
	quit_dialog.pop_in()


func _add_levels_button() -> void:
	var progression = ProgressionService.data
	prints("progression", progression.level_reached)
	for level in 20:
		prints("level", level)
		var human_level = level + 1
		var button = Button.new()
		button.text = str(human_level)
		button.pressed.connect(_on_start_button_pressed.bind(level))
		if level > progression.level_reached:
			button.disabled = true
		levels_container.add_child(button)
	
	levels_container.get_child(0).grab_focus()
