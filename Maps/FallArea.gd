extends Area2D




func _on_FallArea_body_entered(body):
	if "Player" in body.get_parent().name:
		body.fall()
