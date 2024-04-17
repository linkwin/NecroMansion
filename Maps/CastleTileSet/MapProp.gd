extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = global_position.y
	Global.connect("room_updated", self, "_update_z_index")
	
func _update_z_index(origin):
	z_index = global_position.y - origin.y


func _on_Area2D_body_entered(body):
	if "Player" in body.get_parent().name:
		var goal_ui_scn = preload("res://UI/GoalScreen.tscn")
		get_tree().root.add_child(goal_ui_scn.instance())
