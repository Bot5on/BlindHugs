extends Node2D

@onready var player1 = $Player
@onready var player2 = $Player2
@onready var echo_renderer = $EchoRenderer


func _ready():
	player1.player_id = 1
	player1.ray_color = Color.DEEP_SKY_BLUE

	player2.player_id = 2
	player2.ray_color = Color.HOT_PINK

	if echo_renderer.has_method("set_players"):
		echo_renderer.set_players([player1, player2])

	player1.step_taken.connect(echo_renderer.create_effect)
	player2.step_taken.connect(echo_renderer.create_effect)

	player1.get_node("Area2D").area_entered.connect(_on_player_meet.bind(player1))
	player2.get_node("Area2D").area_entered.connect(_on_player_meet.bind(player2))

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_player_meet(other_area):
	get_tree().change_scene_to_file("res://scenes/victory_screen.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
