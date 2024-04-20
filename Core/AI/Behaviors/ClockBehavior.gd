extends AIBehavior

static func tick(controller, character_ref):
	pass

static func on_jump_timer_timeout(controller):
	pass

static func on_attack_timer_timeout(controller):
	pass

static func on_player_enter_attack_radius(controller, player_character):
	var timer = controller.get_node("Timer")
	if controller.can_attack():
		controller.do_basic_attack(player_character)
		timer.wait_time = rand_range(2,4)
		timer.start()
		
