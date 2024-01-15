extends Control

@onready var start_sfx = $StartSFX

signal starting
# Called when the node enters the scene tree for the first time.
func _ready():
	BackgroundMusic.play_music("res://Assets/Sound/Music/main_menu_loop.wav")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	start_game()

func start_game():
	start_sfx.play()
	emit_signal("starting")
	await(start_sfx.finished)
	queue_free()