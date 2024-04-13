extends Node2D

onready var character_ref = $CharacterBody

var bot_state = Global.BOT_STATE.IDLE

var player_ref

var curr_move_dir = Vector2.ZERO

var player_in_range = false

var player_controlled = false

func try_summon(player):
	player_ref = player

func _process(delta):
	if Input.get_action_strength("summon") != 0 and player_in_range:
		player_controlled = true
		bot_state = Global.BOT_STATE.FOLLOW
	
	if player_ref and player_controlled:
		match bot_state:
			Global.BOT_STATE.FOLLOW:
				if (player_ref.global_position - character_ref.global_position).length() > 200:
					curr_move_dir = (player_ref.global_position - character_ref.global_position).normalized()

			
	character_ref.add_move_input(curr_move_dir)

func _on_Health_death():
	player_ref = null
	queue_free()

func _on_OverlapSphere_body_entered(body):
	if "Player" in body.get_parent().name and not player_controlled:
		# Show interact prompt
		$InteractIcon.visible = true
		player_in_range = true
		player_ref = body
	if "Bot" in body.get_parent().name and _can_attack():
		# attack bot
		bot_state = Global.BOT_STATE.ATTACK
		curr_move_dir = (body.global_position - character_ref.global_position).normalized()
		character_ref.move_speed *= 2
		
func _can_attack():
	return bot_state == Global.BOT_STATE.IDLE or bot_state == Global.BOT_STATE.FOLLOW \
		and player_controlled

func _on_OverlapSphere_body_exited(body):
	if "Player" in body.get_parent().name:
		$InteractIcon.visible = false
		player_in_range = false
		if not player_controlled:
			player_ref = null


func _on_CharacterBody_on_character_collision(collider):
	if "Bot" in collider.get_parent().name:
		if bot_state == Global.BOT_STATE.ATTACK:
			collider.get_node("Health").try_damage(1)
			bot_state = Global.BOT_STATE.FOLLOW
			character_ref.move_speed = character_ref.default_move_speed
