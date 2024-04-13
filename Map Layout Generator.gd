extends Node

var rng = RandomNumberGenerator.new()
rng.seed = hash("Godot")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():

	var my_random_number = rng.randf_range(-10.0, 10.0)
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
