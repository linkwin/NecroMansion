extends Node2D

signal death

var curr_health

var max_health = 1

func _ready():
	curr_health = max_health

func try_damage(damage_amm):
	curr_health -= damage_amm

	if curr_health <= 0:
		emit_signal("death")
	get_parent().modulate = Color.black
	yield(get_tree().create_timer(0.5), "timeout")
	get_parent().modulate = Color.white
