extends Control

func _on_PlayButton_pressed():
	$CanvasLayer/TitleScreen.queue_free()
	var seed_screen = preload("res://UI/StartGameScreen.tscn")
	$CanvasLayer.add_child(seed_screen.instance())

func _on_ExitButton_pressed():
	get_tree().quit()
