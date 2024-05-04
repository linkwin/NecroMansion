extends Node2D


signal level_transition(direction)

var level = 0
var level_dir = 0
var the_floor = preload("res://Maps/Random_Map.tscn").instance()

func _handle_floor_transition(dir, this_floor):
	level = max(0, level + dir)
	print("THIS FLOOR:  ", this_floor)
	print("THIS LEVEL:  ", level)
	
	for n in this_floor.get_children():
		this_floor.remove_child(n)
		n.queue_free() 
	remove_child(this_floor)
	this_floor.queue_free()
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	the_floor = preload("res://Maps/Random_Map.tscn").instance()
	the_floor.current_level = level
	add_child(the_floor)
	emit_signal("level_updated", 1)
	
	
	var goal_ui_scn = preload("res://UI/GoalScreen.tscn")
	var goal_scrn = goal_ui_scn.instance()
	get_tree().root.add_child(goal_scrn)
	print("HHHH")
	yield(get_tree().create_timer(2.0), "timeout")
	print("HHHH")
	get_tree().root.remove_child(goal_scrn)
	goal_scrn.queue_free()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	the_floor.map_set(self, level)
	add_child(the_floor)
	the_floor.current_level = level

func _process(delta):
	if level_dir != 0:
		print("LEVEL DIRECTION:  ", level_dir)
		_handle_floor_transition(level_dir, the_floor)
	yield(get_tree().create_timer(0.2), "timeout")
	level_dir = 0
	connect("next_floor", self, "_handle_floor_transition")
