extends Node2D

export var bot_behavior = Global.BOT_BEHAVIOR.RANDOM_MOVE

var bot_state = Global.BOT_STATE.IDLE

var curr_move_dir = Vector2.ZERO
onready var character_ref = $CharacterBody
onready var timer = $Timer

func _ready():
	match bot_behavior:
		Global.BOT_BEHAVIOR.RANDOM_MOVE:
			curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
			
	bot_state = Global.BOT_STATE.PATROL

func _process(delta):
	character_ref.add_move_input(curr_move_dir)
	$CharacterBody/DEBUG_state.text = Global.BOT_STATE.keys()[bot_state]

func _on_Timer_timeout():
	bot_state = Global.BOT_STATE.PATROL
	character_ref.move_speed = character_ref.default_move_speed
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()

func _on_CharacterBody_on_character_collision(collider):
	if "Player" in collider.get_parent().name:
		collider.get_node("Health").try_damage(1)
		# move away from player
		curr_move_dir = (character_ref.global_position - collider.global_position).normalized()
		timer.wait_time = rand_range(2,4)
		timer.start()

# body ented attack radius
func _on_OverlapSphere_body_entered(body):
	if "Player" in body.get_parent().name and _can_attack():
		bot_state = Global.BOT_STATE.ATTACK
		curr_move_dir = (body.global_position - character_ref.global_position).normalized()
		character_ref.move_speed *= 2
		timer.wait_time = rand_range(2,4)
		timer.start()

func _can_attack():
	return bot_state == Global.BOT_STATE.IDLE or bot_state == Global.BOT_STATE.PATROL \
		or bot_state == Global.BOT_STATE.WANDER

func _on_Health_death():
	queue_free()
