extends Node2D

var curr_move_dir = Vector2.ZERO
onready var character_ref = $CharacterBody
onready var timer = $Timer

func _ready():
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()

func _process(delta):
	character_ref.add_move_input(curr_move_dir)

func _on_Timer_timeout():
	character_ref.move_speed = character_ref.default_move_speed
	curr_move_dir = Vector2(rand_range(-1.0,1.0), rand_range(-1.0,1.0)).normalized()

func _on_CharacterBody_on_character_collision(collider):
	if "Player" in collider.get_parent().name:
		collider.get_node("Health").try_damage(1)
		# move away from player
		curr_move_dir = (character_ref.global_position - collider.global_position).normalized()
		timer.start()

func _on_OverlapSphere_body_entered(body):
	if "Player" in body.get_parent().name:
		curr_move_dir = (body.global_position - character_ref.global_position).normalized()
		character_ref.move_speed *= 2
		timer.stop()


func _on_Health_death():
	queue_free()
