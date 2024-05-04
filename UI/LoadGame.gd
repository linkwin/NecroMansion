extends Control

func load_game():
	Global.seed_text = $VBoxContainer/LineEdit.text
	get_tree().change_scene("res://Maps/Whole_World.tscn")
	

func _on_PlayButton_pressed():
	pass # Replace with function body.
