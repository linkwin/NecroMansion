extends Node2D

var _position = Vector2()

func _ready():
	init(_position)
	
func init(_position):
	position = _position
	var img_size = $Sprite.texture.get_size().x / 2
	$Sprite.scale = Vector2(1, 1) * 0.5
	
