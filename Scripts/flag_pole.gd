extends Area2D

class_name FlagPole

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("RESET")

func hit():
	animated_sprite_2d.play("dead")
	animation_player.play("pole_down")
