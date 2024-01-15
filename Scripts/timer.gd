extends Label

var time = 0
var timer = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time = time + delta
	if(time > 1):
		time = 0
		timer = timer + 1
		text = "Time= %d" % timer
