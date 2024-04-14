extends Area2D

export var transition_dir = Vector2.ZERO

func _ready():
	connect("body_entered", self, "_overlap_entered")
	
func _overlap_entered(body):
	if "Player" in body.get_parent().name:
		body.get_parent().trigger_transition(transition_dir)
