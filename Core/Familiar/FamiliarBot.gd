extends Node2D

onready var character_ref = $CharacterBody

var bot_state = Global.BOT_STATE.IDLE

var player_ref

var curr_move_dir = Vector2.ZERO

var player_in_range = false

var player_controlled = false

var max_follow_dist = 200

var cast_dirs

var summoning_sounds = preload("res://Core/Sounds/AudioSets/summoning_sounds.tres")
onready var audio_strm_player = $CharacterBody/AudioStreamPlayer2D

func try_summon(player):
	player_ref = player

func on_player_death():
	player_ref = null
	player_controlled = false
	$CharacterBody/ProximitySound.play()
	
func _ready():
	$CharacterBody.set_character_data(preload("res://Characters/Cat.tres"))
	#$CharacterBody.set_sprite_direct("cat")
	#$CharacterBody.character_behavior = 10

func _get_bias_dir(check_dir, _dirs):
	var ret = Vector2.ZERO
	var max_proj = 0
	for dir in _dirs:
		#var basis = ((move_dir * dir) / move_dir.length()) * dir
		var proj = check_dir.dot(dir)
		if proj > max_proj:
			max_proj = proj
			ret = dir
	return ret

func _process(delta):

	var bias_dir = Vector2.ZERO
	$CharacterBody/RayCast2D.cast_to = curr_move_dir*100
	var coll = $CharacterBody/RayCast2D.get_collider()
	# Obstacle avoidance
	var left_ortho = Vector2(curr_move_dir.y,-curr_move_dir.x)
	var right_ortho = Vector2(-curr_move_dir.y, curr_move_dir.x)
	var count = 0
	var potential_dirs = []
	if  coll and not "Bot" in coll.get_parent().name:
		print("ortho: ", left_ortho, right_ortho)
		cast_dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		for dir in cast_dirs:
			$CharacterBody/RayCast2D.cast_to = dir * 100
			print($CharacterBody/RayCast2D.get_collider().get_parent())
			if not $CharacterBody/RayCast2D.is_colliding():
				potential_dirs.append(dir)
	if player_ref:
		var to_player = player_ref.global_position - character_ref.global_position
		bias_dir = _get_bias_dir(to_player, potential_dirs)
	
#	if count == 2:
#
#		bias_dir = [left_ortho,right_ortho][randi()%2]
#		var left = left_ortho.dot(to_player)
#		var right = right_ortho.dot(to_player)
#		print("ORTHO", left, right)
#		if right > left:
#			bias_dir = right_ortho
		
#		var collider = $CharacterBody/RayCast2D.get_collider()
#		if collider and not "Bot"  in collider.get_parent().name:
			
		
	if Input.get_action_strength("summon") != 0 and player_in_range and not player_controlled:
		$CharacterBody/ProximitySound.stop()
		player_ref.get_parent().upgrade()
		player_ref.get_parent().add_familiar(self)
		audio_strm_player.stream = preload("res://Core/Sounds/Summoning sounds/encant3.mp3")
		audio_strm_player.play()
		#audio_strm_player.volume_db = -13
		$CharacterBody/FX.get_node("CPUParticles2D").emitting = true
		player_controlled = true
		bot_state = Global.BOT_STATE.FOLLOW
		print("summon")
	
	if player_ref and player_controlled:
		match bot_state:
			Global.BOT_STATE.FOLLOW:
				if (player_ref.global_position - character_ref.global_position).length() > max_follow_dist:
					curr_move_dir = (player_ref.global_position - character_ref.global_position).normalized()
					curr_move_dir = (Vector2(curr_move_dir.y,-curr_move_dir.x) + curr_move_dir).normalized()

	$CharacterBody/DEBUG_state.text = Global.BOT_STATE.keys()[bot_state]
	if bias_dir == -curr_move_dir:
		curr_move_dir = bias_dir
	character_ref.add_move_input(curr_move_dir + bias_dir)

func _on_Health_death():
	player_ref = null
	queue_free()

# body enterd attack / interact radius
func _on_OverlapSphere_body_entered(body):
	print("ENTER")
	if "Player" in body.get_parent().name and not player_controlled:
		# Show interact prompt
		$CharacterBody/InteractIcon.visible = true
		player_in_range = true
		player_ref = body
	# bot in attack radius, initiate attack
	if "Bot" in body.get_parent().name and _can_attack():
		print(body.get_parent().name)
		# attack bot
		bot_state = Global.BOT_STATE.ATTACK
		curr_move_dir = (body.global_position - character_ref.global_position).normalized()
		character_ref.move_speed *= 2
		$AttackTimeout.start()
		
func _can_attack():
	return (bot_state == Global.BOT_STATE.IDLE or bot_state == Global.BOT_STATE.FOLLOW) \
		and player_controlled

func _on_OverlapSphere_body_exited(body):
	if "Player" in body.get_parent().name:
		$CharacterBody/InteractIcon.visible = false
		player_in_range = false
		if not player_controlled:
			player_ref = null

func _on_CharacterBody_on_character_collision(collider):
	# collided with other bot, check for attack
	if "Bot" in collider.get_parent().name:
		if bot_state == Global.BOT_STATE.ATTACK:
			collider.get_node("CollisionShape2D/Health").try_damage(1)
			audio_strm_player.stream = summoning_sounds.get_rand_sound()
			audio_strm_player.play()
			bot_state = Global.BOT_STATE.FOLLOW
			character_ref.move_speed = character_ref.default_move_speed

func _on_AttackTimeout_timeout():
	if player_controlled:
		bot_state = Global.BOT_STATE.FOLLOW
		character_ref.move_speed = character_ref.default_move_speed
