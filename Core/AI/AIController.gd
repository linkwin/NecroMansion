extends Node2D

signal enemy_defeated(ref, curr_room)

var map_data
var enemy_number

onready var enemy_data

var current_room = Vector2.ZERO

var bot_behavior
var bot_state = Global.BOT_STATE.IDLE

var curr_move_dir = Vector2.ZERO
onready var character_ref = $CharacterBody
onready var timer = $Timer

var target_player

var enemy_characters = {Global.BOT_BEHAVIOR.RANDOM_MOVE:preload("res://Characters/Clock.tres"),
						Global.BOT_BEHAVIOR.HOPPER:preload("res://Characters/Candelabra.tres"),
						Global.BOT_BEHAVIOR.SOLDIER:preload("res://Characters/Whisp.tres")}
onready var character_data : CharacterData
onready var behavior_script : Script

func _ready():
	character_ref.room_origin = current_room * 2000

	bot_behavior = enemy_data["Enemy Class"]
	character_data = enemy_characters[enemy_data["Enemy Class"]]
	
	character_ref.move_speed = enemy_data["Enemy Speed"]
	character_ref.default_move_speed = enemy_data["Enemy Speed"]
	
	$CharacterBody/OverlapSphere/CollisionShape2D.shape.radius = enemy_data["Enemy Attack Radius"]
	$AttackTimer.wait_time = enemy_data["Enemy Recovery"]
	
	behavior_script = character_data.behavior_script

	# Random initial direction
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	bot_state = Global.BOT_STATE.PATROL

	character_ref.set_character_data(character_data)
	
	$CharacterBody/AttackSound.stream = character_data.attack_sound
	
	# ==== DEBUG ====
#    print("Enemy Class:  ", enemy_data["Enemy Class"])
#	"Enemy Data": {"Enemy Seeds": [], "Enemy Difficulty": [], "Enemy Class":    [],
#				   "Enemy Speed": [], "Enemy Damage":     [], "Enemy Recovery": [], 
#				   "Enemy Attack Radius": []},
	
func _process(delta):
	
	# Run character behavior
	behavior_script.tick(self, character_ref)

	# Update character move dir
	character_ref.add_move_input(curr_move_dir)
	
	# ===== DEBUG =====
#	$CharacterBody/DEBUG_state.text = Global.BOT_STATE.keys()[bot_state] + "\n" \
#		+ Global.BOT_BEHAVIOR.keys()[enemy_data["Enemy Class"]]

# Random move direction timer timeout
func _on_Timer_timeout():
	bot_state = Global.BOT_STATE.PATROL
	character_ref.anim_state = "walk"
	character_ref.move_speed = character_ref.default_move_speed
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	target_player = null

func _on_CharacterBody_on_character_collision(collider):
	# body slam player attack
	if "Player" in collider.get_parent().name:
		
		# Apply damage
		collider.get_node("CollisionShape2D/Health").try_damage(enemy_data["Enemy Damage"])
		
		# Play attack sound
		$CharacterBody/AttackSound.play()
		
		# Move away from player
		curr_move_dir = (character_ref.global_position - collider.global_position).normalized()
		
		# Set random wait time for direction change
		timer.wait_time = rand_range(2,4)
		timer.start()

# body entered attack radius
func _on_OverlapSphere_body_entered(body):
	if "Player" in body.get_parent().name and behavior_script:
		behavior_script.on_player_enter_attack_radius(self, body)
		
func do_basic_attack(target = target_player):
	if target:
		bot_state = Global.BOT_STATE.ATTACK
		target_player = target
		curr_move_dir = (target.global_position - character_ref.global_position).normalized()
		character_ref.move_speed = character_ref.default_move_speed * 2
		character_ref.anim_state = "run"
		$AttackTimer.start()

func can_attack():
	return bot_state == Global.BOT_STATE.IDLE or bot_state == Global.BOT_STATE.PATROL \
		or bot_state == Global.BOT_STATE.WANDER and $AttackTimer.time_left <= 0

func _on_Health_death():
	emit_signal("enemy_defeated", self)
	queue_free()

func _on_JumpTimer_timeout():
	if behavior_script:
		behavior_script.on_jump_timer_timeout(self)
	$JumpTimer.wait_time = rand_range(1,5)
	
func _check_for_player():
	for body in $CharacterBody/OverlapSphere.get_overlapping_bodies():
		if "Player" in body.get_parent().name and $AttackTimer.time_left <= 0:
			target_player = body
			break

func _on_AttackTimer_timeout():
	if behavior_script:
		behavior_script.on_attack_timer_timeout(self)
		
