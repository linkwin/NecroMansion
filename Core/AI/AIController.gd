extends Node2D

var curr_move_dir = Vector2.ZERO
onready var character_ref = $CharacterBody
onready var timer = $Timer

func _ready():
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()

func _process(delta):
	print(curr_move_dir)
	character_ref.add_move_input(curr_move_dir)

func _on_Timer_timeout():
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
