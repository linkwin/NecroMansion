extends Node2D

onready var character_ref = $CharacterBody

var map_data
var curr_room = Vector2.ZERO
var current_map = preload("res://Maps/Map Layout Generator.gd")

var input_enabled = true
var respawn_screen_node
	

func enemy_load(room, enemy_number):
	var new_enemy = preload("res://Core/AI/AIController.tscn")
	var new_enemy_node
	new_enemy_node = new_enemy.instance()
	new_enemy_node.enemy_number = enemy_number
	new_enemy_node.current_room = room
	new_enemy_node.position =  2000*room +  500 * Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	get_tree().root.add_child(new_enemy_node)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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
		character_ref.global_position = next_room.position
		curr_room = next_room_pos
		#map_data.load_next_room(next_room)
		var curr_room_index
		for room_indx in range(len(map_data.map)):
			if curr_room == map_data.map[room_indx]:
				curr_room_index = room_indx
		var num_of_enemies_in_room = len(map_data.map_datas[curr_room_index]["Enemy Data"]["Enemy Seeds"])
		for en_num in range(num_of_enemies_in_room):
			enemy_load(curr_room, en_num)

func map_set(map):
	map_data = map
	curr_room = Vector2.ZERO



