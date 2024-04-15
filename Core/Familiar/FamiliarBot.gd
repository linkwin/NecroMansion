extends Node2D

onready var character_ref = $CharacterBody

var bot_state = Global.BOT_STATE.IDLE

var player_ref

var curr_move_dir = Vector2.ZERO

var player_in_range = false

var player_controlled = false

var summoning_sounds = preload("res://Core/Sounds/AudioSets/summoning_sounds.tres")
onready var audio_strm_player = $CharacterBody/AudioStreamPlayer2D

func try_summon(player):
	player_ref = player

	
func _ready():
	$CharacterBody.set_sprite_direct("cat")

func _process(delta):
	if Input.get_action_strength("summon") != 0 and player_in_range:
		$CharacterBody/ProximitySound.stop()
		player_ref.get_parent().add_familiar(self)
		audio_strm_player.stream = summoning_sounds.get_rand_sound()
		audio_strm_player.play()
		audio_strm_player.volume_db = -13
		$CharacterBody/FX.get_node("CPUParticles2D").emitting = true
		player_controlled = true
		bot_state = Global.BOT_STATE.FOLLOW
		print("summon")
	
	if player_ref and player_controlled:
		match bot_state:
			Global.BOT_STATE.FOLLOW:
				if (player_ref.global_position - character_ref.global_position).length() > 200:
					curr_move_dir = (player_ref.global_position - character_ref.global_position).normalized()

	$CharacterBody/DEBUG_state.text = Global.BOT_STATE.keys()[bot_state]
	character_ref.add_move_input(curr_move_dir)

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
			bot_state = Global.BOT_STATE.FOLLOW
			character_ref.move_speed = character_ref.default_move_speed

func _on_AttackTimeout_timeout():
	if player_controlled:
		bot_state = Global.BOT_STATE.FOLLOW
		character_ref.move_speed = character_ref.default_move_speed
