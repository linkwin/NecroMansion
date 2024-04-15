extends Node2D

onready var character_ref = $CharacterBody

var Enemy_group = preload("res://Core/AI/EnemyGroup0.tscn")

var map_data
var map_datas
var curr_room = Vector2.ZERO
var previous_room = Vector2.ZERO

var input_enabled = true
var respawn_screen_node
var visited_rooms = []
var enemy_groups = {}
var dead_enemies = []

var familiars = []

var move_actions = ["move_left", "move_right", "move_forward", "move_back"]

var click_flag = false
var last_button = ""

func enemy_load(en_grp, room, enemy_number, enemy_data):
	var new_enemy = preload("res://Core/AI/AIController.tscn")
	var new_enemy_node
	var this_spec_enemy_data = {}
	new_enemy_node = new_enemy.instance()
	new_enemy_node.connect("enemy_defeated", self, "_handle_enemy_defeated", [new_enemy_node, room])
	
	new_enemy_node.enemy_number = enemy_number
	new_enemy_node.current_room = room
	#if [enemy_number, room] in invalid_enemies:
	#	new_enemy_node.queue_free()
	#	pass
		
	for key in enemy_data:
		this_spec_enemy_data[key] = enemy_data[key][enemy_number]
		
	new_enemy_node.enemy_data = this_spec_enemy_data
	
	new_enemy_node.position =  2000*room +  500 * Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	if not ([room, enemy_number] in dead_enemies):
		en_grp.call_deferred("add_child", new_enemy_node)
	#en_grp.add_child(new_enemy_node)

func add_familiar(node_ref):
	if !familiars.has(node_ref):
		familiars.append(node_ref)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
func _check_double_click_sprint():
	for action in move_actions:
		if Input.is_action_just_pressed(action):
			if click_flag and action == last_button:
				print("double click")
				$CharacterBody.set_sprint(true)
				click_flag = false
			else:
				click_flag = true
				last_button = action
				get_tree().create_timer(0.2).connect("timeout", self, "_double_click_timeout")

func enemy_group_unload(room):
	enemy_groups["EnemyGroup"+str(room)].queue_free()
	

func enemy_group_load(room):
	print(visited_rooms)
	if room in visited_rooms:
		print("Discovered Room")
		#enemy_groups["EnemyGroup"+str(room)].set_process(true)
		get_tree().root.add_child(enemy_groups["EnemyGroup"+str(room)])
	if not (room in visited_rooms):
		print("New Room")
		var en_grp = Enemy_group.instance()
		
		get_tree().root.call_deferred("add_child", en_grp)
		#get_tree().root.add_child(en_grp)
		en_grp.name = "EnemyGroup"+str(room)
		enemy_groups["EnemyGroup"+str(room)] = en_grp
		
		
#func _enemy_load_timer():
#	enemy_room_load(Vector2(0, 0))
#	var en_grp = enemy_groups["EnemyGroup"+str(Vector2(0, 0))]
#	var num_of_enemies_in_room = len(enemy_data["Enemy Seeds"])
#	for en_num in range(num_of_enemies_in_room):
#		enemy_load(en_grp, curr_room, en_num, enemy_data)
		
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#get_tree().create_timer(0.1).connect("timeout", self, "_enemy_load_timer")

func _double_click_timeout():
	click_flag = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !input_enabled:
		return
	
	_check_double_click_sprint()
	
	var move_h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var move_v_input = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	
	if _is_input_held():
		if not $CharacterBody/FootstepSound.playing:
			$CharacterBody/FootstepSound.play()
	else:
		$CharacterBody/FootstepSound.stop()
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
	
func _handle_enemy_defeated(enemy_node, curr_room):
	var enemy_number = enemy_node.enemy_number
	dead_enemies.append([curr_room, enemy_number])
	
func trigger_transition(dir, node):
	print("Current Room: ", curr_room)
	print("Current Visited Room List: ", visited_rooms)
	var next_room_pos = curr_room + dir
	var next_room = map_data.get_node("Room" + str(next_room_pos))
	if next_room:
		var spawn_point = next_room.position - dir * 750
		$CharacterBody.global_position = spawn_point
		for fam in familiars:
			fam.get_node("CharacterBody").global_position = spawn_point
		previous_room = curr_room
		curr_room = next_room_pos
		#map_data.load_next_room(next_room)
		var curr_room_index
		for room_indx in range(len(map_data.map)):
			if curr_room == map_data.map[room_indx]:
				curr_room_index = room_indx
		
		
		enemy_group_unload(previous_room)
		enemy_group_load(curr_room)
		
		
		var enemy_data = map_data.map_datas[curr_room_index]["Enemy Data"]
		var en_grp = enemy_groups["EnemyGroup"+str(curr_room)]
		var num_of_enemies_in_room = len(enemy_data["Enemy Seeds"])
		
		if not (previous_room in visited_rooms):
			visited_rooms.append(previous_room)
		if not (curr_room in visited_rooms):
			visited_rooms.append(curr_room)
		
		for en_num in range(num_of_enemies_in_room):
			enemy_load(en_grp, curr_room, en_num, enemy_data)
		print("Next Room: ", next_room_pos)
		print("Next Visited Room List: ", visited_rooms)
		print("")
		print("")
		print("----------------------------------")
	
func map_set(map, datas):
	map_data = map
	map_datas = datas
	curr_room = Vector2.ZERO

func _on_Health_damaged():
	$CharacterBody/HitSound.play()
