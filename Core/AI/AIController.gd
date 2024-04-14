extends Node2D


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

func _ready():
	print("Enemy Class:  ", enemy_data["Enemy Class"])
#	"Enemy Data": {"Enemy Seeds": [], "Enemy Difficulty": [], "Enemy Class":    [],
#				   "Enemy Speed": [], "Enemy Damage":     [], "Enemy Recovery": [], 
#				   "Enemy Attack Radius": []},
	bot_behavior = enemy_data["Enemy Class"]
	character_ref.move_speed = enemy_data["Enemy Speed"] 
	$CharacterBody/OverlapSphere/CollisionShape2D.shape.radius = enemy_data["Enemy Attack Radius"]
	match bot_behavior:
		Global.BOT_BEHAVIOR.RANDOM_MOVE:
			curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
		Global.BOT_BEHAVIOR.HOPPER:
			curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	
	bot_state = Global.BOT_STATE.PATROL
	
func _process(delta):
	character_ref.add_move_input(curr_move_dir)
	$CharacterBody/DEBUG_state.text = Global.BOT_STATE.keys()[bot_state] + "\n" \
		+ Global.BOT_BEHAVIOR.keys()[enemy_data["Enemy Class"]]

func _on_Timer_timeout():
	bot_state = Global.BOT_STATE.PATROL
	character_ref.move_speed = character_ref.default_move_speed
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	
func _on_CharacterBody_on_character_collision(collider):
	if "Player" in collider.get_parent().name:
		collider.get_node("CollisionShape2D/Health").try_damage(enemy_data["Enemy Damage"])
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

func _on_JumpTimer_timeout():
	if character_ref.is_on_floor() and enemy_data["Enemy Class"] == Global.BOT_BEHAVIOR.HOPPER:
		character_ref.wants_to_jump = true
	$JumpTimer.wait_time = rand_range(1,5)
