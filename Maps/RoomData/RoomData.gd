extends Resource
class_name RoomData

export var initial_seed : int = hash("Carrot") + 1

export var probabilities := {
	"Initial Number of Enemies": [3, 4, 5, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"Initial Enemy Difficulty": [6, 4, 2, 1, 0],
	"Initial Enemy Class": [5, 3, 2, 0, 0, 0, 0, 0, 0, 0],
	"Initial Number of Items": [3, 2, 1],
	"Initial Item Strength": [5, 3, 2, 0, 0, 0, 0, 0, 0, 0],
	"Initial Item Class": [1, 1, 1, 1, 1],
	"Room Design": [1, 1, 1, 1, 1]
}

export var properties := {
	"Enemy Data": {"Enemy Seeds": [], "Enemy Difficulty": [], "Enemy Type": [], "Enemy Classes": []},
	"Item Data": {"Item Seeds": [], "Item Strength": [], "Item Class": []},
	"Room Decoration Data": {"Room Seed": 0, "Room Type": 0}
}

#func _init(props, probs, initial_seed):
#	initial_seed = hash("Carrotds")
#	properties = props
#	probabilities = probs
