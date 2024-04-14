extends Node2D


var ARoom = preload("res://Maps/Room.tscn")

export(Resource) var Roomdata = preload("res://Maps/RoomData/roomdata1.tres")
var directions := [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]

var init_seed
var probabilities

var num_rooms := 15
var map := []
var map_navi := []
var map_datas := []

var player_room = Vector2(0,0)

func array_mult(in_array, inger):
	var out_array := []
	if inger == 1:
		out_array = in_array
	if inger > 2:
		for _i in range(inger):
			for j in in_array:
				out_array.append(j)
	return(out_array)
	
func random_sample(distribution, my_seed):
	var repeated_sample_dist = []
	var sample_index
	var random_sample_rng = RandomNumberGenerator.new()
	for sample in range(len(distribution)):		
		repeated_sample_dist += array_mult([sample], distribution[sample])
	random_sample_rng.seed = my_seed
	sample_index = random_sample_rng.randi_range(0, len(repeated_sample_dist)-1)
	return(repeated_sample_dist[sample_index])

func spawn_room(_position):
	var c = ARoom.instance()
	c.position = _position * 2000
	add_child(c)	
	c.name = "Room"+str(_position)


	#c.init(_position, color_param)




# prob_dist will have the relative prob. of each occurence 
# per room-property per room
# Example: prob_dists = [ [[1, 4], [1, 3, 3, 3]], [[1, 1], [2, 0, 6, 3]]] , [ [[ ...
#                       (Room 1-  (Property 1- ((Rel Prob 1, Rel Prob 2), ...), ... )    
# Need to be sure these arrays match in size

func room_data_load(initial_seed, prob_dists, number_of_rooms):
	print("Initial Seed: ", initial_seed)
	var map_data := []
	var seed_shift := 0
	for _room in range(number_of_rooms):
		
		var difficulty_dists := {
			"Enemy Speed": [[5, 4, 1, 0, 0, 0, 0], [2, 5, 3, 1, 0, 0, 0], 
							[1, 2, 4, 2, 1, 0, 0], [0, 1, 2, 5, 3, 2, 1], [0, 0, 1, 2, 5, 5, 4]],
			"Enemy Damage": [[2, 1, 0], [2, 1, 0], [1, 2, 1], [0, 1, 2], [0, 1, 2]],
			"Enemy Recovery": [[5, 4, 1, 0, 0, 0], [2, 5, 3, 1, 0, 0], 
							[1, 2, 4, 2, 1, 0], [1, 2, 5, 3, 2, 1], [0, 1, 2, 5, 5, 4]],
			"Enemy Attack Radius": [[5, 4, 1, 0, 0, 0, 0, 0], [1, 5, 5, 1, 0, 0, 0, 0], 
							[0, 0, 1, 5, 5, 1, 0, 0], [0, 0, 0, 1, 3, 3, 2, 0], [0, 0, 0, 0, 1, 1, 5, 4]]
		}
		
		var difficulty_conversions := {
			"Enemy Speed": [10000, 10500, 11000, 11500, 12000, 12500, 13000],
			"Enemy Damage": [1, 2, 3],
			"Enemy Recovery": [1.5, 1.3, 1.1, 0.9, 0.7, 0.5],
			"Enemy Attack Radius": [150, 200, 250, 300, 350, 400, 450, 450]
		}
		
		var room_properties := {
			"Enemy Data": {"Enemy Seeds": [], "Enemy Difficulty": [], "Enemy Class": [],
							"Enemy Speed": [], "Enemy Damage": [], "Enemy Recovery": [], "Enemy Attack Radius": []},
			"Item Data": {"Item Seeds": [], "Item Strength": [], "Item Class": []},
			"Room Decoration Data": {"Room Seed": 0, "Room Type": 0}
		}
		
		var number_of_enemies = random_sample(prob_dists["Initial Number of Enemies"], init_seed+seed_shift)
		
		for enemy in range(number_of_enemies):
			var Enemy_Difficulty = random_sample(prob_dists["Initial Enemy Difficulty"], init_seed + seed_shift + enemy + 40)
			room_properties["Enemy Data"]["Enemy Seeds"].append(init_seed + seed_shift + enemy + 20)  
			room_properties["Enemy Data"]["Enemy Difficulty"].append(Enemy_Difficulty)
			room_properties["Enemy Data"]["Enemy Class"].append(random_sample(prob_dists["Initial Enemy Class"], init_seed + seed_shift + enemy + 60))
			room_properties["Enemy Data"]["Enemy Speed"].append(difficulty_conversions["Enemy Speed"][random_sample(difficulty_dists["Enemy Speed"][Enemy_Difficulty], init_seed + seed_shift + enemy + 80)])
			room_properties["Enemy Data"]["Enemy Damage"].append(difficulty_conversions["Enemy Damage"][random_sample(difficulty_dists["Enemy Damage"][Enemy_Difficulty], init_seed + seed_shift + enemy + 100)])
			room_properties["Enemy Data"]["Enemy Recovery"].append(difficulty_conversions["Enemy Recovery"][random_sample(difficulty_dists["Enemy Recovery"][Enemy_Difficulty], init_seed + seed_shift + enemy + 120)])
			room_properties["Enemy Data"]["Enemy Attack Radius"].append(difficulty_conversions["Enemy Attack Radius"][random_sample(difficulty_dists["Enemy Attack Radius"][Enemy_Difficulty], init_seed + seed_shift + enemy + 140)])
		
		var number_of_items = random_sample(prob_dists["Initial Number of Enemies"], init_seed+seed_shift)
		
		for item in range(number_of_items):
			room_properties["Item Data"]["Item Seeds"].append(init_seed + item + 25)  
			room_properties["Item Data"]["Item Strength"].append(random_sample(prob_dists["Initial Item Strength"], init_seed + seed_shift + item + 45))
			room_properties["Item Data"]["Item Class"].append(random_sample(prob_dists["Initial Item Class"], init_seed + seed_shift + item + 65))
			
		room_properties["Room Decoration Data"]["Room Seed"] = init_seed + seed_shift + 655
		room_properties["Room Decoration Data"]["Room Type"] = random_sample(prob_dists["Room Design"], init_seed + seed_shift + 656)
		
		for i in range(len(prob_dists["Initial Number of Enemies"])):
			prob_dists["Initial Number of Enemies"][i] += 1
			
		for i in range(len(prob_dists["Initial Enemy Difficulty"])):
			prob_dists["Initial Enemy Difficulty"][i] += 1
			
		for i in range(len(prob_dists["Initial Item Strength"])):
			prob_dists["Initial Item Strength"][i] += 1
		
		seed_shift += 2000
		map_data.append(room_properties)
	return(map_data)




