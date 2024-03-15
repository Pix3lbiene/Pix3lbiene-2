extends AudioStreamPlayer


func play_music(audio_path: String):
	stop()
	stream = load(audio_path)
	play()
