extends KinematicBody2D

signal on_character_collision(collider)

var move_dir = Vector2.ZERO

export var default_move_speed = 12000
var move_speed = 12000
var move_acc = 12
var friction = 1000

var jump_impulse = 500
var jump_decel = 600
var wants_to_jump = false
var jump_update_vel = Vector2.ZERO

var grav_acc = 300
var grav_update_vel = Vector2.ZERO

var velocity = Vector2.ZERO

var last_move_dir = Vector2.ZERO

var anim_dirs := {
	Vector2(-1,0):"left", 
	Vector2(1,0):"right", 
	Vector2(0,1):"back",
	Vector2(0,-1):"forward",
}

func add_move_input(new_move_dir):
	move_dir = new_move_dir

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if move_dir != Vector2.ZERO:
		if anim_dirs.has(move_dir):
			$CollisionShape2D/Sprite/AnimationPlayer.play("player_character_walk_" + anim_dirs[move_dir])
	else:
		$CollisionShape2D/Sprite/AnimationPlayer.stop()
	
func _physics_process(delta):


	# =====MOVE======	
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
	
	# =====JUMP======
	#perform jump update
	if jump_update_vel != Vector2.ZERO:
		jump_update_vel = jump_update_vel + jump_decel * Vector2.DOWN * delta
		var d = jump_update_vel * delta
		$CollisionShape2D.position = $CollisionShape2D.position + d
		print(jump_update_vel)
	#check if at height of jump
	if _approx_equal(_abs_vec(jump_update_vel), Vector2.ZERO, 0.001):
		jump_update_vel = Vector2.ZERO
	#trigger jump
	if wants_to_jump:
		jump_update_vel = Vector2.UP * jump_impulse
		wants_to_jump = false
		collision_layer = 2
		collision_mask = 2
	
	#character is at peak of jump
	if jump_update_vel == Vector2.ZERO and $CollisionShape2D.position != Vector2.ZERO:
		# character is back a local origin (floor)
		if _approx_equal(_abs_vec($CollisionShape2D.position), Vector2.ZERO, 5):
			grav_update_vel = Vector2.ZERO
			$CollisionShape2D.position = Vector2.ZERO
			collision_layer = 1
			collision_mask = 1
		#character is falling - apply gravity update
		else:
			grav_update_vel = grav_update_vel + grav_acc * Vector2.DOWN * delta
			$CollisionShape2D.position = $CollisionShape2D.position + grav_update_vel * delta
			print($CollisionShape2D.position)
		
	
	velocity = move_and_slide(move_update_vel)

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if "Character" in collision.collider.name:
			emit_signal("on_character_collision", collision.collider)
	
func _approx_equal(a,b,tol=0.0001):
	var diff = Vector2(a.x - b.x, a.y - b.y)
	return diff.x <= tol and diff.y <= tol

func is_on_floor():
	return $CollisionShape2D.position == Vector2.ZERO

func _abs_vec(v):
	return Vector2(abs(v.x), abs(v.y))
