extends Resource
class_name CharacterData

export var sprite_sheet : Texture
export var sprite_offset := Vector2(0,0)
export var sprite_scale := Vector2(1,1)
export var init_region_rect := Rect2(Vector2(0,0), Vector2(0,0))
export var anim_prefix := ""
export var anim_dirs := {
	Vector2(-1,0):"left",
	Vector2(1,0):"right", 
	Vector2(0,1):"back",
	Vector2(0,-1):"forward",
}
