extends Area2D

class_name CollectableCoin


func _on_body_entered(body):
	if (body is Player):
		queue_free()
		pass
