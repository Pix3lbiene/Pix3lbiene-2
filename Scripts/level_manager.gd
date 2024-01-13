extends Node

class_name LevelManager

@export var ui: UI
@export var player: Player

var points = 0
var coins = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if SceneData.points != 0:
		ui.set_score(SceneData.points)
		points = SceneData.points
	if SceneData.coins != 0:
		ui.set_coins(SceneData.coins)
		coins = SceneData.coins
	player.points_scored.connect(on_points_scored)
		
func on_points_scored(points_scored: int):
	points += points_scored
	ui.set_score(points)

func on_coin_collected():
	coins += 1
	ui.set_coins(coins)

