extends KinematicBody2D
#
# 2D top down character movement script. 
# Move : add_move_input(dir)
# Jump : set wants_to_jump = true
# Sprint : set_sprint(true) to start sprinting, set_sprint(false) to stop
#

signal on_end_fall
signal on_start_fall

signal on_character_collision(collider)
#==== MOVE =====
var move_input_enabled := true

var move_dir = Vector2.ZERO
var last_move_dir = Vector2.ZERO

export var default_move_speed = 12000
var move_speed = 12000
var move_acc = 12
var friction = 1000

onready var sprint_timer = $SprintTimer
onready var sprint_cooldown_timer = $SprintCoolDown

#==== END MOVE ====

#==== JUMP =====
var jump_impulse = 500
var jump_decel = 1000
var wants_to_jump = false
var jump_update_vel = Vector2.ZERO

var jump_sounds = preload("res://Core/Sounds/AudioSets/jump_sounds.tres")

var grav_acc = 600
var grav_update_vel = Vector2.ZERO

var falling := false
var falling_t := 0.0
# =====

var velocity = Vector2.ZERO
var room_origin = Vector2.ZERO

var avoid_obstacle = false

var character_data : CharacterData

#===ANIM====
var anim_dirs := {
	Vector2(-1,0):"left",
	Vector2(1,0):"right", 
	Vector2(0,1):"back",
	Vector2(0,-1):"forward",
}
var anim_prefix = "player_character"
var anim_state = "walk"
#===========

onready var sprite = $CollisionShape2D/Sprite

# Setup character sprite offset, scale, rect and anim prefix
func set_character_data(_character_data):
	character_data = _character_data
	anim_prefix = character_data.anim_prefix
	sprite.texture = character_data.sprite_sheet
	sprite.region_rect = character_data.init_region_rect
	sprite.offset = character_data.sprite_offset
	sprite.scale = character_data.sprite_scale
	anim_dirs = character_data.anim_dirs	

# Call to move character in given direction
func add_move_input(new_move_dir):
	if move_input_enabled:
		move_dir = new_move_dir
	
func jump(initial_impulse : float = 500):
	if is_on_floor():
		jump_impulse = initial_impulse
		jump_decel = jump_impulse * 2
		wants_to_jump = true
	
func set_sprint(new_sprint, speed_multiplier : float = 2, sprint_time : float = 1.0, sprint_cooldown : float = 1.0):
	if new_sprint and $SprintTimer.time_left <= 0 and $SprintCoolDown.time_left <= 0:
		anim_state = "run"
		move_speed *= speed_multiplier
		sprint_timer.wait_time = sprint_time
		sprint_cooldown_timer.wait_time = sprint_cooldown		
		$SprintTimer.start()
	else:
		_disable_sprint()
	
func _get_anim_dir(_anim_dirs):
	var ret = Vector2.ZERO
	if move_dir != Vector2.ZERO:
		var max_proj = 0
		for dir in _anim_dirs.keys():
			#var basis = ((move_dir * dir) / move_dir.length()) * dir
			var proj = move_dir.dot(dir)
			if proj > max_proj:
				max_proj = proj
				ret = dir
	return ret
	
func _process(delta):
	z_index = clamp(floor(global_position.y - room_origin.y),VisualServer.CANVAS_ITEM_Z_MIN,VisualServer.CANVAS_ITEM_Z_MAX)
	var anim_dir = Vector2.ZERO

	anim_dir = _get_anim_dir(anim_dirs)
	
	if anim_dirs.has(anim_dir):
		var anim_name = anim_prefix + \
			"_" + anim_state + "_" + anim_dirs[anim_dir]
		$CollisionShape2D/Sprite/AnimationPlayer.play(anim_name)
	if velocity == Vector2.ZERO:
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
		#print(jump_update_vel)
	#check if at height of jump
	if _approx_equal(_abs_vec(jump_update_vel), Vector2.ZERO, 0.001):
		jump_update_vel = Vector2.ZERO
	#trigger jump
	if wants_to_jump:
		jump_update_vel = Vector2.UP * jump_impulse
		$AudioStreamPlayer2D.stream = jump_sounds.get_rand_sound()
		$AudioStreamPlayer2D.play()
		wants_to_jump = false
		collision_layer = 2
		collision_mask = 2
	
	#character is at peak of jump
	if jump_update_vel == Vector2.ZERO and $CollisionShape2D.position != Vector2.ZERO:
		# character is back a local origin (floor)
		#if _approx_equal(_abs_vec($CollisionShape2D.position), Vector2.ZERO, 15):
		if $CollisionShape2D.position.y >= 0:
			grav_update_vel = Vector2.ZERO
			$CollisionShape2D.position = Vector2.ZERO
			collision_layer = 1
			collision_mask = 1
		#character is falling - apply gravity update
		else:
			grav_update_vel = grav_update_vel + grav_acc * Vector2.DOWN * delta
			$CollisionShape2D.position = $CollisionShape2D.position + grav_update_vel * delta
			#print($CollisionShape2D.position)
	#======END JUMP=======
	
	if falling:
		if falling_t < 1:
			print(falling_t)
			scale = Vector2(1,1).linear_interpolate(Vector2.ZERO, falling_t)
			rotate(PI / 8)
			falling_t += delta*3
		else: 
			emit_signal("on_end_fall")
			falling_t = 0
			scale = Vector2(1,1)
			set_rotation(0)
			move_input_enabled = true
			falling = false
		
		
#	var avoid = Vector2.ZERO
#	if character_behavior == 10 and avoid_obstacle:
#		avoid = Vector2(move_dir.y,-move_dir.x)*move_speed *delta
	
	# velocity update
	#velocity = move_and_slide(move_update_vel)
	velocity = move_and_slide(move_update_vel)

	# check for collision during 
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if "Character" in collision.collider.name:
			emit_signal("on_character_collision", collision.collider)
#	$ObjectDetection.cast_to = move_dir * 100
#	if $ObjectDetection.is_colliding() and not "Player" in $ObjectDetection.get_collider().get_parent().name:
#		avoid_obstacle = true
#	else:
#		$AvoidTimer.start()
		
func _avoid_timeout():		
	avoid_obstacle = false
			
func _disable_sprint():
	anim_state = "walk"
	move_speed = default_move_speed
	$SprintCoolDown.start()
	
func _approx_equal(a,b,tol=0.0001):
	var diff = Vector2(a.x - b.x, a.y - b.y)
	return diff.x <= tol and diff.y <= tol

func is_on_floor():
	return $CollisionShape2D.position == Vector2.ZERO

func _abs_vec(v):
	return Vector2(abs(v.x), abs(v.y))

func fall():
	emit_signal("on_start_fall")
	move_dir = Vector2.ZERO
	move_input_enabled = false
	falling = true
