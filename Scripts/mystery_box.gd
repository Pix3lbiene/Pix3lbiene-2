extends Block

class_name MysteryBox

enum BonusType {
	COIN,
	SHROOM,
	FLOWER
}

#Bonus References
const COIN_SCENE = preload("res://Scenes/coin.tscn")
const SHROOM_SCENE = preload("res://Scenes/shroom.tscn")
const SHOOTING_FLOWER_SCENE = preload("res://Scenes/shooting_flower.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@export var bonus_type: BonusType = BonusType.COIN
@export var invisible: bool = false

var is_empty = false

func _ready():
	animated_sprite_2d.visible = !invisible
	
func bump(player: Player):
	if is_empty:
		return
		
	if invisible:
		animated_sprite_2d.visible = true
		invisible = !invisible
	
	super.bump(player)
	make_empty()
	
	match bonus_type:
		BonusType.COIN:
			spawn_coin(player)
		BonusType.SHROOM:
			spawn_shroom()
		BonusType.FLOWER:
			spawn_flower()
	
func make_empty():
	is_empty = true
	animated_sprite_2d.play("empty")
	
func spawn_coin(player: Player):
	var coin = COIN_SCENE.instantiate()
	coin.global_position = global_position + Vector2(0, -16)
	get_parent().add_child(coin)
	player.game_world.add_coins(1)
	player.game_world.add_points(100)
	
func spawn_shroom():
	var shroom = SHROOM_SCENE.instantiate()
	shroom.global_position = Vector2(global_position.x, global_position.y - 10)
	get_parent().add_child(shroom)
	
func spawn_flower():
	var flower = SHOOTING_FLOWER_SCENE.instantiate()
	flower.global_position = global_position
	get_parent().add_child(flower)
