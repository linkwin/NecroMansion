extends Node2D

signal death
signal damaged
onready var health_bar = $ProgressBar

var curr_health

export var max_health = 3

onready var inv_timer = $InvulnerabilityTimer

func _ready():
	curr_health = max_health
	health_bar.min_value = 0
	health_bar.max_value = max_health
	update_health_bar()
	
func update_health_bar():
	health_bar.value = curr_health

func try_damage(damage_amm):
	
	if inv_timer.time_left > 0:
		return
	
	curr_health -= damage_amm
	
	inv_timer.start()
	
	update_health_bar()
	emit_signal("damaged")

	if curr_health <= 0:
		emit_signal("death")
	get_parent().modulate = Color.red
	yield(get_tree().create_timer(0.5), "timeout")
	get_parent().modulate = Color.white

func regen():
	curr_health = max_health
	update_health_bar()
