class_name RoomData extends Resource

export var initial_seed : int = hash("Kazawat")


export var probabilities := {
	"Initial Number of Enemies": [3, 4, 5, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"Initial Enemy Difficulty": [6, 4, 2, 1, 0],
	"Initial Enemy Class": [5, 4, 3, 2],
	"Initial Number of Items": [3, 2, 1],
	"Initial Item Strength": [5, 3, 2, 0, 0, 0, 0, 0, 0, 0],
	"Initial Item Class": [1, 1, 1, 1, 1],
	"Room Design": [1, 1, 1, 1, 1]
}

func seed_gen():
	initial_seed = hash(Global.seed_text)
	return(initial_seed)

#func _init(props, probs, initial_seed):
#	initial_seed = hash("Carrotds")
#	properties = props
#	probabilities = probs
