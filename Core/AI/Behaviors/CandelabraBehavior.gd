extends AIBehavior

static func init_behavior(controller):
	controller.curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	controller.bot_state = Global.BOT_STATE.PATROL

static func tick(controller, character_ref):
	if character_ref.is_on_floor():
		controller._check_for_player() # in range
		# ensure to hop while moving
		if controller.curr_move_dir != Vector2.ZERO:
			character_ref.wants_to_jump = true
			controller.get_node("JumpTimer").start()
			
	if controller.target_player:
		var diff = controller.target_player.global_position - character_ref.global_position
		# only change direction when on floor
		if character_ref.is_on_floor():
			controller.curr_move_dir = (diff).normalized() # move towards player
		
		# distance to player <= 25
		if diff.length() <= 25:
			controller.target_player = null
			controller.get_node("AttackTimer").start()

static func on_jump_timer_timeout(controller):
	var character_ref = controller.character_ref
	if character_ref.is_on_floor():
		character_ref.wants_to_jump = true

static func on_attack_timer_timeout(controller):
	pass
	
static func on_player_enter_attack_radius(controller, player_character):
	pass
#	var character_ref = controller.character_ref
#	var attack_timer = controller.get_node("AttackTimer")
#	if controller.can_attack():
#		if character_ref.is_on_floor() and attack_timer.time_left <= 0:
#			controller.target_player = player_character
#		controller.do_basic_attack(player_character, 1)
#		controller.timer.wait_time = rand_range(2,4)
#		controller.timer.start()
		
static func on_timer_timeout(controller):
	if controller.character_ref.is_on_floor():
		var rand_sign = [1, -1][randi() % 2]
		controller.curr_move_dir = controller.curr_move_dir.rotated(rand_sign * PI / 4)
