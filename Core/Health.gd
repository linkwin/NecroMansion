extends Node2D

signal death
signal damaged
onready var health_bar = $ProgressBar

var curr_health

export var max_health = 3

func _ready():
	curr_health = max_health
	health_bar.min_value = 0
	health_bar.max_value = max_health
	update_health_bar()
	
func update_health_bar():
	health_bar.value = curr_health

func try_damage(damage_amm):
	print(curr_health, "Damage amm", damage_amm)
	curr_health -= damage_amm
	update_health_bar()
	emit_signal("damaged")
	print("new health", curr_health)

	if curr_health <= 0:
		emit_signal("death")
	get_parent().modulate = Color.black
	yield(get_tree().create_timer(0.5), "timeout")
	get_parent().modulate = Color.white

func regen():
	curr_health = max_health
	update_health_bar()
