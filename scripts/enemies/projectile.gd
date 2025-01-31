extends CharacterBody2D

@export var speed = 1000

var direction : Vector2 = Vector2.ZERO
var node : Node

	
func _physics_process(delta: float) -> void:
	velocity = direction.normalized() * speed
	move_and_slide()

func shot():
	await node.create_tween().tween_property(self,"speed", 200, 5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).finished
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player = body as Player
		player.receive_damage(1)
		
	if body.is_in_group("enemy"):
		pass # i dont want it breaking when it hits an enemy
	else:
		queue_free()
