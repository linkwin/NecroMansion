extends Button

export var default_color : Color = self.modulate
export var hovered_color = Color.blue
export var pressed_color = Color.black

func _on_PlayButton_mouse_entered():
	$".".modulate = hovered_color

func _on_PlayButton_mouse_exited():
	$".".modulate = default_color

func _on_PlayButton_pressed():
	$".".modulate = pressed_color
