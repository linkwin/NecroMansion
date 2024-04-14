extends Node2D

onready var character_ref = $CharacterBody

var map_data
var curr_room = Vector2.ZERO

var input_enabled = true
var respawn_screen_node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !input_enabled:
		return
	
	var move_h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var move_v_input = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	
	character_ref.add_move_input(Vector2(move_h_input, move_v_input).normalized())

func _is_input_held():
	return Input.get_action_strength("move_right") != 0 or Input.get_action_strength("move_left") != 0 \
		or Input.get_action_strength("move_back") != 0 or Input.get_action_strength("move_forward") != 0

func _on_CharacterBody_on_character_collision(collider):
	collider.get_node("Health").try_damage(1)

func _on_Health_death():
	if input_enabled:
		input_enabled = false
		var respawn_screen = preload("res://UI/RepawnScreen.tscn")
		respawn_screen_node = respawn_screen.instance()
		respawn_screen_node.get_node("Button").connect("pressed", self, "_do_respawn")
		get_tree().root.add_child(respawn_screen_node)
		

func _do_respawn():
	get_tree().reload_current_scene()
	respawn_screen_node.queue_free()
	
func trigger_transition(dir):
	var next_room_pos = curr_room + dir
	var next_room = map_data.get_node("Room" + str(next_room_pos))
	if next_room:
		$CharacterBody.global_position = next_room.position
		curr_room = next_room_pos
	#map_data.load_next_room(next_room)
	
func map_set(map):
	map_data = map
	curr_room = Vector2.ZERO
	
