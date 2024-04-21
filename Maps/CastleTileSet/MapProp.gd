extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = clamp(global_position.y,VisualServer.CANVAS_ITEM_Z_MIN,VisualServer.CANVAS_ITEM_Z_MAX)
	Global.connect("room_updated", self, "_update_z_index")
	
func _update_z_index(origin):
	z_index = clamp(global_position.y - origin.y,VisualServer.CANVAS_ITEM_Z_MIN,VisualServer.CANVAS_ITEM_Z_MAX)


func _on_Area2D_body_entered(body):
	if "Player" in body.get_parent().name:
		var goal_ui_scn = preload("res://UI/GoalScreen.tscn")
		get_tree().root.add_child(goal_ui_scn.instance())
