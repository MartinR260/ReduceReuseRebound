extends RigidBody2D

var scale_size = randf_range(0.5, 1.5)

func _ready():
	linear_velocity = Vector2(randf_range(0.5, 1) * -75, randf_range(0.5, 1) * -425).rotated(randf() * TAU)
	await get_tree().create_timer(randf_range(1, 4)).timeout
	queue_free()

func _physics_process(delta):
	scale = Vector2(scale_size, scale_size)
