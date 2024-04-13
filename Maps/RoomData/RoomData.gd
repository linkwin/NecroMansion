class_name RoomData extends Resource


export var initial_seed : int = hash("Carrotds")

export var probabilities := {
	"Initial Number of Enemies": [6, 6, 5, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"Initial Enemy Difficulty": [5, 3, 2, 0, 0, 0, 0, 0, 0, 0],
	"Initial Enemy Difficdulty": [5, 3, 2, 0, 0, 0, 0, 0, 0, 0]
}

export var properties := {}

func seed_gen():
	return(hash("Carrotds"))

#func _init(props, probs, initial_seed):
#	initial_seed = hash("Carrotds")
#	properties = props
#	probabilities = probs
