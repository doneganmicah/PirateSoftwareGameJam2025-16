extends Node
class_name PathVectors

var vec_array : Array[Vector2]

func _init() -> void:
	vec_array.resize(8)
	vec_array.fill(Vector2(1,1))
	
func create_vector(v0 : Vector2, v1 : Vector2, v2 : Vector2, v3 : Vector2, v4 : Vector2, v5 : Vector2, v6 : Vector2, v7 : Vector2) -> PathVectors:
	vec_array = [v0, v1, v2, v3, v4, v5, v6, v7]	
	return self

func set_vector(index : int, vec : Vector2) -> PathVectors:
	vec_array[wrapi(index, 0, 8)] = vec
	return self

static func get_max_index(arr: Array[Vector2]) -> int:
	if arr.is_empty():
		return -1  # Return -1 if the array is empty

	var max_index = 0
	var max_value = arr[0].x

	for i in range(1, arr.size()):
		if arr[i].x > max_value:
			max_value = arr[i].x
			max_index = i

	return max_index
