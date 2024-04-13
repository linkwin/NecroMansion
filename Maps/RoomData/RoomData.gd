extends Resource
class_name RoomData

export var properties := [1]
export var probabilities = []

func _init(props, probs):
	properties = props
	probabilities = probs
