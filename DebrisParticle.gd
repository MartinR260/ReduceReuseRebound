extends RigidBody2D


func _ready():
	linear_velocity = Vector2(randf_range(0.5, 1) * -75, randf_range(0.5, 1) * -425).rotated(randf() * TAU)
	await get_tree().create_timer(randf_range(1, 4)).timeout
	queue_free()
