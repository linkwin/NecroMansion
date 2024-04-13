extends Node2D

onready var character_ref = $CharacterBody

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var move_h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var move_v_input = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	
	character_ref.add_move_input(Vector2(move_h_input, move_v_input).normalized())

func _is_input_held():
	return Input.get_action_strength("move_right") != 0 or Input.get_action_strength("move_left") != 0 \
		or Input.get_action_strength("move_back") != 0 or Input.get_action_strength("move_forward") != 0
