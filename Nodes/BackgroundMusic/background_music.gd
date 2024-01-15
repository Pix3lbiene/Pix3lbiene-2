extends AudioStreamPlayer2D


func play_music(audio_path: String):
	stop()
	stream = load(audio_path)
	play()
