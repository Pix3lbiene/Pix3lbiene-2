extends Node2D

@onready var fade_player = $CanvasLayer/ScreenFader/FadePlayer

signal faded_out
signal faded_in

func fade_out():
	fade_player.play("fade_out")
	await(fade_player.animation_finished)
	emit_signal("faded_out")
	
func fade_in():
	fade_player.play("fade_in")
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BackgroundMusic"), -72)
	var audio_fade = get_tree().create_tween()
	audio_fade.tween_method(change_audio_bus_volume, -72.0, 0.0, 1.0)
	await(fade_player.animation_finished)
	emit_signal("faded_in")
	
func change_audio_bus_volume(value: float):
	var index = AudioServer.get_bus_index("BackgroundMusic")
	AudioServer.set_bus_volume_db(index, value)
	
func fade_to_gray():
	fade_player.play("fade_to_gray")
	await(fade_player.animation_finished)
	emit_signal("faded_out")
	
func fade_from_gray_to_white():
	fade_player.play("fade_from_gray_to_white")
	await(fade_player.animation_finished)
	emit_signal("faded_in")

