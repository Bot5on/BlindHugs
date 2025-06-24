extends Control

# Получаем ссылку на наш AnimationPlayer
@onready var animation_player = $AnimationPlayer
@onready var animation_player2 = $AnimationPlayer2

func _ready():
	# Подключаем сигналы кнопок
	$RepeatButton.pressed.connect(_on_start_button_pressed)
	$ExitButton.pressed.connect(_on_exit_button_pressed)
	
	animation_player.play("appear")
	animation_player2.play("pulse")

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
