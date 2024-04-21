extends Node

signal room_updated(room_origin)

var room_size = 2000

enum BOT_STATE {IDLE, PATROL, WANDER, FOLLOW, ATTACK}

var seed_text = "bananas"

enum BOT_BEHAVIOR {RANDOM_MOVE, SOLDIER, HOPPER, SCARED}

func room_transition(new_origin):
	emit_signal("room_updated", new_origin)
