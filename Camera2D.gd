extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if self is Camera2D:
		make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
