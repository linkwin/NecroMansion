extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = global_position.y
	Global.connect("room_updated", self, "_update_z_index")
	
func _update_z_index(origin):
	z_index = global_position.y - origin.y
