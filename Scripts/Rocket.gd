extends RigidBody2D

@export var MAX_SPEED = 1000.0
@onready var debris_scene = preload("res://Scenes/DebrisParticle.tscn")
@onready var explosion_scene = preload("res://Scenes/Explosion.tscn")

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
			var explosion_sound = get_node("../Explosion")
			explosion_sound.play()
			
			var player = get_node("../Player")
			var player_distance = global_position.distance_to(player.global_position)
			#print(player_distance)
			if player and player_distance <= 40:
				var player_direction = (player.global_position - global_position).normalized()
				var player_force = 140 #125 to prevent 4-block jump
				player.velocity += player_direction * player_force 
				
			var explosion = explosion_scene.instantiate()
			explosion.global_position = global_position
			get_parent().add_child(explosion)
			
			for __ in range(int(randf_range(3,6))):
				var debris_particle = debris_scene.instantiate()
				debris_particle.global_position = global_position
				get_parent().add_child(debris_particle)
			
			
			#print("Collided with: ", collision.get_collider().name)
			if collision.get_collider().name.begins_with("Breakable") or collision.get_collider().name.begins_with("@RigidBody2D"):
				# ^ Bad solution, find out problem
				
				emit_signal("broken_block")
				collision.get_collider().queue_free()
			queue_free()
	else:
		position += velocity
	
