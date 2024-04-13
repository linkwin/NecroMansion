extends Area2D

var rng = RandomNumberGenerator.new()

var ARoom = preload("res://Maps/MiniMapBlocks/Rooms.tscn")

var init_seed := hash("Super Duper Cool")
var num_rooms := 15

var direction := [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
var map := []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func spawn_room(_position=null):
	var c = ARoom.instance()
	add_child(c)
	c.init(_position)

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.seed = init_seed
	var current_position = Vector2(0,0)
	var new_direction = Vector2()
	var i = 0
	while len(map) <= num_rooms:
		if not (current_position in map):
			map.append(current_position)
		rng.seed = init_seed+i
		new_direction = direction[rng.randi_range(0, 3)]
		current_position += 50*new_direction
		i += 1
	print(map)
	
	for new_room in map:
		spawn_room(new_room)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
