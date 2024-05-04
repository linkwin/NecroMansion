extends Node2D

signal next_floor(ref)

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = clamp(global_position.y,VisualServer.CANVAS_ITEM_Z_MIN,VisualServer.CANVAS_ITEM_Z_MAX)
	Global.connect("room_updated", self, "_update_z_index")
	
func _update_z_index(origin):
	z_index = clamp(global_position.y - origin.y,VisualServer.CANVAS_ITEM_Z_MIN,VisualServer.CANVAS_ITEM_Z_MAX)

func _on_timer_timeout_funcname(body, goal_scrn) -> void:
	get_tree().root.remove_child(goal_scrn)
	queue_free() # removes this node from scene
	pass

func _on_Area2D_body_entered(body):
	if "Player" in body.get_parent().name:
		emit_signal("next_floor", self)
		get_parent().get_parent().level_dir = 1
		Global.emit_signal("level_updated", 1)
		
		
