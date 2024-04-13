extends KinematicBody2D

signal on_character_collision(collider)

var move_dir = Vector2.ZERO

export var default_move_speed = 12000
var move_speed = 12000
var move_acc = 12
var friction = 1000

var velocity = Vector2.ZERO

var last_move_dir = Vector2.ZERO

func add_move_input(new_move_dir):
	move_dir = new_move_dir

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	
	var target_vel = move_speed * move_dir * delta
	
	var move_update_vel = Vector2.ZERO
	if move_dir != Vector2.ZERO:
		move_update_vel = target_vel
		last_move_dir = move_dir
	elif not _approx_equal(_abs_vec(velocity), Vector2.ZERO,0.1):
		move_update_vel = velocity - last_move_dir * friction * delta
	#if _abs_vec(velocity) <= _abs_vec(target_vel):
	#	move_update_vel = velocity + move_dir * move_acc
	#print(velocity)
	
	velocity = move_and_slide(move_update_vel)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if "Character" in collision.collider.name:
			emit_signal("on_character_collision", collision.collider)
	
func _approx_equal(a,b,tol=0.0001):
	var diff = Vector2(a.x - b.x, a.y - b.y)
	return diff.x <= tol and diff.y <= tol



func _abs_vec(v):
	return Vector2(abs(v.x), abs(v.y))
