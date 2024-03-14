extends Area2D

class_name CollectableCoin


func _on_body_entered(body):
	if (body is Player):
		queue_free()
		get_parent().get_parent().get_parent().add_coins(1)
		get_parent().get_parent().get_parent().add_points(100)
