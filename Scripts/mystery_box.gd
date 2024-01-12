extends Block

class_name MysteryBox

enum BonusType {
	COIN,
	SHROOM,
	FLOWER
}

@onready var animated_sprite_2d = $AnimatedSprite2D
@export var bonus_type: BonusType = BonusType.COIN
@export var invisible: bool = false

var is_empty = false

func _ready():
	animated_sprite_2d.visible = !invisible
	
func bump(player_mode: Player.PlayerMode):
	if is_empty:
		return
		
	if invisible:
		animated_sprite_2d.visible = true
		invisible = !invisible
	
	super.bump(player_mode)
	make_empty()
	
	match bonus_type:
		BonusType.COIN:
			spawn_coin()
		BonusType.SHROOM:
			spawn_shroom()
		BonusType.FLOWER:
			spawn_flower()
	
func make_empty():
	is_empty = true
	animated_sprite_2d.play("empty")
	
func spawn_coin():

func spawn_shroom():

func spawn_flower():