func navigation_load(current_map, cardinal_directions):
	var map_nav := []
	for room in current_map:
		var poss_dir := []
		for dir in cardinal_directions:
			if room+dir in current_map:
				poss_dir.append(dir)
		map_nav.append(poss_dir)
	return(map_nav)

func enemy_load(room, enemy_number, enemy_data):
	var new_enemy = preload("res://Core/AI/AIController.tscn")
	var new_enemy_node
	var this_spec_enemy_data = {}
	new_enemy_node = new_enemy.instance()
	
	new_enemy_node.enemy_number = enemy_number
	new_enemy_node.current_room = room
	
	for key in enemy_data:
		this_spec_enemy_data[key] = enemy_data[key][enemy_number]
		
	new_enemy_node.enemy_data = this_spec_enemy_data
	
	new_enemy_node.position =  2000*room +  500 * Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	add_child(new_enemy_node)

# Called when the node enters the scene tree for the first time.
func _ready():
	init_seed = Roomdata.seed_gen() +1 
	probabilities = Roomdata.probabilities
	var room_rng = RandomNumberGenerator.new()

	room_rng.seed = init_seed
	var current_position = Vector2(0,0)
	var new_direction = Vector2()
	var i = 0
	while len(map) <= num_rooms-1:
		if not (current_position in map):
			map.append(current_position)
			spawn_room(current_position)
		room_rng.seed = init_seed+i
		new_direction = directions[room_rng.randi_range(0, 3)]
		current_position += new_direction
		i += 1
	map_navi = navigation_load(map, directions)
	map_datas = room_data_load(init_seed, probabilities, num_rooms)
	
	var player = load("res://Core/Player/PlayerController.tscn").instance()
	add_child(player)
	player.map_set(self)	
	
	var enemy_data = map_datas[0]["Enemy Data"]
	var num_of_enemies_in_room = len(enemy_data["Enemy Seeds"])
	for en_num in range(num_of_enemies_in_room):
		enemy_load(Vector2(0,0), en_num, enemy_data)
	

#func _process(delta):
#	character_ref.add_move_input(curr_move_dir)
#	$CharacterBody/DEBUG_state.text = Global.BOT_STATE.keys()[bot_state] + "\n" \
#		+ Global.BOT_BEHAVIOR.keys()[bot_behavior]
