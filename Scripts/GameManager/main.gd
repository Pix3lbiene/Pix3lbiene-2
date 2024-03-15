extends Node

@export var game_scene: String
var game_world: Node2D
var instantiated_game_world: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	
	ScreenFader.fade_in()



func _on_game_load(cheat: bool):
	ScreenFader.fade_out()
	await(ScreenFader.faded_out)
	# Die Spiel-Welt instanzieren und dann zur Main-Node hinzufügen
	# Nur dann instanzieren, wenn sie nicht vorher schon mal geladen wurde
	if !instantiated_game_world:
			instantiated_game_world = true
			game_world = load(game_scene).instantiate()
			game_world.next_start_cheat = true
			add_child(game_world)
			game_world.connect('end_game', open_main_menu)
	else:
		add_child(game_world)
		game_world._ready()
	
	#ScreenFader.fade_in()
	

func open_main_menu(won: bool):
	ScreenFader.fade_out()
	remove_child(game_world)
	get_tree().paused = false
	
	var main_menu = load("res://Nodes/MainMenu/Title.tscn").instantiate()
	add_child(main_menu)
	if(won):main_menu.thanks_for_playing()
	main_menu.connect('starting', _on_game_load)
	ScreenFader.fade_in()
	
