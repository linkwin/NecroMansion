extends Resource
class_name AudioSet

export var sounds = []

func get_rand_sound():
	sounds.shuffle()
	return sounds[0]
