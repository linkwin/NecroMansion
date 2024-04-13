extends Node2D

var _position = Vector2()
var color_param = int()

func _ready():
	init(_position, color_param)
	
func init(_position, color_param):
	position = _position*33
	if _position == Vector2(0,0):
		$Polygon2D.color = Color(0, 0, 0, 1)
	else:
		$Polygon2D.color = Color(color_param*0.1, -color_param*0.1, color_param*0.1, color_param*0.1)
	var img_size = $Sprite.texture.get_size().x / 2
	$Sprite.scale = Vector2(1, 1) * 0.5
	
