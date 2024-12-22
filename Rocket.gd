extends RigidBody2D

@export var MAX_SPEED = 1000.0
@onready var particle_scene = preload("res://DebrisParticle.tscn")
signal broken_block

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
			for __ in range(5):
				var particle = particle_scene.instantiate()
				particle.global_position = global_position
				get_parent().add_child(particle)
			#print("Collided with: ", collision.get_collider().name)
			if collision.get_collider().name.begins_with("Breakable") or collision.get_collider().name.begins_with("@RigidBody2D"):
				# ^ Bad solution, find out problem
				emit_signal("broken_block")
				collision.get_collider().queue_free()
			queue_free()
	else:
		position += velocity
	
