extends Node
class_name AIBehavior

static func init_behavior(controller):
	pass

static func tick(controller, character_ref):
	pass

static func on_jump_timer_timeout(controller):
	pass

static func on_attack_timer_timeout(controller):
	pass
	
static func on_player_enter_attack_radius(controller, player_character):
	pass

static func on_timer_timeout(controller):
	var rand_sign = [1, -1][randi() % 2]
	controller.curr_move_dir = controller.curr_move_dir.rotated(rand_sign * PI / 4)
