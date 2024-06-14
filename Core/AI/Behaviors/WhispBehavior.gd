extends AIBehavior

static func init_behavior(controller):
	controller.curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()
	controller.bot_state = Global.BOT_STATE.PATROL

static func tick(controller, character_ref):
	#print("Whisp attack", controller.black_board["player_ref"], controller.can_attack())
	if controller.black_board["player_ref"]:
		if controller.can_attack():
			controller.try_action("basic_attack")
		if controller.bot_state == Global.BOT_STATE.ATTACK:
			controller.move_towards_target()
