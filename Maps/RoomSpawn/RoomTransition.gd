extends Area2D

export var transition_dir = Vector2.ZERO
var enabled = true

func _ready():
	connect("body_entered", self, "_overlap_entered")
	
func _debounce_timer():
	enabled = true
	
func _overlap_entered(body):
	if "Player" in body.get_parent().name and enabled:
		enabled = false
		get_tree().create_timer(0.2).connect("timeout", self, "_debounce_timer")
		body.get_parent().trigger_transition(transition_dir, self)
