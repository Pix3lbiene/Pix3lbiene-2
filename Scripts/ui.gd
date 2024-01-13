extends CanvasLayer

class_name UI

@onready var center_container = $MarginContainer/CenterContainer


@onready var coins_label = $MarginContainer/HBoxContainer/CoinsLabel
@onready var score_label = $MarginContainer/HBoxContainer/ScoreLabel

func set_score(points: int):
	print_debug(points)
	score_label.text = "SCORE: %d" % points
	
func set_coins(coins: int):
	print_debug(coins)
	coins_label.text = "COINS: %d" % coins
	
func on_finish():
	center_container.visible = true
