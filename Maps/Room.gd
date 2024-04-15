extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	if randf() < 0.2:
		$Familiar.queue_free()


