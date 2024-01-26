extends ColorRect

signal faded_out
signal faded_in

func fade_out():
	$FadePlayer.play("fade_out")
	await($FadePlayer.animation_finished)
	emit_signal("faded_out")
	
func fade_in():
	$FadePlayer.play("fade_in")
	await($FadePlayer.animation_finished)
	emit_signal("faded_in")
	
func fade_to_gray():
	$FadePlayer.play("fade_to_gray")
	await($FadePlayer.animation_finished)
	emit_signal("faded_out")
	
func fade_from_gray_to_white():
	$FadePlayer.play("fade_from_gray_to_white")
	await($FadePlayer.animation_finished)
	emit_signal("faded_in")
