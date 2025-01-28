extends Node
class_name PathVectors

var vec_array : Array[Vector2]

func _init() -> void:
	vec_array.resize(16)
	vec_array.fill(Vector2.ZERO)
	
func create_vector(v0 : Vector2, v1 : Vector2, v2 : Vector2, v3 : Vector2, v4 : Vector2, v5 : Vector2, v6 : Vector2, v7 : Vector2, v8 : Vector2, v9 : Vector2, v10 : Vector2, v11 : Vector2, v12 : Vector2, v13 : Vector2, v14 : Vector2, v15 : Vector2) -> PathVectors:
	vec_array = [v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15]	
	return self

func set_vector(index : int, vec : Vector2) -> PathVectors:
	vec_array[index] = vec
	return self
