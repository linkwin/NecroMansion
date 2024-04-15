extends Node2D

signal enemy_defeated(ref, curr_room)

var map_data
var enemy_number

onready var enemy_data

var current_room = Vector2.ZERO
#var current_map = preload("res://Maps/Map Layout Generator.gd")
var bot_behavior
var bot_state = Global.BOT_STATE.IDLE

var curr_move_dir = Vector2.ZERO
onready var character_ref = $CharacterBody
onready var timer = $Timer

var hit_sounds = {Global.BOT_BEHAVIOR.RANDOM_MOVE:preload("res://Core/Sounds/Mob sounds/coocoo1.mp3"),
				Global.BOT_BEHAVIOR.HOPPER:preload("res://Core/Sounds/Mob sounds/candle_smack.mp3"),
				Global.BOT_BEHAVIOR.SOLDIER:preload("res://Core/Sounds/Mob sounds/spooky_fabric.mp3")}

var target_player

func _ready():
	$CharacterBody.room_origin = current_room * 2000
	#print("Enemy Class:  ", enemy_data["Enemy Class"])
#	"Enemy Data": {"Enemy Seeds": [], "Enemy Difficulty": [], "Enemy Class":    [],
#				   "Enemy Speed": [], "Enemy Damage":     [], "Enemy Recovery": [], 
#				   "Enemy Attack Radius": []},
	bot_behavior = enemy_data["Enemy Class"]
	character_ref.move_speed = enemy_data["Enemy Speed"] 
	$CharacterBody/OverlapSphere/CollisionShape2D.shape.radius = enemy_data["Enemy Attack Radius"]
	$AttackTimer.wait_time = enemy_data["Enemy Recovery"]
	match bot_behavior:
		Global.BOT_BEHAVIOR.RANDOM_MOVE:
			curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
		Global.BOT_BEHAVIOR.HOPPER:
			curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	
	bot_state = Global.BOT_STATE.PATROL
	#character_ref.anim_prefix = "coocoo"
	character_ref.set_character_sprite(bot_behavior)
	
func _process(delta):
	if bot_behavior == Global.BOT_BEHAVIOR.HOPPER:
		if character_ref.is_on_floor():
			_check_for_player()
			if curr_move_dir != Vector2.ZERO:
				character_ref.wants_to_jump = true
				$JumpTimer.start()
		if target_player:
			var diff = target_player.global_position - $CharacterBody.global_position
			curr_move_dir = (diff).normalized()
			if diff.length() <= 25:
				target_player = null
				$AttackTimer.start()
				
#	if bot_behavior == Global.BOT_BEHAVIOR.SOLDIER:
#		var sprite = $CharacterBody.global_position
#		$CharacterBody.get_node("CollisionShape2D/Sprite").look_at(sprite + curr_move_dir*100)
#		var div = sqrt(pow(curr_move_dir.x, 2) + pow(curr_move_dir.y, 2))
#		if div != 0:
#			$CharacterBody.get_node("CollisionShape2D/Sprite").rotation_degrees = \
#				acos(curr_move_dir.x/div)
	character_ref.add_move_input(curr_move_dir)
	$CharacterBody/DEBUG_state.text = Global.BOT_STATE.keys()[bot_state] + "\n" \
		+ Global.BOT_BEHAVIOR.keys()[enemy_data["Enemy Class"]]

func _on_Timer_timeout():
	bot_state = Global.BOT_STATE.PATROL
	character_ref.anim_state = "walk"
	character_ref.move_speed = character_ref.default_move_speed
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	target_player = null
	
func _on_CharacterBody_on_character_collision(collider):
	# body slam player attack
	if "Player" in collider.get_parent().name:
		
		collider.get_node("CollisionShape2D/Health").try_damage(enemy_data["Enemy Damage"])
		#$CharacterBody.get_node("AudioStreamPlayer2D").stream = hit_sounds[bot_behavior]
		$CharacterBody/AttackSound.stream = hit_sounds[bot_behavior]
		#$CharacterBody.get_node("AudioStreamPlayer2D").play()
		$CharacterBody/AttackSound.play()
		# move away from player
		curr_move_dir = (character_ref.global_position - collider.global_position).normalized()
		timer.wait_time = rand_range(2,4)
		timer.start()

# body ented attack radius
func _on_OverlapSphere_body_entered(body):
	if "Player" in body.get_parent().name and _can_attack():
		if $CharacterBody.is_on_floor() and bot_behavior == Global.BOT_BEHAVIOR.HOPPER and $AttackTimer.time_left <= 0:
			target_player = body
		_do_basic_attack(body)
		timer.wait_time = rand_range(2,4)
		timer.start()
		
func _do_basic_attack(target):
	if target:
		bot_state = Global.BOT_STATE.ATTACK
		target_player = target
		curr_move_dir = (target.global_position - character_ref.global_position).normalized()
		character_ref.move_speed = character_ref.default_move_speed * 2
		character_ref.anim_state = "run"

		$AttackTimer.start()

func _can_attack():
	return bot_state == Global.BOT_STATE.IDLE or bot_state == Global.BOT_STATE.PATROL \
		or bot_state == Global.BOT_STATE.WANDER and $AttackTimer.time_left <= 0

func _on_Health_death():
	emit_signal("enemy_defeated", self)
	queue_free()

func _on_JumpTimer_timeout():
	if character_ref.is_on_floor() and enemy_data["Enemy Class"] == Global.BOT_BEHAVIOR.HOPPER:
		character_ref.wants_to_jump = true
	$JumpTimer.wait_time = rand_range(1,5)
	
func _check_for_player():
	for body in $CharacterBody/OverlapSphere.get_overlapping_bodies():
		if "Player" in body.get_parent().name and $AttackTimer.time_left <= 0:
			target_player = body
			break

func _on_AttackTimer_timeout():
	if bot_behavior == Global.BOT_BEHAVIOR.SOLDIER and target_player:
		_do_basic_attack(target_player)
		
