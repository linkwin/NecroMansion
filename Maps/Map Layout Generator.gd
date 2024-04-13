extends Area2D


var ARoom = preload("res://Maps/MiniMapBlocks/Rooms.tscn")

export(RoomData) var Roomdata = preload("res://Maps/RoomData/roomdata1.tres")

var directions := [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]

var init_seed



func array_mult(in_array, inger):
	var out_array := []
	print(inger)
	for i in range(inger):
		for j in in_array:
			out_array.append(j)
	return(out_array)

func spawn_room(_position, color_param=1):
	var c = ARoom.instance()
	add_child(c)
	c.init(_position, color_param)




# prob_dist will have the relative prob. of each occurence 
# per room-property per room
# Example: prob_dists = [ [[1, 4], [1, 3, 3, 3]], [[1, 1], [2, 0, 6, 3]]] , [ [[ ...
#                       (Room 1-  (Property 1- ((Rel Prob 1, Rel Prob 2), ...), ... )    
# Need to be sure these arrays match in size

func room_data_load(map, initial_seed, prob_dists):
	var room_prop_rng = RandomNumberGenerator.new()
	var map_data := []
	room_prop_rng.seed = initial_seed + 200
	var i := 0
	for rooms in prob_dists:
		var room_data := []
		for dist in rooms:
			var repeated_sample_dist := []
			var sample_index
			for sample in range(len(dist)):
				print("Sample: ", sample)
				print("dist[Sample]: ", dist[sample])
				repeated_sample_dist += array_mult([sample], dist[sample])
			room_prop_rng.seed = init_seed+i
			sample_index = room_prop_rng.randi_range(0, len(repeated_sample_dist)-1)
			room_data.append(repeated_sample_dist[sample_index])
			i += 1
		i += 20
		map_data.append(room_data)
	print("MAP DATA: ", map_data)
	return(map_data)




func navigation_load(map, directions):
	var map_nav := []
	for room in map:
		var poss_dir := []
		for dir in directions:
			if room+dir in map:
				poss_dir.append(dir)
		map_nav.append(poss_dir)
	#print("DOOR DIRECTIONS: ", map_nav)
	return(map_nav)

# Called when the node enters the scene tree for the first time.
func _ready():
	var init_seed = Roomdata.seed_gen()
	var room_rng = RandomNumberGenerator.new()
	var num_rooms := 15
	var map := []
	var map_navi := []
	var map_datas := []
	room_rng.seed = init_seed
	var current_position = Vector2(0,0)
	var new_direction = Vector2()
	var i = 0
	while len(map) <= num_rooms-1:
		if not (current_position in map):
			map.append(current_position)
			spawn_room(current_position, i)
		room_rng.seed = init_seed+i
		new_direction = directions[room_rng.randi_range(0, 3)]
		current_position += new_direction
		i += 1
	print("MAP COORDINATES: ", map)
	print("")
	map_navi = navigation_load(map, directions)
	map_datas = room_data_load(map, init_seed, array_mult([[[1, 1], [1, 2]]], num_rooms) )
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass[    [[5 3 2], [10 4 1], [1 1 1 1 1 1], ... 
