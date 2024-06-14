extends AIBehavior

static func init_behavior(controller):
	controller.curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	controller.bot_state = Global.BOT_STATE.PATROL

static func tick(controller, character_ref):
	if controller.black_board['player_ref'] != null and controller.can_attack():
		controller.do_basic_attack()

static func on_jump_timer_timeout(controller):
	pass

static func on_attack_timer_timeout(controller):
	pass

static func on_player_enter_attack_radius(controller, player_character):
	pass
#	var timer = controller.get_node("Timer")
#	if controller.can_attack():
#
#		timer.wait_time = rand_range(2,4)
#		timer.start()
		
static func on_timer_timeout(controller):
	pass
