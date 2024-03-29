extends Control

@onready var start_sfx = $StartSFX

var already_pressed = false
@onready var title_thank_you = $TitleThankYou

signal starting(cheat: bool)
# Called when the node enters the scene tree for the first time.
func _ready():
	BackgroundMusic.play_music("res://Assets/Sound/Music/main_menu_loop.wav")

func thanks_for_playing():
	title_thank_you.visible = true

func _on_button_pressed():
	if(!already_pressed):
		already_pressed = true
		start_game(false)
		

func start_game(cheat: bool):
	BackgroundMusic.stop()
	start_sfx.play()
	emit_signal("starting", cheat)
	await(start_sfx.finished)
	queue_free()


func _on_button_pressed_cheat():
	if(!already_pressed):
		already_pressed = true
		start_game(true)
