extends RigidBody2D

@export var MAX_SPEED = 1000.0
@onready var sprite = $Sprite2D

var acceleration = 0
var direction : float
var starting_position : Vector2
var starting_rotation : float

func _ready():
	global_position = starting_position
	rotation = starting_rotation

func _process(delta):
	acceleration = move_toward(acceleration, MAX_SPEED, 13 * delta)
	var velocity = Vector2(cos(direction), sin(direction)) * acceleration
	
	var collision = move_and_collide(velocity)
	if collision:
		if collision.get_collider().name != "Player":
			print("Collided with: ", collision.get_collider().name)
			if collision.get_collider().name.begins_with("Breakable") or collision.get_collider().name.begins_with("@RigidBody2D"):
				#Bad solution, find out problem
				collision.get_collider().queue_free()
			queue_free()
	else:
		position += velocity
	
